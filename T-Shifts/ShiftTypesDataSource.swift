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

        return options!.shiftTemplates.count
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftTypeCell")!
        let pos = indexPath.row
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        
        let shiftTemplates = delegate.shiftTemplates!
        let shift = shiftTemplates.template(at: pos)!.shift
        
        cell.textLabel?.text = shift.description
        cell.detailTextLabel?.text = shift.shortcut
        
        return cell
    }

    
}
