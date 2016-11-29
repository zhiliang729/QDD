//
//  RequestError.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import HTTPStatusCodes

extension AFError {
    public static let Domain = "org.alamofire.aferror.domain"
}

class ErrorItem {
    var type: String
    var error: [String] = []
    
    init?(json: JSON) {
        
        if let tmp = json["error"].array, tmp.count > 0 {
            type = json["type"].stringValue
            
            for e in tmp {
                error.append(e.stringValue)
            }
        } else {
            return nil
        }
    }
    
    class func serverErrorHandle(data: Data?) -> [ErrorItem]? {
        
        guard let data = data else {
            return nil
        }
        
        let json = JSON(data: data)
        
        if let tmp = json["errors"].array, tmp.count > 0 {
            var errors = [ErrorItem]()
            
            for item in tmp {
                if let err = ErrorItem(json: item) {
                    errors.append(err)
                }
            }
            
            if errors.count > 0 {
                return errors
            } else {
                return nil
            }
        }
        
        return nil
    }
}

class RequestError {
    var domain: String!    //错误域
    var statusCode: Int?   //状态码
    var desc: String?      //错误描述
    
    var debugDesc: String? //debugDesc
    
    var errors: [ErrorItem]?//服务器返回错误详情
    
    var request: URLRequest?//request
    var response: HTTPURLResponse?//response
    
    init(error: Error, data: Data?, alert: Bool = true) {
        
        if let err = error as? AFError {
            domain = AFError.Domain
            statusCode = err.responseCode
            debugDesc = err.localizedDescription
            
            switch err {
            case .responseValidationFailed:
                
                if let code = statusCode {
                    if let httpcode = HTTPStatusCode(rawValue: code) {
                        switch httpcode {
                        case .badRequest:
                            desc = AlertMessage.Client.ClientError
                            
                        case .forbidden:
                            if G.userIsLogin {//用户已经登录
                                desc = AlertMessage.Login.OutOfDate
                            } else {
                                desc = AlertMessage.Login.NoUser
                            }
                            
                        case let c where c.isClientError:
                            //desc = AlertMessage.Client.ClientError//不需要报给用户
                            desc = AlertMessage.UnKnown.UnKnowError
                            
                        case let c where c.isServerError:
                            desc = AlertMessage.Server.ServerError
                            
                        default:
                            desc = AlertMessage.UnKnown.UnKnowError
                        }
                    } else {
                        desc = AlertMessage.UnKnown.UnKnowError
                    }
                } else {
                    desc = AlertMessage.UnKnown.UnKnowError
                }
                
                errors = ErrorItem.serverErrorHandle(data: data)
            default:
                desc = AlertMessage.UnKnown.UnKnowError
            }
        } else {
            domain = (error as NSError).domain
            statusCode = (error as NSError).code
            
            debugDesc = (error as NSError).localizedDescription
            
            if (error as NSError).domain == NSURLErrorDomain {
                switch (error as NSError).code {
                case NSURLErrorNotConnectedToInternet/*-1009*/,
                NSURLErrorNetworkConnectionLost/*-1005*/:
                    desc = AlertMessage.Internet.NotConnectedToInternet
                case NSURLErrorCannotConnectToHost/*-1004*/,
                NSURLErrorCannotFindHost/*-1003*/:
                    desc = AlertMessage.Internet.NotConnectToHost
                case NSURLErrorTimedOut/*-1001*/:
                    desc = AlertMessage.Internet.TimedOutDesc
                default:
                    desc = AlertMessage.UnKnown.UnKnowError
                }
            } else {
                desc = AlertMessage.UnKnown.UnKnowError
            }
        }
        
        if alert {
            G.showMessage(desc)
        }
        
        if G.ShowHTTPError {
            #if DEBUG
                G.logger.debug(self.debugDesc)
            #else
            #endif
        }
    }
}

