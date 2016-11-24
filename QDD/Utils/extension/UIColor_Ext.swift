//
//  UIColor_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/24.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

fileprivate extension Int {
    
    //由 a 到 aa
    func duplicate4bits() -> Int {
        return (self << 4) + self
    }
}

extension UIColor {
    
    /**
     #FFF  #FFFFFF  FFFFFF  FFF
     
     - parameter hexString: hexstring  alpha = 1.0
     
     - returns: color
     */
    public convenience init?(hexString: String) {
        self.init(hexString: hexString, alpha: 1.0)
    }
    
    /**
     #FFF
     
     - parameter hex3:  三位hex
     - parameter alpha: alpha
     
     - returns: color
     */
    private convenience init?(hex3: Int, alpha: Float) {
        self.init(red:   CGFloat( ((hex3 & 0xF00) >> 8).duplicate4bits() ) / 255.0,
                  green: CGFloat( ((hex3 & 0x0F0) >> 4).duplicate4bits() ) / 255.0,
                  blue:  CGFloat( ((hex3 & 0x00F) >> 0).duplicate4bits() ) / 255.0, alpha: CGFloat(alpha))
    }
    
    /**
     #FFFFFF
     
     - parameter hex6:  六位hex
     - parameter alpha: alpha
     
     - returns: color
     */
    private convenience init?(hex6: Int, alpha: Float) {
        self.init(red:   CGFloat( (hex6 & 0xFF0000) >> 16 ) / 255.0,
                  green: CGFloat( (hex6 & 0x00FF00) >> 8 ) / 255.0,
                  blue:  CGFloat( (hex6 & 0x0000FF) >> 0 ) / 255.0, alpha: CGFloat(alpha))
    }
    
    /**
     16进制数 生成颜色
     
     - parameter hexString:   16进制数   (0x000000 ... 0xFFFFFF)
     - parameter alpha: alpha           (0.0 ... 1.0)
     
     - returns: color
     */
    public convenience init?(hexString: String, alpha: Float) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 1))
        }
        
        guard let hexVal = Int(hex, radix: 16) else {
            return nil
        }
        
        switch hex.characters.count {
        case 3:
            self.init(hex3: hexVal, alpha: alpha)
        case 6:
            self.init(hex6: hexVal, alpha: alpha)
        default:
            return nil
        }
    }
    
    /**
     16进制数 生成颜色 alpha 为 1
     
     - parameter hex: 16进制数
     
     - returns: color
     */
    public convenience init?(hex: Int) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    /**
     16进制数 生成颜色
     
     - parameter hex:   16进制数    (0x000000 ... 0xFFFFFF)
     - parameter alpha: alpha     (0.0 ... 1.0)
     
     - returns: color
     */
    public convenience init?(hex: Int, alpha: Float) {
        if (0x000000 ... 0xFFFFFF) ~= hex {
            self.init(hex6: hex , alpha: alpha)
        } else {
            return nil
        }
    }
    
}


