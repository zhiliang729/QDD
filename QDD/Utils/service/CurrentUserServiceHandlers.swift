//
//  CurrentUserServiceHandlers.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class NotisHandler: MultiPageBaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kNotiHandlerNotiKey: String = "notifications"
    
    // MARK: Properties
    public var notification: [Noti]?
    
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
    public override init(json: JSON) {
        super.init(json: json)
        
        if let items = json[kNotiHandlerNotiKey].array { notification = items.map { Noti(json: $0) } }
    }
    
}


public class StatusHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kStatusHandlerHasUnreadNotifiesKey: String = "has_unread_notifies"
    
    // MARK: Properties
    public var hasUnreadNotifies: Bool = false
    
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
    public override init(json: JSON) {
        super.init(json: json)
        
        hasUnreadNotifies = json[kStatusHandlerHasUnreadNotifiesKey].boolValue
    }
    
}




