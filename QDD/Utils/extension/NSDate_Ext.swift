//
//  NSDate_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: - Formatter  yyyy-MM-dd hh:mm:ss
extension NSDate {
    class func format(_ formatString: String = "yyyy-MM-dd hh:mm:ss") -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatString
        dateFormatter.locale = NSLocale.current
        return dateFormatter
    }
}

