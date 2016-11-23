//
//  String_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: - App版本 major.minor.patch
extension String {
    func version() -> (major: Int, minor: Int, patch: Int) {
        let array = components(separatedBy: ".")
        
        var ret: (major: Int, minor: Int, patch: Int) = (0, 0, 0)
        let count = array.count
        switch count {
        case 3:
            ret = (Int(array[0]) ?? 0, Int(array[1]) ?? 0, Int(array[2]) ?? 0)
        case 2:
            ret = (Int(array[0]) ?? 0, Int(array[1]) ?? 0, 0)
        case 1:
            ret = (Int(array[0]) ?? 0, 0, 0)
        default:
            ret = (0, 0, 0)
        }
        
        return ret
    }
}

