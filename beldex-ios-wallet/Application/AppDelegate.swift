//
//  AppDelegate.swift
//  beldex-ios-wallet
//
//  Created by sanada yukimura on 6/2/22.
//

import UIKit

@main
@available(iOS 13.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var visualEffectView: UIVisualEffectView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    
    // MARK: - Methods (Private)
    
    private func addBlurForWindow() {
        let blur: UIBlurEffect
        blur = UIBlurEffect(style: .light)
        let visualView = VisualEffectView(effect: blur)
        visualView.frame = self.window?.bounds ?? .zero
        visualView.blurRadius = px(18)
        self.window?.addSubview(visualView)
        self.visualEffectView = visualView
    }
    
    private func removeBlurForWindow() {
        guard let visualEffectView = self.visualEffectView else { return }
        visualEffectView.removeFromSuperview()
        self.visualEffectView = nil
    }
}
