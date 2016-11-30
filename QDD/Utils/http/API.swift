//
//  API.swift
//  QDD
//
//  Created by RHCT on 2016/11/28.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire

protocol APIRequestProtocol: URLRequestConvertible {
    
    //根url
    static var baseURL: String { get }
    
    //path
    var path: String { get }
    
    //method
    var method: HTTPMethod { get }
    
    var alert: Bool { get }
}

extension APIRequestProtocol {
    static var baseURL: String {
        return G.platformBaseUrl
    }
}


enum UserAPI: APIRequestProtocol {
    case userInfo(id: Int)                                      //1. 获取用户信息
    case userComments(id: Int, paras: Parameters)               //2. 获取用户评论
    case userTopic(id: Int, paras: Parameters)                  //3. 获取用户收藏的文章
    case userSubNode(id: Int, paras: Parameters)                //4. 获取用户订阅的收藏夹
    case userCreateNode(id: Int)                                //5. 获取用户创建的收藏夹
    
    internal var path: String {
        switch self {
        case .userInfo(let id):                     //1. 获取用户信息
            return "/user/\(id)/"
        case .userComments(let id, _):                 //2. 获取用户评论
            return "/user/\(id)/comments/"
        case .userTopic(let id, _):                    //3. 获取用户收藏的文章
            return "/user/\(id)/favorites/"
        case .userSubNode(let id, _):                  //4. 获取用户订阅的收藏夹
            return "/user/\(id)/sub_nodes/"
        case .userCreateNode(let id):               //5. 获取用户创建的 node
            return "/user/\(id)/nodes/"
        }
        
    }
    
    internal var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    internal var alert: Bool {
        switch self {
        default:
            return true
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try UserAPI.baseURL.asURL()
        
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method, headers: G.httpHeaders())
        
        switch self {
        case .userComments(_, let paras),
             .userTopic(_, let paras),
             .userSubNode(_, let paras):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: paras)
        default:
            break
        }
        
        return urlRequest
    }
}


enum AccountAPI: APIRequestProtocol {
    case verifyCode(paras: Parameters)                  //1. 申请验证码
    case checkRegistCode(paras: Parameters)             //2. 检查验证码是否正确
    case signUp(paras: Parameters)                      //3. 用户注册
    case login(paras: Parameters)                       //4. 登录
    case checkMobileNum(paras: Parameters)              //5. 检查手机号是否注册
    case checkUsername(paras: Parameters)               //6. 检查用户是否重复
    case logout                                         //7. 退出登录
    case changePassword(paras: Parameters)              //8. 修改密码
    case changeUserName(paras: Parameters)              //9. 修改昵称
    case avatar                                         //10.上传头像
    case thirdPartyLogin(paras: Parameters)             //11.使用第三方登录
    case changeMobileNum(paras: Parameters)             //12.修改手机号码
    case forgotPassword(paras: Parameters)              //13.忘记密码
    case forgotPasswordCode(paras: Parameters)          //14.申请修改密码验证码
    case changeSex(paras: Parameters)                   //15.修改性别
    
    internal var path: String {
        switch self {
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
        }
    }
    
    internal var method: HTTPMethod {
        switch self {
        case .checkRegistCode, .checkMobileNum, .checkUsername, .logout:
            return .get
        default:
            return .post
        }
    }
    
    internal var alert: Bool {
        switch self {
        default:
            return true
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try AccountAPI.baseURL.asURL()
        
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method, headers: G.httpHeaders())
        
        switch self {
        case .verifyCode(let paras),
             .checkRegistCode(let paras),
             .signUp(let paras),
             .login(let paras),
             .checkMobileNum(let paras),
             .checkUsername(let paras),
             
             .changePassword(let paras),
             .changeUserName(let paras),
             
             .thirdPartyLogin(let paras),
             .changeMobileNum(let paras),
             .forgotPassword(let paras),
             .forgotPasswordCode(let paras),
             .changeSex(let paras):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: paras)
        default:
            break
        }
        
        return urlRequest
    }
}


enum MISCAPI: APIRequestProtocol {
    case checkVersion                       //1.获取是否有新版本
    case splashScreen                       //2.获取闪屏图片
    case banner(paras: Parameters)          //3.获取banner
    case deviceActivating                   //4.设备激活
    case graphicCaptcha                     //5.图形验证码
    case settings                           //8.获取 app 的后台配置信息 是否显示广告等
    case imageUpload(paras: Parameters)     //15.上传图片
    
    internal var path: String {
        switch self {
        case .checkVersion:                                     //1.获取是否有新版本
            return "/check_version/"
        case .splashScreen:                                      //2.获取闪屏图片
            return "/flash_screen/?wh=4_3"
        case .banner:                                           //3.获取banner
            return "/banner/"
        case .deviceActivating:                                 //4.设备激活
            return "/device_activating/"
        case .graphicCaptcha:                                   //5. 图形验证码
            return "/captcha/"
        case .settings:                                         //8.获取 app 的后台配置信息 是否显示广告等
            return "/settings/"
        case .imageUpload:                                      //15.上传图片
            return "/image_upload/"
        }
        
    }
    
    internal var method: HTTPMethod {
        switch self {
        case .deviceActivating, .imageUpload:
            return .post
        default:
            return .get
        }
    }
    
    internal var alert: Bool {
        switch self {
        default:
            return true
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try MISCAPI.baseURL.asURL()
        
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method, headers: G.httpHeaders())
        
        switch self {
        case .banner(let paras),
             .imageUpload(let paras):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: paras)
        default:
            break
        }
        
        return urlRequest
    }
}




