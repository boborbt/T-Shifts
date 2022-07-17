//
//  TShifts_UIWidget.swift
//  TShifts UIWidget
//
//  Created by Roberto Esposito on 15/06/22.
//  Copyright © 2022 Roberto Esposito. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import TShiftsFramework

struct Provider: TimelineProvider {
    let options: Options
    let calendarUpdater: CalendarShiftUpdater
    let shiftsStorage: CalendarShiftStorage
    
    init() {
        options = Options()
        calendarUpdater = CalendarShiftUpdater(calendarName: options.calendar, calendarUpdateCallback: {_ in })
        shiftsStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
    }

    
    func getSnapshot(in context: Context, completion: @escaping (TShiftsEntry) -> Void) {
        let entry = TShiftsEntry(date:Date(), options:options, storage:shiftsStorage)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TShiftsEntry>) -> Void) {
        var entries: [TShiftsEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TShiftsEntry(date:entryDate, options:options, storage:shiftsStorage)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> TShiftsEntry {
        TShiftsEntry(date:Date(), options:options, storage:shiftsStorage)
    }
}

struct ShiftsContainer: Identifiable {
    var id = UUID()
    let date: Date
    
    let values:[Shift]
    var shortcut: String {
        get {
            return values.first?.shortcut ?? "X"
        }
    }
}

struct TShiftsEntry: TimelineEntry {
    var date: Date
    let shifts: [ShiftsContainer]
    let storage: ShiftStorage
    let options: Options
        
    init(date: Date, options:Options, storage: ShiftStorage) {
        var result: [ShiftsContainer] = []
        for i in -1...1 {
            let date =  date.advanced(by: i.days())
            let container = ShiftsContainer(date: date, values:storage.shifts(at: date))
            result.append(container)
        }
        
        self.date = date
        self.shifts = result
        self.storage = storage
        self.options = options
    }
}

struct TShiftsUIWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("T-Shifts")
                .font(.title)
                .padding(.vertical)
            ForEach(entry.shifts) { (shifts:ShiftsContainer) in
                HStack {
                    Text(shifts.date, style: .offset)
                        .frame(width:40)
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.black, lineWidth: 1)
                        )
                        .background(Color.red)
                    Text(shifts.shortcut)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)

                }
            }
        }
    }
}

@main
struct TShiftsUIWidget: Widget {
    let kind: String = "TShifts_UIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TShiftsUIWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("T-shift widget")
        .description("7 days shifts")
    }
}

struct NotImplemented: Error {
    let message = "Not implemented"
}

struct DummyShiftStorage: ShiftStorage {
    func add(shift: Shift, toDate: Date) throws {
        throw NotImplemented()
    }
    
    func remove(shift: Shift, fromDate: Date) throws {
        throw NotImplemented()
    }
    
    func commit() throws -> [Date] {
        throw NotImplemented()
    }
    
    func isPresent(shift: Shift, at date: Date) -> Bool {
        return false
    }
    
    func shifts(at date: Date) -> [Shift] {
        return [
            Shift(description: "Mattino", shortcut: "M", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0))
        ]
    }
    
    func notifyChanges(to function: @escaping (Date) -> ()) {
        
    }
    
    func shiftsDescription(at date: Date) -> String? {
        return nil
    }
    
    func uniqueIdentifier(for date: Date) -> String {
        "n/a"
    }
    
    func date(forUniqueIdentifier identifier: String) -> Date? {
        return nil
    }
}

struct TShiftsUIWidget_Previews: PreviewProvider {
    static var previews: some View {
        TShiftsUIWidgetEntryView(entry: TShiftsEntry(date: Date(), options:Options(), storage: DummyShiftStorage()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
