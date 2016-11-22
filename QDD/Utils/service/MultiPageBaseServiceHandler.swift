//
//  MultiPageBaseServiceHandler.swift
//  Daker
//
//  Created by RHCT on 16/8/24.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class MultiPageBaseServiceHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    let kMultiPageBaseServiceHandlerHasMoreKey: String = "has_more"
    let kMultiPageBaseServiceHandlerNextStartKey: String = "next_start"
    
    
    // MARK: Properties
    var hasMore: Bool = false
    var nextStart: Int?
    
    
    // MARK: SwiftyJSON Initalizers
    /**
     Initates the class based on the object
     - parameter object: The object of either Dictionary or Array kind that was passed.
     - returns: An initalized instance of the class.
     */
    convenience init(object: AnyObject) {
        self.init(json: JSON(object))
    }
    
    /**
     Initates the class based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    override init(json: JSON) {
        super.init(json: json)
        
        hasMore = json[kMultiPageBaseServiceHandlerHasMoreKey].boolValue
        nextStart = json[kMultiPageBaseServiceHandlerNextStartKey].int
        
    }
    
    // MARK: ObjectMapper Initalizers
    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    required init?(_ map: Map){
        super.init(map)
    }
    
    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    override func mapping(map: Map) {
        super.mapping(map)
        
        hasMore <- map[kMultiPageBaseServiceHandlerHasMoreKey]
        nextStart <- map[kMultiPageBaseServiceHandlerNextStartKey]
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    override func dictionaryRepresentation() -> [String : AnyObject ] {
        
        var dictionary: [String : AnyObject ] = super.dictionaryRepresentation()
        dictionary.updateValue(hasMore, forKey: kMultiPageBaseServiceHandlerHasMoreKey)
        if nextStart != nil {
            dictionary.updateValue(nextStart!, forKey: kMultiPageBaseServiceHandlerNextStartKey)
        }
        
        return dictionary
    }
    
}