//
//  AppDelegate.swift
//  Marble
//
//  Created by Daniel Li on 10/9/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {
            
            NetworkActivityIndicatorManager.shared.isEnabled = true
                        
            if KeychainWrapper.hasAuthAndUser() {  // User is logged into app
                self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
            } else {  // User not auth'd
                self.window?.rootViewController = UIStoryboard.init(name: "Auth", bundle: nil).instantiateInitialViewController()
            }
        return true
    }

}

