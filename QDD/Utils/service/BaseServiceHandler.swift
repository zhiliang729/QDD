//
//  BaseServiceHandler.swift
//  Daker
//
//  Created by RHCT on 16/8/1.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

class BaseServiceHandler: NSObject, Mappable {
    var request: NSURLRequest?//请求信息
    var response: NSHTTPURLResponse?//响应信息
    
    
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
    init(json: JSON) {
    }
    
    // MARK: ObjectMapper Initalizers
    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    required init?(_ map: Map){
    }
    
    /**
     Map a JSON object to this class using ObjectMapper
     - parameter map: A mapping from ObjectMapper
     */
    func mapping(map: Map) {
    }
    
    func dictionaryRepresentation() -> [String : AnyObject ] {
        return [ : ]
    }
}
