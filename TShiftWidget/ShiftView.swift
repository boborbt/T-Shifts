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
    
    func dayOfWeak() -> String {
        let index = Calendar.current.component(.weekday, from: date) // this returns an Int
        return Calendar.current.shortWeekdaySymbols[index - 1] // subtract 1 since the index starts at 1
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
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(dayOfWeak())
                .font(.footnote)
            Text(day())
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 5.0)
                .foregroundColor(highlight ? Color.red : Color.black)
            
            ForEach(0 ..< 2, id:\.self) {
                Text(scAtIndex($0))
                    .padding(/*@START_MENU_TOKEN@*/.all, 5.0/*@END_MENU_TOKEN@*/)
                    .frame(width: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/30.0/*@END_MENU_TOKEN@*/)
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
        
        ShiftView(highlight:false, date: Date(), shortcuts:["M"], colors: [UIColor.red])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
