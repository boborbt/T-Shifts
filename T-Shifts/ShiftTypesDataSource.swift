//
//  ShiftTypesDataSource.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class ShiftTypesDataSource : NSObject, UITableViewDataSource {
    weak var options: Options?
    
    init(withOptions opts: Options ) {
        super.init()
        
        options = opts        
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section ==  0  else { return 0 }

        return options!.shiftNames().count
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftTypeCell")!
        let shiftKey = options!.shifNamesOrder()[indexPath.row]
        let shiftName = options!.shiftNames()[shiftKey]
        
        cell.textLabel?.text = shiftName
        cell.detailTextLabel?.text = shiftKey
        
        return cell
    }

    
}
