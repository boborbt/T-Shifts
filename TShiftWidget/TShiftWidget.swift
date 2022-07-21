//
//  TShiftWidget.swift
//  TShiftWidget
//
//  Created by Roberto Esposito on 17/07/22.
//  Copyright © 2022 Roberto Esposito. All rights reserved.
//

import WidgetKit
import SwiftUI
import TShiftsFramework
import OSLog

let SHIFTS_ON_SYSTEM_SMALL = 3
let SHIFTS_ON_SYSTEM_MEDIUM = 8

struct Provider: TimelineProvider {
    func shiftsData() -> [ShiftInfo] {
        os_log(.info, "Widget: Fetching data")
        let options = Options()
        let calendarUpdater = CalendarShiftUpdater(calendarName: options.calendar, calendarUpdateCallback: {_ in } )
        let shiftStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
        
        var result: [ShiftInfo] = []
        let numDates = SHIFTS_ON_SYSTEM_MEDIUM
        for dayIncrement in 0..<numDates {
            let date = Date().addingTimeInterval(dayIncrement.days())
            let shifts = shiftStorage.shifts(at: date)
            let templates = shifts.map { shift in
                return options.shiftTemplates.template(for: shift)!
            }.sorted { t1, t2 in return t1.position < t2.position }
            result.append(ShiftInfo(shiftDate: date, templates: templates))
        }
        
        return result
    }
    
    func placeholder(in context: Context) -> ShiftsEntry {
        ShiftsEntry(date: Date(), shiftInfos:shiftsData())
    }

    func getSnapshot(in context: Context, completion: @escaping (ShiftsEntry) -> ()) {
        let entry = ShiftsEntry(date: Date(), shiftInfos:shiftsData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        os_log("Updating the timeline")
        var entries: [ShiftsEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ShiftsEntry(date: entryDate, shiftInfos: shiftsData())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ShiftInfo {
    let shiftDate: Date
    let templates: [ShiftTemplate]
}

struct ShiftsEntry: TimelineEntry {
    let date: Date
    let shiftInfos: [ShiftInfo]
}

struct TShiftWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
            HStack {
                ForEach(shiftsData(), id: \.date) { view in
                    view
                }
            }
    }
    
    func isToday(_ date:Date) -> Bool {
        return Calendar(identifier: .gregorian ).isDateInToday(date)
    }
    
    func shiftsData() -> [ShiftView] {
        let numShifts = widgetFamily == .systemSmall ? SHIFTS_ON_SYSTEM_SMALL : SHIFTS_ON_SYSTEM_MEDIUM
        
        os_log("shift infos >= numShifts: \(entry.shiftInfos.count >= numShifts)")

        var result:[ShiftView] = []
        for index in 0..<min(numShifts, entry.shiftInfos.count) {
            let si = entry.shiftInfos[index]
            let shortcuts = si.templates.map { t in return t.shift.shortcut }
            let colors = si.templates.map { t in return t.color }
            result.append(ShiftView(highlight: isToday(si.shiftDate), date: si.shiftDate, shortcuts: shortcuts, colors: colors))
        }
        
        return result
    }
}

@main
struct TShiftWidget: Widget {
    let kind: String = "TShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TShiftWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("T-Shifts Widget")
        .description("Displays the shifts for the next few days")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TShiftWidget_Previews: PreviewProvider {
    static func shiftsInfo(_ widgetFamily: WidgetFamily) -> [ShiftInfo] {
        let result = [
            ShiftInfo(shiftDate: Date(), templates: [
                ShiftTemplate(shift: Shift(description: "Mattino", shortcut: "M", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.yellow )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(1.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Pomeriggio", shortcut: "P", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.red ),
                ShiftTemplate(shift: Shift(description: "Reperibilità", shortcut: "R", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.green ),
                ShiftTemplate(shift: Shift(description: "Ferie", shortcut: "F", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.orange )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(2.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(3.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(4.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ]),
            ShiftInfo(shiftDate: Date().addingTimeInterval(5.days()), templates: [
                ShiftTemplate(shift: Shift(description: "Notte", shortcut: "N", isAllDay: true, startTime: (0,0), endTime: (23,59), alert: (false, 0)), position: 0, color: UIColor.blue )
            ])
        ]
        
        let numElems = widgetFamily == .systemSmall ? SHIFTS_ON_SYSTEM_SMALL : SHIFTS_ON_SYSTEM_MEDIUM
        return Array(result[0..<numElems])
    }
    
    
    static var previews: some View {
        Group {
            TShiftWidgetEntryView(entry: ShiftsEntry(date: Date(), shiftInfos: shiftsInfo(.systemSmall)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            TShiftWidgetEntryView(entry: ShiftsEntry(date: Date(), shiftInfos: shiftsInfo(.systemMedium)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
