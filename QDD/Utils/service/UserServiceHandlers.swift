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
    private let CommentsKey: String = "comments"
    
    // MARK: Properties
    var comments: [Comment]?
    
    override init(json: JSON) {
        super.init(json: json)
        
        
        if let items = json[CommentsKey].array, items.count > 0 {
            comments = []
            
            for item in items {
                comments?.append(Comment(json: item))
            }
        }
    }
}

class UserTopicsHandler: MultiPageBaseServiceHandler {
    private let TopicsKey: String = "topics"
    
    // MARK: Properties
    var topics: [Topic]?
    
    override init(json: JSON) {
        super.init(json: json)
        
        
        if let items = json[TopicsKey].array, items.count > 0 {
            topics = []
            
            for item in items {
                topics?.append(Topic(json: item))
            }
        }
    }
}

class UserNodesHandler: MultiPageBaseServiceHandler {
    private let NodesKey: String = "nodes"
    
    // MARK: Properties
    var nodes: [Node]?
    
    override init(json: JSON) {
        super.init(json: json)
        
        
        if let items = json[NodesKey].array, items.count > 0 {
            nodes = []
            
            for item in items {
                nodes?.append(Node(json: item))
            }
        }
    }
}

