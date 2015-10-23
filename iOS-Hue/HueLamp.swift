//
//  HueLamp.swift
//  iOS-HueApp
//
//  Created by Guus Beckett on 20/10/15.
//  Copyright © 2015 Reupload. All rights reserved.
//

import UIKit

class HueLamp {
    var id : Int!
    var name : String!
    var isOn: Bool!
    var hue: Int!
    var saturation: Int!
    var brightness: Int!
    
    func getImage() -> UIImage {
        if isOn.boolValue {
            let hueImage : CGFloat = CGFloat((Double(hue)) / 65535.0)
            let saturationImage : CGFloat = CGFloat(Double(saturation) / 255.0)
            let brightnessImage : CGFloat = CGFloat(Double(brightness) / 255.0)
            let alphaImage : CGFloat = 1.0
            let colour = UIColor.init(hue: hueImage, saturation: saturationImage, brightness: brightnessImage, alpha: alphaImage)
            return colour.convertImage()
        }
        return UIColor.blackColor().convertImage()
    }
}

public extension UIColor {
    func convertImage() -> UIImage {
        let rect : CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}