//
//  AccountService.swift
//  Daker
//
//  Created by RHCT on 16/7/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


enum ThirdLoginType: String {
    case phone = "0"
    case weibo = "1"
    case weChat = "2"
    case qq = "3"
}


class AccountService {
    //MARK: - 1. 申请验证码
    class func getVerifyCode(mobileNumber: String, captcha: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequst.post(Daker.verifyCode.routeUrl, parameters: ["mobile_num": mobileNumber, "captcha": captcha], onSuccess: { (res, json) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 2.检查验证码是否正确
    class func check(registCode: String, mobileNum: String, success: ((checked: Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequst.get(Daker.checkRegistCode.routeUrl, parameters: ["mobile_num": mobileNum, "regist_code": registCode], onSuccess: { (response, json) in
            let result = json["checked"].boolValue
            success?(checked: result)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 3. 用户注册
    class func signUp(mobileNum: String, registCode: String, password: String, username: String, sex: Sex, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.signUp.routeUrl, parameters: ["mobile_num": mobileNum, "regist_code": registCode, "password": password, "username": username, "sex": String(sex.rawValue)], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 4. 用户手机登录
    class func login(accound: String, password: String, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.login.routeUrl, parameters: ["account": accound, "password": password], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            //            handler.request = res.request
            //            handler.response = res.response
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 5.检查手机号是否注册
    class func check(mobileNum: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequst.get(Daker.checkMobileNum.routeUrl, parameters: ["mobile_num": mobileNum], onSuccess: { (response, json) in
            let result = json["available"].boolValue
            success?(result)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 6.检查用户是否重复
    class func checkUser(name: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequst.get(Daker.checkUsername.routeUrl, parameters: ["username": name], onSuccess: { (response, json) in
            let result = json["available"].boolValue
            success?(result)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 7. 退出登录
    class func logout(success: (()-> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequst.get(Daker.logout.routeUrl, parameters: nil, onSuccess: { (response, json) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 8. 修改密码
    class func change(curPassword: String, newPassword: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.changePassword.routeUrl, parameters: ["current_password": curPassword, "newer_password": newPassword, "repeat_password": newPassword], onSuccess: { (res, json) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 9.修改昵称
    class func change(name: String, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.changeUserName.routeUrl, parameters: ["username": name], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 10.上传头像
    class func upload(avatar: NSData, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.uploadImage(.POST, url: Daker.avatar.routeUrl, multipartFormData: { (multipartFormData) in
            multipartFormData.appendBodyPart(data: avatar, name: "avatar", fileName: "icon.png", mimeType: "image/png")
            }, onSuccess: { (res, json) in
                let handler = AccountServiceHandler(json: json)
                success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 11.第三方登录
    class func login(type: ThirdLoginType, token: String, tokenExpired: String, openID: String?, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        var para = ["type": type.rawValue, "token": token, "token_expired": tokenExpired];
        if type == .weChat, let id = openID {
            para["open_id"] = id
        }
        
        HttpRequst.post(Daker.thirdPartyLogin.routeUrl, parameters: para, onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 12.修改手机号码
    class func change(number: String, newNum: String, registCode: String, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.changeMobileNum.routeUrl, parameters: ["current_mobile_num": number, "new_mobile_num": newNum, "regist_code": registCode], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 13.忘记密码
    class func forgetPassword(phoneNum: String, registCode: String, newPassword: String, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.forgotPassword.routeUrl, parameters: ["mobile_num": phoneNum, "regist_code": registCode, "newer_password": newPassword, "repeat_password": newPassword], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 14.申请修改密码验证码
    class func forgotPasswordCode(phoneNum: String, captcha: String, success: ((BaseServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.forgotPasswordCode.routeUrl, parameters: ["mobile_num": phoneNum, "captcha": captcha], onSuccess: { (res, json) in
            let handler = BaseServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 15.修改性别
    class func changeSex(sex: Sex, success: ((AccountServiceHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequst.post(Daker.changeSex.routeUrl, parameters: ["sex": "\(sex.rawValue)"], onSuccess: { (res, json) in
            let handler = AccountServiceHandler(json: json)
            success?(handler)
        }) { (error) in
            fail?(error)
        }
    }
}

