//
//  User.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON

//MARK: enum 性别
public enum Sex: Int {
    case woman = 0
    case man = 1
    case unknown = -1
}

//MARK: enum 账号类型
public enum AccountType: Int {
    case phone = 0
    case weibo = 1
    case wechat = 2
    case qq = 3
    case none = 100
}

//MARK: class 用户
public class User: NSCoding {
    
    static let EncodeKey = "userinfo"
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    fileprivate let kUserAccountFromKey: String = "account_from"
    fileprivate let kUserLocationKey: String = "location"
    fileprivate let kUserInternalIdentifierKey: String = "id"
    fileprivate let kUserAvatarKey: String = "avatar"
    fileprivate let kUserMobileNumKey: String = "mobile_num"
    fileprivate let kUserDescriptionValueKey: String = "description"
    fileprivate let kUserBirthdayKey: String = "birthday"
    fileprivate let kUserUsernameKey: String = "username"
    fileprivate let kUserSexKey: String = "sex"
    
    
    // MARK: -- Properties
    public var accountFrom: AccountType = .phone
    public var location: String?
    public var userID: Int?
    public var avatar: String?
    public var mobileNum: String?
    public var userSummary: String?
    public var birthday: String?
    public var username: String?
    public var sex: Sex = .man
    
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
        accountFrom = AccountType(rawValue:json[kUserAccountFromKey].int ?? 100) ?? .none
        location = json[kUserLocationKey].string
        userID = json[kUserInternalIdentifierKey].int
        avatar = json[kUserAvatarKey].string
        mobileNum = json[kUserMobileNumKey].string
        userSummary = json[kUserDescriptionValueKey].string
        birthday = json[kUserBirthdayKey].string
        username = json[kUserUsernameKey].string
        sex = Sex(rawValue:json[kUserSexKey].int ?? 1) ?? .man
    }
    
    /**
     Generates description of the object in the form of a NSDictionary.
     - returns: A Key value pair containing all valid values in the object.
     */
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[kUserAccountFromKey] = accountFrom.rawValue
        if let value = location { dictionary[kUserLocationKey] = value }
        if let value = userID { dictionary[kUserInternalIdentifierKey] = value }
        if let value = avatar { dictionary[kUserAvatarKey] = value }
        if let value = mobileNum { dictionary[kUserMobileNumKey] = value }
        if let value = userSummary { dictionary[kUserDescriptionValueKey] = value }
        if let value = birthday { dictionary[kUserBirthdayKey] = value }
        if let value = username { dictionary[kUserUsernameKey] = value }
        dictionary[kUserSexKey] = sex.rawValue
        return dictionary
    }
    
    
    // MARK: -- NSCoding
    required public init?(coder aDecoder: NSCoder) {
        self.accountFrom = AccountType(rawValue: (aDecoder.decodeObject(forKey:kUserAccountFromKey) as? Int) ?? 100) ?? .none
        self.location = aDecoder.decodeObject(forKey: kUserLocationKey) as? String
        self.userID = aDecoder.decodeObject(forKey: kUserInternalIdentifierKey) as? Int
        self.avatar = aDecoder.decodeObject(forKey: kUserAvatarKey) as? String
        self.mobileNum = aDecoder.decodeObject(forKey: kUserMobileNumKey) as? String
        self.userSummary = aDecoder.decodeObject(forKey: kUserDescriptionValueKey) as? String
        self.birthday = aDecoder.decodeObject(forKey: kUserBirthdayKey) as? String
        self.username = aDecoder.decodeObject(forKey: kUserUsernameKey) as? String
        self.sex = Sex(rawValue: (aDecoder.decodeObject(forKey:kUserSexKey) as? Int) ?? 1) ?? .man
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(accountFrom.rawValue, forKey: kUserAccountFromKey)
        aCoder.encode(location, forKey: kUserLocationKey)
        aCoder.encode(userID, forKey: kUserInternalIdentifierKey)
        aCoder.encode(avatar, forKey: kUserAvatarKey)
        aCoder.encode(mobileNum, forKey: kUserMobileNumKey)
        aCoder.encode(userSummary, forKey: kUserDescriptionValueKey)
        aCoder.encode(birthday, forKey: kUserBirthdayKey)
        aCoder.encode(username, forKey: kUserUsernameKey)
        aCoder.encode(sex.rawValue, forKey: kUserSexKey)
    }
    
    //MARK: -- 将当前用户信息保存
    class func synchronizeCurrentUserInfo() {
        let infoData = NSMutableData(capacity: 0)
        let archiver = NSKeyedArchiver(forWritingWith: infoData!)
        if let user = G.shared.user {
            archiver.encode(user, forKey: EncodeKey)
        }
        archiver.finishEncoding()
        
        UserDefaults.standard.set(infoData, forKey: G.UserDefaultKey.currentUserInfo.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: -- 取消第三方授权
    class func cancelAuthorize() {
        //取消第三方分享授权
        ShareSDK.cancelAuthorize(.typeQQ)
        ShareSDK.cancelAuthorize(.subTypeQQFriend)
        ShareSDK.cancelAuthorize(.subTypeQZone)
        
        ShareSDK.cancelAuthorize(.typeWechat)
        ShareSDK.cancelAuthorize(.subTypeWechatSession)
        ShareSDK.cancelAuthorize(.subTypeWechatTimeline)
        
        ShareSDK.cancelAuthorize(.typeSinaWeibo)
    }
    
    //MARK: -- 清除当前用户信息
    class func clearCurrentUserInfo() {
        //清除cookie
        G.clearSysCookies()
        
        //userDefault 保存状态
        UserDefaults.standard.set(nil, forKey: G.UserDefaultKey.currentUserInfo.rawValue)
        UserDefaults.standard.synchronize()
        
        //发送退出登录消息
        NotificationCenter.default.post(name: NSNotification.Name.User.DidLogout, object: nil)
    }
    
    //MARK: -- 配置当前用户信息 (只在启动时调用，只调用一次)
    class func configCurrentUserInfo() {
        let data = UserDefaults.standard.object(forKey: G.UserDefaultKey.currentUserInfo.rawValue)
        if let userData = data as? NSData {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: userData as Data)
            guard let user = unarchiver.decodeObject(forKey: EncodeKey) as? User else {
                return
            }
            G.shared.user = user
        } else {
            G.shared.user = nil
        }
    }
}

