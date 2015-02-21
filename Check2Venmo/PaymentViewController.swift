//
//  PaymentViewController.swift
//  Check2Venmo
//
//  Created by Joseph Lin on 2/21/15.
//  Copyright (c) 2015 Joseph Lin. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    var amount = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.amountTextField.text =  String(format:"%1.2f", self.amount);
    }
    
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
    }
}
