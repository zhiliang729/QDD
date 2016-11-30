//
//  Topic.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Topic {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kTopicUserKey: String = "user"
    private let kTopicSourceKey: String = "source"
    private let kTopicNodeKey: String = "node"
    private let kTopicDescriptionValueKey: String = "description"
    private let kTopicLeadKey: String = "lead"
    private let kTopicStyleKey: String = "style"
    private let kTopicRecommendedKey: String = "recommended"
    private let kTopicImgsKey: String = "imgs"
    private let kTopicViewCountKey: String = "view_count"
    private let kTopicLikeCountKey: String = "like_count"
    private let kTopicStatusKey: String = "status"
    private let kTopicFavoritedKey: String = "favorited"
    private let kTopicLikedKey: String = "liked"
    private let kTopicSourceNameKey: String = "source_name"
    private let kTopicInternalIdentifierKey: String = "id"
    private let kTopicIsOriginalKey: String = "is_original"
    private let kTopicMLinkKey: String = "m_link"
    private let kTopicIsLocalhostKey: String = "is_localhost"
    private let kTopicPublishedKey: String = "published"
    private let kTopicTitleKey: String = "title"
    private let kTopicCommentCountKey: String = "comment_count"
    
    // MARK: Properties
    public var user: User?
    public var source: Source?
    public var node: Node?
    public var desc: String?
    public var lead: String?
    public var style: Int?
    public var recommended: Bool = false
    public var imgs: [String]?
    public var viewCount: Int?
    public var likeCount: Int?
    public var status: Int?
    public var favorited: Bool = false
    public var liked: Bool = false
    public var sourceName: String?
    public var id: Int?
    public var isOriginal: Bool = false
    public var mLink: String?
    public var isLocalhost: Bool = false
    public var published: String?
    public var title: String?
    public var commentCount: Int?
    
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
        user = User(json: json[kTopicUserKey])
        source = Source(json: json[kTopicSourceKey])
        node = Node(json: json[kTopicNodeKey])
        desc = json[kTopicDescriptionValueKey].string
        lead = json[kTopicLeadKey].string
        style = json[kTopicStyleKey].int
        recommended = json[kTopicRecommendedKey].boolValue
        if let items = json[kTopicImgsKey].array { imgs = items.map { $0.stringValue } }
        viewCount = json[kTopicViewCountKey].int
        likeCount = json[kTopicLikeCountKey].int
        status = json[kTopicStatusKey].int
        favorited = json[kTopicFavoritedKey].boolValue
        liked = json[kTopicLikedKey].boolValue
        sourceName = json[kTopicSourceNameKey].string
        id = json[kTopicInternalIdentifierKey].int
        isOriginal = json[kTopicIsOriginalKey].boolValue
        mLink = json[kTopicMLinkKey].string
        isLocalhost = json[kTopicIsLocalhostKey].boolValue
        published = json[kTopicPublishedKey].string
        title = json[kTopicTitleKey].string
        commentCount = json[kTopicCommentCountKey].int
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = user { dictionary[kTopicUserKey] = value.dictionaryRepresentation() }
        if let value = source { dictionary[kTopicSourceKey] = value.dictionaryRepresentation() }
        if let value = node { dictionary[kTopicNodeKey] = value.dictionaryRepresentation() }
        if let value = desc { dictionary[kTopicDescriptionValueKey] = value }
        if let value = lead { dictionary[kTopicLeadKey] = value }
        if let value = style { dictionary[kTopicStyleKey] = value }
        dictionary[kTopicRecommendedKey] = recommended
        if let value = imgs { dictionary[kTopicImgsKey] = value }
        if let value = viewCount { dictionary[kTopicViewCountKey] = value }
        if let value = likeCount { dictionary[kTopicLikeCountKey] = value }
        if let value = status { dictionary[kTopicStatusKey] = value }
        dictionary[kTopicFavoritedKey] = favorited
        dictionary[kTopicLikedKey] = liked
        if let value = sourceName { dictionary[kTopicSourceNameKey] = value }
        if let value = id { dictionary[kTopicInternalIdentifierKey] = value }
        dictionary[kTopicIsOriginalKey] = isOriginal
        if let value = mLink { dictionary[kTopicMLinkKey] = value }
        dictionary[kTopicIsLocalhostKey] = isLocalhost
        if let value = published { dictionary[kTopicPublishedKey] = value }
        if let value = title { dictionary[kTopicTitleKey] = value }
        if let value = commentCount { dictionary[kTopicCommentCountKey] = value }
        return dictionary
    }
    
}
