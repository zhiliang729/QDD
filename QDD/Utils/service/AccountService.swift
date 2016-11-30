//
//  AccountService.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire


class AccountService {
    
    //MARK: - 1. 申请验证码
    @discardableResult
    class func verifyCode(mobNum: String, captcha: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.verifyCode(paras: ["mobile_num": mobNum, "captcha": captcha]), success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 2.检查验证码是否正确
    @discardableResult
    class func check(regCode: String, mobNum: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.checkRegistCode(paras: ["mobile_num": mobNum, "regist_code": regCode]), success: { (_, json) in
            let checked = json["checked"].boolValue
            success?(checked)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 3. 用户注册
    @discardableResult
    class func signUp(mobNum: String, regCode: String, pwd: String, username: String, sex: Sex, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.signUp(paras: ["mobile_num": mobNum, "regist_code": regCode, "password": pwd, "username": username, "sex": sex.rawValue]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 4. 用户手机登录
    @discardableResult
    class func login(account: String, pwd: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.signUp(paras: ["account": account, "password": pwd]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 5.检查手机号是否注册
    @discardableResult
    class func check(mobNum: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.checkMobileNum(paras: ["mobile_num": mobNum]), success: { (_, json) in
            let available = json["available"].boolValue
            success?(available)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 6.检查用户是否重复
    @discardableResult
    class func check(username: String, success: ((Bool) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.checkUsername(paras: ["username": username]), success: { (_, json) in
            let available = json["available"].boolValue
            success?(available)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 7. 退出登录
    @discardableResult
    class func logout(success: (()-> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.logout, success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 8. 修改密码
    @discardableResult
    class func change(curPwd: String, newPwd: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.changePassword(paras: ["current_password": curPwd, "newer_password": newPwd, "repeat_password": newPwd]), success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 9.修改昵称
    @discardableResult
    class func change(name: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.changeUserName(paras: ["username": name]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 10.上传头像
    class func upload(avatar: Data, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.uploadImage(AccountAPI.avatar, multipartFormData: { (multipartFormData) in
            multipartFormData.append(avatar, withName: "avatar", fileName: "image.png", mimeType: "image/png")

        }, success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
    }
    
    
    //MARK: - 11.第三方登录
    @discardableResult
    class func login(type: AccountType, token: String, expired: String, openID: String?, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        var para = ["type": String(type.rawValue), "token": token, "token_expired": expired]
        
        if type == .wechat, let id = openID {
            para["open_id"] = id
        }
        
        let tmp = HttpRequest.request(AccountAPI.thirdPartyLogin(paras: para), success:{ (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 12.修改手机号码
    @discardableResult
    class func change(number: String, newNum: String, regCode: String, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.changeMobileNum(paras: ["current_mobile_num": number, "new_mobile_num": newNum, "regist_code": regCode]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 13.忘记密码
    @discardableResult
    class func forgetPwd(phoneNum: String, regCode: String, newPwd: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.changePassword(paras: ["mobile_num": phoneNum, "regist_code": regCode, "newer_password": newPwd, "repeat_password": newPwd]), success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    //MARK: - 14.申请修改密码验证码
    @discardableResult
    class func forgotPwdCode(phoneNum: String, captcha: String, success: (() -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.forgotPasswordCode(paras: ["mobile_num": phoneNum, "captcha": captcha]), success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 15.修改性别
    @discardableResult
    class func change(sex: Sex, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(AccountAPI.changeSex(paras: ["sex": sex.rawValue]), success: { (_, json) in
            let user = User(json: json)
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
}

