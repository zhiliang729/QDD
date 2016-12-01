//
//  SplashScreen.swift
//
//  Created by RHCT on 2016/12/1
//  Copyright (c) RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftDate
import Kingfisher

public class SplashScreen: NSCoding {
    
    public static let CacheKey = "com.hothuati.splashscreenkey"
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private let kSplashScreenStartTimeKey: String = "start_time"
    private let kSplashScreenEndTimeKey: String = "end_time"
    private let kSplashScreenImageUrlKey: String = "image_url"
    
    // MARK: Properties
    public var startTime: String?
    public var endTime: String?
    public var imageUrl: String?
    
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
        startTime = json[kSplashScreenStartTimeKey].string
        endTime = json[kSplashScreenEndTimeKey].string
        imageUrl = json[kSplashScreenImageUrlKey].string
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = startTime { dictionary[kSplashScreenStartTimeKey] = value }
        if let value = endTime { dictionary[kSplashScreenEndTimeKey] = value }
        if let value = imageUrl { dictionary[kSplashScreenImageUrlKey] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.startTime = aDecoder.decodeObject(forKey: kSplashScreenStartTimeKey) as? String
        self.endTime = aDecoder.decodeObject(forKey: kSplashScreenEndTimeKey) as? String
        self.imageUrl = aDecoder.decodeObject(forKey: kSplashScreenImageUrlKey) as? String
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(startTime, forKey: kSplashScreenStartTimeKey)
        aCoder.encode(endTime, forKey: kSplashScreenEndTimeKey)
        aCoder.encode(imageUrl, forKey: kSplashScreenImageUrlKey)
    }
    
    //MARK: - 缓存数据
    public class func save(screen: SplashScreen) {
        let data = NSKeyedArchiver.archivedData(withRootObject: screen)
        
        UserDefaults.standard.set(data, forKey: UserDefaults.Key.SplashScreen)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: 提取有效数据
    public class func validScreen() -> SplashScreen? {
        if let data = UserDefaults.standard.object(forKey: UserDefaults.Key.SplashScreen) as? Data, let screen = NSKeyedUnarchiver.unarchiveObject(with: data) as? SplashScreen {
            
            //清除
            let clearUserDefaults = {
                UserDefaults.standard.set(nil, forKey: UserDefaults.Key.SplashScreen)
                UserDefaults.standard.synchronize()
            }
            
            let today = Date()
            
            guard let startDate = screen.startTime?.date, let endDate = screen.endTime?.date else {
                
                //缓存格式有问题，清除
                clearUserDefaults()
                return nil
            }
            
            if today.isAfter(date: startDate, orEqual: true, in: nil, granularity: .second) && today.isBefore(date: endDate, granularity: .second) {//在日期之内
                return screen
            } else {
                
                //已过期，清除
                ImageCache.default.removeImage(forKey: CacheKey)
                clearUserDefaults()
            }
        }

        return nil
    }
    
    //MARK: 删除数据
    public class func clearScreen() {
        if validScreen() != nil {
            ImageCache.default.removeImage(forKey: CacheKey)
        }
        
        UserDefaults.standard.set(nil, forKey: UserDefaults.Key.SplashScreen)
        UserDefaults.standard.synchronize()
    }
}
