//
//  String+Extension.swift
//  Daker
//
//  Created by RHCT on 16/8/3.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


//MARK: - App版本 major.minor.patch
extension String {
    func version() -> (major: Int, minor: Int, patch: Int) {
        let array = self.componentsSeparatedByString(".")
        
        var ret: (major: Int, minor: Int, patch: Int) = (0, 0, 0)
        switch array.count {
        case let count where count >= 3:
            ret = (array[0].toInt() ?? 0, array[1].toInt() ?? 0, array[2].toInt() ?? 0)
        case 2:
            ret = (array[0].toInt() ?? 0, array[1].toInt() ?? 0, 0)
        case 1:
            ret = (array[0].toInt() ?? 0, 0, 0)
        default:
            ret = (0, 0, 0)
        }
        
        return ret
    }
}
