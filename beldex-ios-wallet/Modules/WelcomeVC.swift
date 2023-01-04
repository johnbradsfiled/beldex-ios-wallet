//
//  WelcomeVC.swift
//  beldex-ios-wallet
//
//  Created by sanada yukimura on 6/2/22.
//

import UIKit

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func createWalletAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateWalletViewController") as! CreateWalletViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func restoreWalletAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImportWalletViewController") as! ImportWalletViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func NodeAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NodeListViewController") as! NodeListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TabBarAction(sender:UIButton){
        
    }
    @IBAction func CuurencyarAction(sender:UIButton){
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
