//
//  Noti.swift
//
//  Created by RHCT on 2016/11/30
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class Noti {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kNotiContentKey: String = "content"
    private let kNotiInternalIdentifierKey: String = "id"
    private let kNotiUnReadKey: String = "un_read"
    private let kNotiIdxKey: String = "idx"
    
    // MARK: Properties
    public var content: String?
    public var id: Int?
    public var unRead: Bool = false
    public var idx: Int?
    
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
        content = json[kNotiContentKey].string
        id = json[kNotiInternalIdentifierKey].int
        unRead = json[kNotiUnReadKey].boolValue
        idx = json[kNotiIdxKey].int
    }
}
