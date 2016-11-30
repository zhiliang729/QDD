//
//  CurrentUserService.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire


class CurrentUserService {
    
    //MARK: - 3.获取我的信息
    @discardableResult
    class func userInfo(success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.userInfo, success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 4. 修改生日
    @discardableResult
    class func change(birthday: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.changeBirthday(paras: ["birthday": birthday]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 5.用户收到的通知
    @discardableResult
    class func notifications(start: Int, success: ((NotisHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.notifications(paras: ["page": start]), success: { (res, json) in
            let handler = NotisHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 6.用户状态是否有新通知等
    @discardableResult
    class func status(success: ((StatusHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.status, success: { (_, json) in
            let handler = StatusHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 7. 上传国家 省 市
    @discardableResult
    class func change(location: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.location(paras: ["location": location]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 9. 修改描述 (签名)
    @discardableResult
    class func change(desc: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(CurrentUserAPI.desc(paras: ["description": desc]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
}

