//
//  Errors.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 16/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

public enum ShiftErrors: Error {
    case DuplicateTemplate
}


public enum CalendarUpdaterError {
    case accessNotGranted
    case accessError(String)
    case updateError(String)
}
