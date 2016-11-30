//
//  Node.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Node {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kNodeNameKey: String = "name"
    private let kNodeUserKey: String = "user"
    private let kNodeInternalIdentifierKey: String = "id"
    private let kNodeShareUrlKey: String = "share_url"
    private let kNodeIsSubscriptionKey: String = "is_subscription"
    private let kNodeTopicCountKey: String = "topic_count"
    private let kNodeDescriptionValueKey: String = "description"
    private let kNodeSubCountKey: String = "sub_count"
    private let kNodeCoverKey: String = "cover"
    
    // MARK: Properties
    public var name: String?
    public var user: User?
    public var id: Int?
    public var shareUrl: String?
    public var isSubscription: Bool = false
    public var topicCount: Int?
    public var desc: String?
    public var subCount: Int?
    public var cover: String?
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the instance based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    convenience public init(object: Any) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the instance based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    public init(json: JSON) {
        name = json[kNodeNameKey].string
        user = User(json: json[kNodeUserKey])
        id = json[kNodeInternalIdentifierKey].int
        shareUrl = json[kNodeShareUrlKey].string
        isSubscription = json[kNodeIsSubscriptionKey].boolValue
        topicCount = json[kNodeTopicCountKey].int
        desc = json[kNodeDescriptionValueKey].string
        subCount = json[kNodeSubCountKey].int
        cover = json[kNodeCoverKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = name { dictionary[kNodeNameKey] = value }
        if let value = user { dictionary[kNodeUserKey] = value.dictionaryRepresentation() }
        if let value = id { dictionary[kNodeInternalIdentifierKey] = value }
        if let value = shareUrl { dictionary[kNodeShareUrlKey] = value }
        dictionary[kNodeIsSubscriptionKey] = isSubscription
        if let value = topicCount { dictionary[kNodeTopicCountKey] = value }
        if let value = desc { dictionary[kNodeDescriptionValueKey] = value }
        if let value = subCount { dictionary[kNodeSubCountKey] = value }
        if let value = cover { dictionary[kNodeCoverKey] = value }
        return dictionary
    }
    
}
