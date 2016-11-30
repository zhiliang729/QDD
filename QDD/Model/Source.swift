//
//  Source.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Source {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kSourceDescriptionValueKey: String = "description"
    private let kSourceNameKey: String = "name"
    private let kSourceInternalIdentifierKey: String = "id"
    private let kSourceSourceAvatarKey: String = "source_avatar"
    
    // MARK: Properties
    public var desc: String?
    public var name: String?
    public var id: Int?
    public var sourceAvatar: String?
    
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
        desc = json[kSourceDescriptionValueKey].string
        name = json[kSourceNameKey].string
        id = json[kSourceInternalIdentifierKey].int
        sourceAvatar = json[kSourceSourceAvatarKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = desc { dictionary[kSourceDescriptionValueKey] = value }
        if let value = name { dictionary[kSourceNameKey] = value }
        if let value = id { dictionary[kSourceInternalIdentifierKey] = value }
        if let value = sourceAvatar { dictionary[kSourceSourceAvatarKey] = value }
        return dictionary
    }
    
}
