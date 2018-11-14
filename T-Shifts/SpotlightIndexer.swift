//
//  SpotlightIndexer.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 14/11/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import Foundation
import CoreSpotlight
import os.log

class SpotlightIndexer {
    var shiftStorage: ShiftStorage
    let monthFormatter:DateFormatter!
    let dayFormatter:DateFormatter!
    let index: CSSearchableIndex!
    
    init(shiftStorage: ShiftStorage) {
        self.shiftStorage = shiftStorage
        
        monthFormatter = DateFormatter()
        dayFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL"
        dayFormatter.dateFormat = "d"
        
        index =  CSSearchableIndex.default()
    }
    
    private func searchableItem(for shifts:[Shift], at date:Date) -> CSSearchableItem {
        let attributeSet = CSSearchableItemAttributeSet()
        attributeSet.contentType = "public.calendar-event"
        attributeSet.startDate = date
        attributeSet.endDate = date
        attributeSet.allDay = true
        attributeSet.title = self.shiftStorage.shiftsDescription(at: date)!
        attributeSet.keywords = [monthFormatter.string(from: date), dayFormatter.string(from:date)] + shifts.map {
            shift in return shift.description
        }
        
        
        let item = CSSearchableItem(uniqueIdentifier: shiftStorage.uniqueIdentifier(for: date), domainIdentifier: "shifts", attributeSet: attributeSet)
        

    
        return item
    }
    
    
    func addItemsToSpotlightIndex() {
        index.deleteAllSearchableItems() { (error) in
            if error != nil {
                os_log("Could not delete searchable items")
            }
        }
        
        
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        let startDay = calendar.date(byAdding: .day, value: -30, to: Date())!
        var items:[CSSearchableItem] = []
        
        for numDays in 0...61 {
            let date = calendar.date(byAdding: .day, value: numDays, to: startDay )!
            if self.shiftStorage.shifts(at: date).isEmpty {
                continue
            }
            
            let shifts = shiftStorage.shifts(at:date)
            items.append(searchableItem(for: shifts, at:date))
        }
        
        index.indexSearchableItems(items) { (error) in
            if error != nil {
                os_log(.debug, "Cannot index shifts %s", error.debugDescription)
            } else {
                os_log(.debug, "Indexing shifts completed")
            }
        }
        
    }
    
    func reindexShifts(for date:Date) {
        let shifts = shiftStorage.shifts(at:date)
        let item = searchableItem(for: shifts, at: date)
        
        index.deleteSearchableItems(withIdentifiers: [shiftStorage.uniqueIdentifier(for: date)]) { (error) in
            if error != nil {
                os_log(.debug, "Cannot delete shift. Reason: %s", error.debugDescription)
            } else {
                os_log(.debug, "Deleting index for shifts completed")
            }
        }
        
        index.indexSearchableItems([item]) { (error) in
            if error != nil {
                os_log(.debug, "Cannot re-index shift. Reason: %s", error.debugDescription)
            } else {
                os_log(.debug, "Re-indexing shift completed")
            }
        }
    }
}
