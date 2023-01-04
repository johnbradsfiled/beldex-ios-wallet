//
//  SendViewController.swift
//  beldex-ios-wallet
//
//  Created by Blockhash on 15/12/22.
//

import UIKit

class SendViewController: UIViewController {
    
    @IBOutlet weak var txtaddress:UITextField!
    @IBOutlet weak var txtamount:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }
    
    @IBAction func BackAction(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    // Reconnect work
    @IBAction func Send_Action(sender:UIButton){
        print("===================> \(txtaddress.text!)")
        print("===================> \(txtamount.text!)")
        
        
        
    }

   

}
