//
//  Banner.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class Banner {
    
    public enum Area: Int {
        case Square = 1//广场
        case Sub = 2//订阅
        case Discovery = 3//发现
    }
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kBannerBannerTypeKey: String = "banner_type"
    private let kBannerLinkKey: String = "link"
    private let kBannerInternalIdentifierKey: String = "id"
    private let kBannerImageKey: String = "image"
    
    // MARK: Properties
    public var bannerType: Int?
    public var link: String?
    public var id: Int?
    public var image: String?
    
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
        bannerType = json[kBannerBannerTypeKey].int
        link = json[kBannerLinkKey].string
        id = json[kBannerInternalIdentifierKey].int
        image = json[kBannerImageKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = bannerType { dictionary[kBannerBannerTypeKey] = value }
        if let value = link { dictionary[kBannerLinkKey] = value }
        if let value = id { dictionary[kBannerInternalIdentifierKey] = value }
        if let value = image { dictionary[kBannerImageKey] = value }
        return dictionary
    }
    
}
