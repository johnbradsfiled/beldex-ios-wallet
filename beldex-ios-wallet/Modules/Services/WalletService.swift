//
//  WalletService.swift


import Foundation

public enum WalletError: Error {
    case noWalletName
    case noSeed
    case createFailed
    case openFailed
}

class WalletService {
    
    typealias GetWalletHandler = (Result<BDXWallet, WalletError>) -> Void
    
    // MARK: - Properties (static)
    
    static let shared = { WalletService() }()
    
    // MARK: - Properties (public)
      public var hasProceedWallet: Bool {
        get {
          return WalletDefaults.shared.proceedWalletID != nil
        }
      }
      public var hasWallets: Bool {
        get {
          return WalletDefaults.shared.walletsCount > 0
        }
      }
      // MARK: - Properties (public lazy)
      lazy var walletActiveState = { Observable<Int?>(nil) }()
      lazy var assetRefreshState = { Observable<Int?>(nil) }()
      // MARK: - Methods (Public)
      public static func validAddress(_ addr: String, symbol: String) -> Bool {
        if symbol == "BDX" {
          return BeldexWalletWrapper.validAddress(addr)
        }
        return false
      }
      public func verifyPassword(_ name: String, password: String) -> Bool {
        return BDXWalletBuilder(name: name, password: password).isValidatePassword()
      }

  
    public func createWallet(with style: CreateWalletStyle, result: GetWalletHandler?) {
        //    DispatchQueuePool.shared["XMRWallet:new"].async {
        var result_wallet: BDXWallet!
        switch style {
        case .new(let data):
            result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromScratch().generate()
            if result_wallet != nil {
                let WalletSeed = result_wallet.seed!
                UserDefaults.standard.set(result_wallet.publicAddress, forKey: "WalletpublicAddress")
                UserDefaults.standard.set(WalletSeed.sentence, forKey: "WalletSeed")
                UserDefaults.standard.set(result_wallet.walletName, forKey: "WalletName")
            } else {
                
            }
        case .recovery(let data, let recover):
            switch recover.from {
            case .seed:
                if let seedStr = recover.seed, let seed = Seed.init(sentence: seedStr) {
                    result_wallet = BDXWalletBuilder(name: data.name, password: data.pwd).fromSeed(seed).generate()
//                    print("\(result_wallet.balance)")
//                    print("\(result_wallet.history)")
//                    print("\(result_wallet.blockChainHeight)")
//                    print("\(result_wallet.secretSpendKey)")
                    if result_wallet != nil {
                        print("Height ==> \(result_wallet.blockChainHeight)")
                        let WalletSeed = result_wallet.seed!
                        UserDefaults.standard.set(result_wallet.publicAddress, forKey: "WalletpublicAddress")
                        UserDefaults.standard.set(WalletSeed.sentence, forKey: "WalletSeed")
                        UserDefaults.standard.set(result_wallet.walletName, forKey: "WalletName")
                    } else {
                        
                    }
                }
            case .keys:
                print("case Keys")
            }
        }
        //   }
    }
    
    
    
    public func openWallet(_ name: String, password: String, result: GetWalletHandler?) {
        DispatchQueuePool.shared["BDXWallet:" + name].async {
            if let wallet = BDXWalletBuilder(name: name, password: password).openExisting() {
                result?(.success(wallet))
            } else {
                result?(.failure(.openFailed))
            }
        }
    }
    
    
}
