//
//  CurrentUserService.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


class CurrentUserService {
    
    //MARK: - 3.获取我的信息
    class func userInfo(success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.userInfo, success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 4. 修改生日
    class func change(birthday: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.changeBirthday(paras: ["birthday": birthday]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 5.用户收到的通知
    class func notifications(start: Int, success: ((NotisHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.notifications(paras: ["page": start]), success: { (res, json) in
            let handler = NotisHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 6.用户状态是否有新通知等
    class func status(success: ((StatusHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.status, success: { (_, json) in
            let handler = StatusHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 7. 上传国家 省 市
    class func change(location: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.location(paras: ["location": location]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 9. 修改描述 (签名)
    class func change(desc: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(CurrentUserAPI.desc(paras: ["description": desc]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
}

