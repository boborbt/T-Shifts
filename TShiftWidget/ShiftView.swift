//
//  ShiftView.swift
//  TShiftWidgetExtension
//
//  Created by Roberto Esposito on 20/07/22.
//  Copyright © 2022 Roberto Esposito. All rights reserved.
//

import SwiftUI
import WidgetKit

struct ShiftView: View {
    let highlight: Bool
    let date: Date
    let shortcuts:[String]
    let colors: [UIColor]
        
    func day() -> String {
        return "\(Calendar.current.dateComponents([.day], from: date).day!)"
    }
    
    static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
    
    func dayOfWeakIndex() -> Int {
        let cal = Calendar.current
        
        return cal.component(.weekday, from: date)
    }
    
    func dayOfWeak() -> String {
        let index = dayOfWeakIndex()
        var cal = Calendar.current
        
        cal.locale = ShiftView.preferredLocale()
        return cal.shortWeekdaySymbols[index - 1].capitalized
    }
    
    
    func scAtIndex(_ index:Int) -> String{
        if index < shortcuts.count {
            return shortcuts[index]
        } else {
            return " "
        }
    }
    
    func clrAtIndex(_ index: Int) -> UIColor {
        if index < colors.count {
            return colors[index]
        } else {
            return UIColor.clear
        }
    }
    
    func ellipsis() -> String {
        if shortcuts.count > 2 {
            return "..."
        } else {
            return ""
        }
    }
    
    func dowBackColor() -> Color {
        if dayOfWeakIndex() == 1 {
            return Color(UIColor.label)
        } else {
            return Color(UIColor.systemBackground)
        }
    }
    
    func dowForeColor() -> Color {
        if dayOfWeakIndex() != 1 {
            return Color(UIColor.label)
        } else {
            return Color(UIColor.systemBackground)
        }
    }

    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(dayOfWeak())
                .font(.footnote)
                .foregroundColor(dowForeColor())
                .background(dowBackColor())
                .cornerRadius(2)

            Text(day())
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5.0)
                .foregroundColor(highlight ? Color.red : nil)
            
            ForEach(0 ..< 2, id:\.self) {
                Text(scAtIndex($0))
                    .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
                    .frame(width: 34.0, height: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/)
                    .background(Color(clrAtIndex($0)))
                    .cornerRadius(5)
            }
            
            Text(ellipsis())
                .frame(width: 30, height: 10)
        }
        .frame(width: 30, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
    }

}

struct ShiftView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftView(highlight:true, date: Date(), shortcuts:["M", "P", "A", "B"], colors: [UIColor.red, UIColor.yellow, UIColor.green, UIColor.blue])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ShiftView(highlight:false, date: Date().advanced(by: 4.days()), shortcuts:["☎️"], colors: [UIColor.red])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
