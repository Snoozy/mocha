//
//  Common.swift
//  Marble
//
//  Created by Daniel Li on 4/18/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

enum MediaType {
    case video
    case image
}

func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

// Converts milliseconds delta to hours string
func calcTime(time: Int64) -> String {
    let start: Int64 = Int64(NSDate().timeIntervalSince1970 * 1000)
    let delta = start - time
    if delta < 3600000 {  // less than 1 hr ago
        let temp = delta/60000
        if temp <= 0 {  // less than 1 min ago
            return "Just now"
        }
        return String(temp) + "m ago"
    }
    return String(delta/3600000) + "h ago"
}

func videoPreviewImage(fileUrl: URL) -> UIImage? {
    
    let asset = AVURLAsset(url: fileUrl)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
    
    do {
        let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
        return UIImage(cgImage: imageRef)
    }
    catch let error as NSError
    {
        print("Image generation failed with error \(error)")
        return nil
    }
}

func styleLayer(layer: CALayer) {
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowOpacity = 1
    layer.shadowRadius = 3
}

