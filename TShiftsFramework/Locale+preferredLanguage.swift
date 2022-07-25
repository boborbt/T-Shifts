//
//  Locale+preferredLanguage.swift
//  TShiftsFramework
//
//  Created by Roberto Esposito on 25/07/22.
//  Copyright © 2022 Roberto Esposito. All rights reserved.
//

import Foundation

extension Locale {
    public static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}
