//
//  UserServiceHandlers.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserCommentsHandler: MultiPageBaseServiceHandler {
    let CommentsKey: String = "comments"
    
    // MARK: Properties
    var comments: [User]?
    
    override init(json: JSON) {
        super.init(json: json)
        
        
        if let items = json[CommentsKey].array, items.count > 0 {
            comments = []
            
            for item in items {
                comments?.append(User(json: item))
            }
        }
    }
}

