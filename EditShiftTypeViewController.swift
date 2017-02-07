//
//  EditShiftTypeViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class EditShiftTypeViewController: UIViewController {
    @IBOutlet weak var shortcutTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var shortcutText: String?
    var descriptionText:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shortcutTextField!.text = shortcutText
        descriptionTextField!.text = descriptionText
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
