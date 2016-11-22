//
//  Request_Error.swift
//  Daker
//
//  Created by RHCT on 16/8/1.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct ServerResponseError: ErrorType {
    /// The domain used for creating all Alamofire errors.
    static let Domain = "com.rhct.DakerError"
    
    static let ImageDomain = "com.rhct.DakerImageError"
    
    static let MultipartFormDataEncodeDomain = "com.rhct.MultipartFormDataEncodeError"
    
    struct UserInfoKeys {
        static let ResponseKey = "ResponseKey"
        
        
        static let encodeDataFailKey = "encodeDataFailKey"
    }
}

public class RequestError {
    var errorDomain: String?//错误域
    var statusCode: Int!    //状态码
    var errorDesc: String?  //错误描述
    
    var request: NSURLRequest?//请求信息
    var response: NSHTTPURLResponse?//返回信息
    
    var errors: [ErrorItem]?
    
    init(error: NSError) {
        errorDomain = error.domain
        statusCode = error.code
        
        var desc:String?
        if error.domain == NSURLErrorDomain {//系统domain
            
            switch error.code {
            case NSURLErrorNotConnectedToInternet/*-1009*/, NSURLErrorNetworkConnectionLost/*-1005*/:
                desc = G.AlertMessage.notConnectedToInternetDesc.rawValue
            case NSURLErrorCannotConnectToHost/*-1004*/, NSURLErrorCannotFindHost/*-1003*/:
                desc = G.AlertMessage.cannotConnectToHostDesc.rawValue
            case NSURLErrorTimedOut/*-1001*/:
                desc = G.AlertMessage.timedOutDesc.rawValue
            default:
                desc = G.AlertMessage.unKnowErrorDesc.rawValue
            }
        } else if error.domain == Alamofire.Error.Domain {//Alamofire domain
            #if APPSTORE
                desc = G.AlertMessage.unKnowErrorDesc.rawValue
            #else
                desc = ""
                switch error.code {
                case Error.Code.InputStreamReadFailed.rawValue:
                    desc = "输入流读取错误"
                case Error.Code.OutputStreamWriteFailed.rawValue:
                    desc = "输出流写入错误"
                case Error.Code.ContentTypeValidationFailed.rawValue:
                    desc = "ContentType 验证失败"
                case Error.Code.StatusCodeValidationFailed.rawValue:
                    desc = "状态码验证失败"
                case Error.Code.DataSerializationFailed.rawValue:
                    desc = "数据序列化失败"
                case Error.Code.StringSerializationFailed.rawValue:
                    desc = "字符串序列化失败"
                case Error.Code.JSONSerializationFailed.rawValue:
                    desc = "json序列化失败"
                case Error.Code.PropertyListSerializationFailed.rawValue:
                    desc = "plist序列化失败"
                default:
                    break
                }
                
                desc = desc! + "错误原因：\(error.userInfo[NSLocalizedFailureReasonErrorKey])"
            #endif
            
        } else if error.domain == ServerResponseError.Domain {//响应 statuscode
            guard let code = HTTPStatusCode(rawValue: error.code) else {
                return
            }
            errors = error.userInfo[ServerResponseError.UserInfoKeys.ResponseKey as NSObject] as? [ErrorItem]
            var errDesc: String?
            if let es = errors where es.count > 0 {
                if let errDetail = es[0].error where errDetail.count > 0 {
                    errDesc = errDetail[0]
                }
            }
            switch code {
            case .BadRequest:
                desc = errDesc ?? G.AlertMessage.unKnowErrorDesc.rawValue
            case .Forbidden:
                if G.userIsLogin {//用户已登录
                    desc = G.AlertMessage.loginOutOfDateDesc.rawValue
                } else {
                    desc = G.AlertMessage.noLoginUserDesc.rawValue
                }
            case .MethodNotAllowed:
                #if APPSTORE
                    desc = G.AlertMessage.unKnowErrorDesc.rawValue
                #else
                    desc = "http请求方法不被允许"
                #endif
            default:
                desc = errDesc
                break
            }
        } else if error.domain == ServerResponseError.ImageDomain {
            desc = G.AlertMessage.unKnowErrorDesc.rawValue
        } else if error.domain == ServerResponseError.MultipartFormDataEncodeDomain {
            #if APPSTORE
                desc = "数据编码出错了"
            #else
                desc = G.AlertMessage.unKnowErrorDesc.rawValue
            #endif
        } else {
            desc = G.AlertMessage.unKnowErrorDesc.rawValue
        }
        errorDesc = desc
    }
    
    //MARK: -- 处理服务器返回的错误
    class func serverErrorHandle(json: AnyObject) -> [ErrorItem]? {
        let ejson = SwiftyJSON.JSON(json)
        let tmp = ejson["errors"].arrayValue
        
        guard tmp.count > 0 else {
            return nil
        }
        
        var errors = [ErrorItem]()
        
        for errorItem in tmp {
            let item = ErrorItem(json:errorItem)
            
            if item.error != nil {
                errors.append(item)
            }
        }
        
        return errors
    }
}

//MARK: - 服务器错误 对象
public class ErrorItem{
    var type: String?
    var error: [String]?
    
    init(json:SwiftyJSON.JSON) {
        self.type = json["type"].stringValue
        
        let tmp = json["error"].arrayValue
        guard tmp.count > 0 else {
            return
        }

        self.error = [String]()
        for e in tmp {
            self.error!.append(e.stringValue)
        }
    }
}
