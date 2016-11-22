//
//  API.swift
//  Daker
//
//  Created by RHCT on 16/7/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire

protocol APIRequestProtocol {
    static var baseURL: String { get }
    var path: String { get }
}

extension APIRequestProtocol {
    var routeUrl: String {//获取路径
        return Self.baseURL + path
    }
}

//MARK: - enum Daker
enum Daker {
    
    //MARK: -- ACCOUNT
    case verifyCode                 //1. 申请验证码
    case checkRegistCode            //2. 检查验证码是否正确
    case signUp                     //3. 用户注册
    case login                      //4. 登录
    case checkMobileNum             //5. 检查手机号是否注册
    case checkUsername              //6. 检查用户是否重复
    case logout                     //7. 退出登录
    case changePassword             //8. 修改密码
    case changeUserName             //9. 修改昵称
    case avatar                     //10.上传头像
    case thirdPartyLogin            //11.使用第三方登录
    case changeMobileNum            //12.修改手机号码
    case forgotPassword             //13.忘记密码
    case forgotPasswordCode         //14.申请修改密码验证码
    case changeSex                  //15.修改性别
    
    
    
    //MARK: -- MISC
    case pictureCaptcha             //5. 图形验证码
    
    
    //MARK: -- USER
    case userInfo(id: Int)                   //1. 获取用户信息
    case userComments(id: Int)               //2. 获取用户评论
    case userTopic(id: Int)                  //3. 获取用户收藏的文章
    case userSubNode(id: Int)                //4. 获取用户订阅的收藏夹
    case userCreateNode(id: Int)             //5. 获取用户创建的收藏夹
    case userContriTopic(id: Int)            //7. 获取用户的投稿列表
    
    case DEFAULT//啥也不是
}

extension Daker: APIRequestProtocol {
    static var baseURL: String { return G.platformBaseUrl }
    
    var path: String {
        switch self {
        
        //MARK: -- ACCOUNT
        case .verifyCode:                           //1. 申请验证码
            return "/account/verify_code/"
        case .checkRegistCode:                      //2. 检查验证码是否正确
            return "/account/check_regist_code/"
        case .signUp:                               //3. 用户注册
            return "/account/signup/"
        case .login:                                //4. 登录
            return "/account/login/"
        case .checkMobileNum:                       //5. 检查手机号是否注册
            return "/account/check_mobile_num/"
        case .checkUsername:                        //6. 检查用户是否重复
            return "/account/check_username/"
        case .logout:                               //7. 退出登录
            return "/account/logout/"
        case .changePassword:                       //8. 修改密码
            return "/account/change_password/"
        case .changeUserName:                       //9. 修改昵称
            return "/account/change_username/"
        case .avatar:                               //10.上传头像
            return "/account/avatar/"
        case .thirdPartyLogin:                      //11.使用第三方登录
            return "/account/third_party/login/"
        case .changeMobileNum:                      //12.修改手机号码
            return "/account/change_mobile_num/"
        case .forgotPassword:                       //13.忘记密码
            return "/account/forgot_password/"
        case .forgotPasswordCode:                   //14.申请修改密码验证码
            return "/account/forgot_password_code/"
        case .changeSex:                            //15.修改性别
            return "/account/change_sex/"
            
        //MARK: -- MISC
        case .pictureCaptcha:                       //5. 图形验证码
            return "/captcha/"
            
        //MARK: -- USER
        case .userInfo(let id):                     //1. 获取用户信息
            return "/user/\(id)/"
        case .userComments(let id):                 //2. 获取用户评论
            return "/user/\(id)/comments/"
        case .userTopic(let id):                    //3. 获取用户收藏的文章
            return "/user/\(id)/favorites/"
        case .userSubNode(let id):                  //4. 获取用户订阅的收藏夹
            return "/user/\(id)/sub_nodes/"
        case .userCreateNode(let id):               //5. 获取用户创建的 node
            return "/user/\(id)/nodes/"
        case .userContriTopic(let id):              //7. 获取用户的投稿列表
            return "/user/\(id)/contributions/"
        default:
            return "/"
        }
    }
}

