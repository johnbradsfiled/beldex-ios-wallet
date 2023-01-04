//
//  CurrencyViewController.swift
//  beldex-ios-wallet
//
//  Created by Blockhash on 09/12/22.
//

import UIKit
import Alamofire

class CurrencyViewController: UIViewController {
    
    @IBOutlet weak var txtBdx:UITextField!
    @IBOutlet weak var txtCurrency:UITextField!
    @IBOutlet weak var lblresult:UILabel!
    
    public lazy var loadingState = { Postable<Bool>() }()
    private var currencyName = ""
    private var BdxCurrencyValue = ""
    private var CurrencyValue: Double!
    private var refreshDuration: TimeInterval = 60
    private var marketsDataRequest: DataRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    @IBAction func BackAction(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func reloadData(_ json: [String: [String: Any]]) {
        let xmrAmount = json["beldex"]?[currencyName] as? Double
        if xmrAmount != nil {
            print("====1 BDX=========>  \(xmrAmount!)")
            CurrencyValue = xmrAmount
        }
        if CurrencyValue != nil {
            let tax = Double(BdxCurrencyValue)! * CurrencyValue
            lblresult.text = "\(tax)"
            print("-----------------------Final Value------------------------------------>\(tax)")
        }
    }
  
    private func fetchMarketsData(_ showHUD: Bool = false) {
        if let req = marketsDataRequest {
            req.cancel()
        }
        if showHUD { loadingState.newState(true) }
        let startTime = CFAbsoluteTimeGetCurrent()
        let Url = "https://api.coingecko.com/api/v3/simple/price?ids=beldex&vs_currencies=\(currencyName)"
        let request = Session.default.request("\(Url)")
        request.responseJSON(queue: .main, options: .mutableLeaves) { [weak self] (resp) in
            guard let SELF = self else { return }
            SELF.marketsDataRequest = nil
            if showHUD { SELF.loadingState.newState(false) }
            switch resp.result {
            case .failure(_): break
             //   HUD.showError(error.localizedDescription)
            case .success(let value):
                SELF.reloadData(value as? [String: [String: Any]] ?? [:])
            }
            let endTime = CFAbsoluteTimeGetCurrent()
            let requestDuration = endTime - startTime
            if requestDuration >= SELF.refreshDuration {
                SELF.fetchMarketsData()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + SELF.refreshDuration - requestDuration) {
                    guard let SELF = self else { return }
                    SELF.fetchMarketsData()
                }
            }
        }
        marketsDataRequest = request
    }
    

    
    //MARK:-UIButton action calculation
    
    @IBAction func SendAction(sender:UIButton){
        self.BdxCurrencyValue = txtBdx.text!
        self.currencyName = txtCurrency.text!
        
        fetchMarketsData(true)
        reloadData([:])
    }

   

}
