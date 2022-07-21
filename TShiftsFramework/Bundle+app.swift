//
//  Bundle+app.swift
//  TShiftsFramework
//
//  Created by Roberto Esposito on 20/07/22.
//  Copyright © 2022 Roberto Esposito. All rights reserved.
//

import Foundation

extension Bundle {
    /// Return the main bundle when in the app or an app extension.
    static var app: Bundle {
        var components = main.bundleURL.path.split(separator: "/")
        var bundle: Bundle?

        if let index = components.lastIndex(where: { $0.hasSuffix(".app") }) {
            components.removeLast((components.count - 1) - index)
            bundle = Bundle(path: components.joined(separator: "/"))
        }

        return bundle ?? main
    }
}
