//
//  AccountService.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


class AccountService {
    //MARK: - 1. 申请验证码
    class func verifyCode(mobNum: String, captcha: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.verifyCode(paras: ["mobile_num": mobNum, "captcha": captcha]), success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
    }
    
    //MARK: - 2.检查验证码是否正确
    class func check(regCode: String, mobNum: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.checkRegistCode(paras: ["mobile_num": mobNum, "regist_code": regCode]), success: { (_, json) in
            let checked = json["checked"].boolValue
            success?(checked)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 3. 用户注册
    class func signUp(mobNum: String, regCode: String, pwd: String, username: String, sex: Sex, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.signUp(paras: ["mobile_num": mobNum, "regist_code": regCode, "password": pwd, "username": username, "sex": sex.rawValue]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 4. 用户手机登录
    class func login(account: String, pwd: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.signUp(paras: ["account": account, "password": pwd]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 5.检查手机号是否注册
    class func check(mobNum: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.checkMobileNum(paras: ["mobile_num": mobNum]), success: { (_, json) in
            let available = json["available"].boolValue
            success?(available)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 6.检查用户是否重复
    class func checkUser(name: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.checkUsername(paras: ["username": name]), success: { (_, json) in
            let available = json["available"].boolValue
            success?(available)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 7. 退出登录
    class func logout(success: (()-> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.logout, success: { (_, _) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 8. 修改密码
    class func change(curPwd: String, newPwd: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.changePassword(paras: ["current_password": curPwd, "newer_password": newPwd, "repeat_password": newPwd]), success: { (_, _) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 9.修改昵称
    class func change(name: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(AccountAPI.changeUserName(paras: ["username": name]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 10.上传头像
    class func upload(avatar: Data, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.uploadImage(AccountAPI.avatar, multipartFormData: { (multipartFormData) in
            multipartFormData.append(avatar, withName: "avatar", fileName: "image.png", mimeType: "image/png")

        }, success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 11.第三方登录
    class func login(type: AccountType, token: String, expired: String, openID: String?, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        var para = ["type": String(type.rawValue), "token": token, "token_expired": expired]
        
        if type == .wechat, let id = openID {
            para["open_id"] = id
        }
        
        HttpRequest.request(AccountAPI.thirdPartyLogin(paras: para), success:{ (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 12.修改手机号码
    class func change(number: String, newNum: String, regCode: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(AccountAPI.changeMobileNum(paras: ["current_mobile_num": number, "new_mobile_num": newNum, "regist_code": regCode]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 13.忘记密码
    class func forgetPwd(phoneNum: String, regCode: String, newPwd: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.request(AccountAPI.changePassword(paras: ["mobile_num": phoneNum, "regist_code": regCode, "newer_password": newPwd, "repeat_password": newPwd]), success: { (_, _) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 14.申请修改密码验证码
    class func forgotPwdCode(phoneNum: String, captcha: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.forgotPasswordCode(paras: ["mobile_num": phoneNum, "captcha": captcha]), success: { (_, _) in
            success?()
        }) { (error) in
            fail?(error)
        }
    }
    
    //MARK: - 15.修改性别
    class func changeSex(sex: Sex, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(AccountAPI.changeSex(paras: ["sex": sex.rawValue]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }) { (error) in
            fail?(error)
        }
    }
}

