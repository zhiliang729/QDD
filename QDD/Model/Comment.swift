//
//  Comment.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Comment {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kCommentContentKey: String = "content"
    private let kCommentLikeCountKey: String = "like_count"
    private let kCommentUserKey: String = "user"
    private let kCommentLikedKey: String = "liked"
    private let kCommentInternalIdentifierKey: String = "id"
    private let kCommentCreatedKey: String = "created"
    private let kCommentImagesKey: String = "images"
    
    // MARK: Properties
    public var content: String?
    public var likeCount: Int?
    public var user: User?
    public var liked: Bool = false
    public var id: Int?
    public var created: String?
    public var images: String?
    
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
        content = json[kCommentContentKey].string
        likeCount = json[kCommentLikeCountKey].int
        user = User(json: json[kCommentUserKey])
        liked = json[kCommentLikedKey].boolValue
        id = json[kCommentInternalIdentifierKey].int
        created = json[kCommentCreatedKey].string
        images = json[kCommentImagesKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = content { dictionary[kCommentContentKey] = value }
        if let value = likeCount { dictionary[kCommentLikeCountKey] = value }
        if let value = user { dictionary[kCommentUserKey] = value.dictionaryRepresentation() }
        dictionary[kCommentLikedKey] = liked
        if let value = id { dictionary[kCommentInternalIdentifierKey] = value }
        if let value = created { dictionary[kCommentCreatedKey] = value }
        if let value = images { dictionary[kCommentImagesKey] = value }
        return dictionary
    }
    
}
