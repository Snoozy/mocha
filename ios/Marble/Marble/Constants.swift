//
//  Constants.swift
//  Marble
//
//  Created by Daniel Li on 2/7/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit

#if DEV
//    let API_URL = "http://192.168.10.102:8000"
    let API_URL = "http://127.0.0.1:8000"
//    let API_URL = "https://api.amarbleapp.com"
#else
//    let API_URL = "http://192.168.10.102:8000"
    let API_URL = "https://api.amarbleapp.com"
#endif

struct Constants {
    
    struct Colors {
        static let MarbleBlue = UIColor(red: CGFloat(49.0/255.0), green: CGFloat(113/255.0), blue:CGFloat(239/255.0), alpha: CGFloat(1.0))
        
        static let DisabledGray = UIColor(red: CGFloat(219.0/255.0), green: CGFloat(219/255.0), blue:CGFloat(219/255.0), alpha: CGFloat(1.0))
        
        static let FormUnderlineGray = UIColor(red: CGFloat(211.0/255.0), green: CGFloat(211/255.0), blue:CGFloat(211/255.0), alpha: CGFloat(1.0))
        
        static let UnseenHighlight = UIColor(red: CGFloat(50/255.0), green: CGFloat(50/255.0), blue: CGFloat(255/255.0), alpha: 1.0)
        
        static let HomeBgColor = UIColor(red: 226/250, green: 226/250, blue: 226/250, alpha: 1.0)
        
        static let InfoNotifColor = Constants.Colors.MarbleBlue
    }
    
    struct Notifications {
        static let ClipUploadStarted = Notification.Name("com.amarbleapp.clipUploadStarted")
        static let ClipUploadFinished = Notification.Name("com.amarbleapp.clipUploadFinished")
        static let RefreshMainGroupState = Notification.Name("com.amarbleapp.refreshMainGroupState")
    }
    
    struct Identifiers {
        static let BackgroundNetwork = "com.amarbleapp.backgroundNetwork"
    }
    
    static let ApiUrl = API_URL
    
    // max video length in seconds
    
    static let MaxVideoSize: Int64 = 15500000
        
    static let ImageJpegCompression: CGFloat = 0.8
    
    static let DoubleTapDelay: Int = 200  // in milliseconds
    
    static let IphoneXMargin: Int = 50
    
    static let MaxRecordingDuration: Int = 60  // in seconds
}
