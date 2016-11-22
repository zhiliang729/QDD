//
//  AccountServiceHandler.swift
//  Daker
//
//  Created by RHCT on 16/7/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class AccountServiceHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kAccountServiceHandlerUserKey: String = "user"
    
    
    // MARK: Properties
    var user: User?
    
    
    /**
     Initates the class based on the JSON that was passed.
     - parameter json: JSON object from SwiftyJSON.
     - returns: An initalized instance of the class.
     */
    override init(json: JSON) {
        super.init(json: json)
        //FIXME: - 此处视正式接口替换
        //        user = User(json: json[kAccountServiceHandlerUserKey])
        
        user = User(json: json)
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
        user <- map[kAccountServiceHandlerUserKey]
        
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    override func dictionaryRepresentation() -> [String : AnyObject ] {
        var dictionary: [String : AnyObject ] = super.dictionaryRepresentation()
        if user != nil {
            dictionary.updateValue(user!.dictionaryRepresentation(), forKey: kAccountServiceHandlerUserKey)
        }
        
        return dictionary
    }
    
}
