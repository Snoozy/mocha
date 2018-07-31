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
import AVFoundation
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        if KeychainWrapper.hasAuthAndUser() {  // User is logged into app
            self.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController()
        } else {  // User not auth'd
            self.window?.rootViewController = UIStoryboard.init(name: "Auth", bundle: nil).instantiateInitialViewController()
        }
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            NotificationCenter.default.post(name: Constants.Notifications.RefreshMainGroupState, object: self)
        }
        
        let builder = FlurrySessionBuilder.init()
            .withAppVersion(Bundle.main.releaseVersionNumber ?? "0")
            .withLogLevel(FlurryLogLevelCriticalOnly)
            .withCrashReporting(true)
            .withSessionContinueSeconds(10)
        
        Flurry.startSession("GTZHFWDFM7WY3G6PW6CG", with: builder)
        
        if let url = launchOptions?[.url] as? URL {
            return executeDeepLink(with: url)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return url.scheme == "marble" && executeDeepLink(with: url)
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
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        Networker.shared.sessionManager.backgroundCompletionHandler = completionHandler
    }
    
    private func executeDeepLink(with url: URL) -> Bool {
        print("qwerqwer")
        let recognizer = DeepLinkRecognizer(deepLinkTypes: [
            JoinGroupDeepLink.self
            ])
        
        guard let deepLink = recognizer.deepLink(matching: url) else {
            print("Unable to match URL: \(url.absoluteString)")
            return false 
        }
        
        switch deepLink {
        case let link as JoinGroupDeepLink: return joinGroup(with: link)
        default: fatalError("Unsupported DeepLink: \(type(of: deepLink))")
        }
        
    }
    
    var responder: SCLAlertViewResponder?
    
    private func joinGroup(with deepLink: JoinGroupDeepLink) -> Bool {
        guard let viewController = UIApplication.topViewController() else { return false }
        let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        viewController.present(alert, animated: true, completion: nil)
        
        Networker.shared.findGroupBy(code: deepLink.groupCode, completionHandler: { response in
            viewController.dismiss(animated: false, completion: nil)
            switch response.result {
            case .success:
                let response = response.result.value as! NSDictionary
                if let status = response["status"] as? Int {
                    if status == 0 {  // successfuly found group
                        
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        
                        let name = response["group_name"] as! String
                        let memberCount = response["member_count"] as! Int
                        let groupCode = response["code"] as! String
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false,
                            hideWhenBackgroundViewIsTapped: true
                        )
                        
                        let alert = SCLAlertView(appearance: appearance)
                        alert.addButton("Join Marble", action: {
                            Networker.shared.joinGroup(code: groupCode, completionHandler: { response in
                                switch response.result {
                                case .success(let value):
                                    print("segue")
                                    let json = JSON(value)
                                    print(json)
                                    let group = json["group"]
                                    let groupId = group["group_id"].int!
                                    State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0, members: group["members"].int ?? 1,  code: group["code"].string ?? String(groupId))
                                    NotificationCenter.default.post(name: Constants.Notifications.RefreshMainGroupState, object: self)
                                case .failure:
                                    print(response.debugDescription)
                                }
                            })
                        })
                        alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                            self.responder?.close()
                        })
                        self.responder = alert.showInfo(name, subTitle: String(memberCount) + (memberCount > 1 ? " members" : " member"))
                    }
                }
            case .failure:
                print(response.debugDescription)
            }
            
        })
        return true
    }
    
}
