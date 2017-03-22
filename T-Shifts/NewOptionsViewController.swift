//
//  NewOptionsViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 22/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class NewOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView()
        let label = UILabel()
        label.text = "Test"
        

        
        scrollView.addSubview(label)

        self.view.addSubview(scrollView)
        self.view.backgroundColor = UIColor.white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollView.contentSize = CGSize(width: 400, height: 2000)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: scrollView.topAnchor ).isActive = true
        
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
