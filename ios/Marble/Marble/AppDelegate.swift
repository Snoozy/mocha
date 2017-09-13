//
//  AppDelegate.swift
//  Marble
//
//  Created by Daniel Li on 10/9/16.
//  Copyright © 2016 Marble, LLC. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator
import UserNotifications

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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Zero out badge number whenever it enters foreground
        //application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("DEVICE TOKEN: " + token)
        State.shared.ping(deviceToken: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register notifs")
        print(error)
        State.shared.ping(deviceToken: nil)
    }

}

