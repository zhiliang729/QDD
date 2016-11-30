//
//  MultiPageBaseServiceHandler.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class MultiPageBaseServiceHandler: BaseServiceHandler {
    let HasMoreKey = "has_more"
    let NextStartKey = "next_start"
    
    var hasMore: Bool = false
    var nextStart: Int?
    
    override init(json: JSON) {
        super.init(json: json)
        
        hasMore = json[HasMoreKey].boolValue
        nextStart = json[NextStartKey].int
    }
}
