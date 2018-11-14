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
    
    init(shiftStorage: ShiftStorage) {
        self.shiftStorage = shiftStorage
    }
    
    
    func addItemsToSpotlightIndex() {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        let startDay = calendar.date(byAdding: .day, value: -30, to: Date())!
        var items:[CSSearchableItem] = []
        
        for numDays in 0...61 {
            let date = calendar.date(byAdding: .day, value: numDays, to: startDay )!
            if self.shiftStorage.shifts(at: date).isEmpty {
                continue
            }
            
            let monthFormatter = DateFormatter()
            let dayFormatter = DateFormatter()
            monthFormatter.dateFormat = "LLLL"
            dayFormatter.dateFormat = "d"
            
            
            let attributeSet = CSSearchableItemAttributeSet()
            attributeSet.contentType = "public.calendar-event"
            attributeSet.startDate = date
            attributeSet.endDate = date
            attributeSet.allDay = true
            attributeSet.title = self.shiftStorage.shiftsDescription(at: date)!
            attributeSet.keywords = [monthFormatter.string(from: date), dayFormatter.string(from:date)] + shiftStorage.shifts(at: date).map { shift in return shift.description }
            
            
            let item = CSSearchableItem(uniqueIdentifier: shiftStorage.uniqueIdentifier(for: date), domainIdentifier: "shifts", attributeSet: attributeSet)
            
            items.append(item)
        }
        
        let index = CSSearchableIndex.default()
        index.indexSearchableItems(items) { (error) in
            if error != nil {
                os_log(.debug, "Cannot index shifts %s", error.debugDescription)
            } else {
                os_log(.debug, "Indexing shifts completed")
            }
        }
        
    }
}
