//
//  AccountServiceHandlers.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class AccountHandler: BaseServiceHandler {
    
    // MARK: Properties
    var user: User?
    
    public override init(json: JSON) {
        super.init(json: json)
        
        user = User(json: json)
    }
}
