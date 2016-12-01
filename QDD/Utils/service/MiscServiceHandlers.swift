//
//  MiscServiceHandlers.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class VersionHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kVersionHandlerDescriptionValueKey: String = "description"
    private let kVersionHandlerVersionKey: String = "version"
    private let kVersionHandlerEnforcementKey: String = "enforcement"
    private let kVersionHandlerDeviceKey: String = "device"
    private let kVersionHandlerNewVersionKey: String = "new_version"
    private let kVersionHandlerUrlKey: String = "url"
    
    // MARK: Properties
    public var desc: String?
    public var version: String?
    public var enforcement: Bool = false
    public var device: String?
    public var newVersion: Bool = false
    public var url: String?
    
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
        
        desc = json[kVersionHandlerDescriptionValueKey].string
        version = json[kVersionHandlerVersionKey].string
        enforcement = json[kVersionHandlerEnforcementKey].boolValue
        device = json[kVersionHandlerDeviceKey].string
        newVersion = json[kVersionHandlerNewVersionKey].boolValue
        url = json[kVersionHandlerUrlKey].string
    }
}


public class BannerHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kBannerHandlerBannersKey: String = "banners"
    
    // MARK: Properties
    public var banners: [Banner]?
    
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
        
        if let items = json[kBannerHandlerBannersKey].array { banners = items.map { Banner(json: $0) } }
    }
}

public class SettingsHandler: BaseServiceHandler {
    
}

public class UploadImageHandler: BaseServiceHandler {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kUploadImageHandlerAttachKey: String = "attach"
    private let kUploadImageHandlerUrlKey: String = "url"
    
    // MARK: Properties
    public var attach: String?
    public var url: String?
    
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
        attach = json[kUploadImageHandlerAttachKey].string
        url = json[kUploadImageHandlerUrlKey].string
    }
}
