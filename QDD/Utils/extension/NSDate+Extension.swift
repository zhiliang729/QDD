//
//  NSDate+Extension.swift
//  Daker
//
//  Created by RHCT on 16/7/28.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

//MARK: - Formatter  yyyy-MM-dd hh:mm:ss
extension NSDate {
    class func getDateFormat(dateFormat: String = "yyyy-MM-dd hh:mm:ss") -> NSDateFormatter{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = NSLocale.currentLocale()
        return dateFormatter
    }
}
