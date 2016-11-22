//
//  HttpRequst.swift
//  ios
//
//  Created by 刘强 on 15/8/13.
//  Copyright (c) 2015年 ecangwang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

/// HTTP 请求
public class HttpRequst {
    
    //MARK: - http head
    //参见 Alamofire issue #1342 #1372
    private static var httpHeaders: [String: String]? = {
        let headers = [
            "Accept-Language": "en;q=0.8,zh-Hans;q=0.5,zh-Hant;",
            "Accept-Encoding": "gzip;q=0.8,compress;",
            "User-Agent":G.globalUserAgent()
        ]
        return headers
    }()
    
    //MARK: - send
    private class func send(
        method: Alamofire.Method,
        url: String,
        parameters: [String: String]?,
        onSuccess: ((response: Alamofire.Response<AnyObject, NSError>, json: SwiftyJSON.JSON) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ) {
        
        let requestUrl = NSURLRequest(URL: NSURL(string: url)!)
        Alamofire.request(method, requestUrl, parameters: parameters, headers: httpHeaders)
            .responseJSON(completionHandler: { (res) in
                log(res)
                switch res.result {
                case .Success(let value):
                    if res.response?.statusCode >= 400 && res.response?.statusCode < 600 {
                        let errors = RequestError.serverErrorHandle(value)
                        
                        var info: [NSObject : AnyObject]?
                        
                        if let ers = errors {
                            info = [ServerResponseError.UserInfoKeys.ResponseKey: ers]
                        }
                        
                        let error = NSError(domain: ServerResponseError.Domain, code: res.response?.statusCode ?? 0, userInfo: info)
                        let requestError = RequestError(error: error)
                        requestError.request = res.request
                        requestError.response = res.response
                        onFail?(error: requestError)
                        return
                    }
                    
                    onSuccess?(response:res, json: JSON(value))
                case .Failure(let error):
                    let requestError = RequestError(error: error)
                    requestError.request = res.request
                    requestError.response = res.response
                    onFail?(error: requestError)
                }
            })
    }
    
    //MARK: - GET
    public class func get(
        url: String,
        parameters: [String: String]?,
        onSuccess: ((response: Alamofire.Response<AnyObject, NSError>, json: SwiftyJSON.JSON) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ){
        send(Alamofire.Method.GET, url: url, parameters: parameters, onSuccess: onSuccess, onFail: onFail)
    }
    
    //MARK: - POST
    public class func post(
        url: String,
        parameters: [String: String]?,
        onSuccess: ((response: Alamofire.Response<AnyObject, NSError>, json: SwiftyJSON.JSON) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ){
        send(Alamofire.Method.POST, url: url, parameters: parameters, onSuccess: onSuccess, onFail: onFail)
    }
    
    //MARK: - DELETE
    public class func delete(
        url: String,
        parameters: [String: String]?,
        onSuccess: ((response: Alamofire.Response<AnyObject, NSError>, json: SwiftyJSON.JSON) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ){
        send(.DELETE, url: url, parameters: parameters, onSuccess: onSuccess, onFail: onFail)
    }
    
    //MARK: - 上传图片
    public class func uploadImage(
        method: Alamofire.Method,
        url: String,
        multipartFormData: (MultipartFormData -> Void),
        onSuccess: ((response: Alamofire.Response<AnyObject, NSError>, json: SwiftyJSON.JSON) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ){
        
        Alamofire.upload(method, url, headers: httpHeaders, multipartFormData: multipartFormData, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold) { (result) in
            switch result {
            case .Success(let request, _, _):
                request.responseJSON(completionHandler: { (res) in
                    log(res)
                    switch res.result {
                    case .Success(let value):
                        if res.response?.statusCode >= 400 && res.response?.statusCode < 600 {
                            let errors = RequestError.serverErrorHandle(value)
                            
                            var info: [NSObject : AnyObject]?
                            
                            if let ers = errors {
                                info = [ServerResponseError.UserInfoKeys.ResponseKey: ers]
                            }
                            
                            let error = NSError(domain: ServerResponseError.Domain, code: res.response?.statusCode ?? 0, userInfo: info)
                            
                            let requestError = RequestError(error: error)
                            requestError.request = res.request
                            requestError.response = res.response
                            onFail?(error: requestError)
                            return
                        }
                        
                        onSuccess?(response:res, json: JSON(value))
                    case .Failure(let error):
                        let requestError = RequestError(error: error)
                        requestError.request = res.request
                        requestError.response = res.response
                        onFail?(error: requestError)
                    }
                })
            case .Failure(let error as NSError):
                let error = NSError(domain: ServerResponseError.MultipartFormDataEncodeDomain, code: error.code, userInfo: error.userInfo)
                let requestError = RequestError(error: error)
                onFail?(error: requestError)
            default:
                break
            }
        }
    }
    
    //MARK: - 下载图片
    public class func getImage(
        method: Alamofire.Method,
        url: String,
        parameters: [String: String]?,
        onSuccess: ((response: Alamofire.Response<UIImage, NSError>, image: UIImage) -> Void)?,
        onFail: ((error: RequestError) -> Void)? ){
        
        Request.addAcceptableImageContentTypes(["image/jpg"])
        
        let requestUrl = NSURLRequest(URL: NSURL(string: url)!)
        Alamofire.request(method, requestUrl, parameters: parameters, headers: httpHeaders)
            .responseImage(completionHandler: { (res) in
                logImage(res)
                switch res.result {
                case .Success(let value):
                    if res.response!.statusCode >= 400 && res.response!.statusCode < 600 {
                        
                        let error = NSError(domain: ServerResponseError.ImageDomain, code: res.response!.statusCode, userInfo: nil)
                        let requestError = RequestError(error: error)
                        requestError.request = res.request
                        requestError.response = res.response
                        onFail?(error: requestError)
                        return
                    }
                    
                    onSuccess?(response:res, image: value)
                case .Failure( let error):
                    let requestError = RequestError(error: error)
                    requestError.request = res.request
                    requestError.response = res.response
                    onFail?(error: requestError)
                }
            })
    }
    
    //MARK: - LOG
    class func logImage(res: Response<UIImage, NSError>) {
        #if DEBUG
            if G.ShowHTTPURL {
                G.logger.debug("\nHTTP   URL: \(res.request?.HTTPMethod) ---  \(res.request?.URL?.absoluteString)\n")
            }
            
            if G.ShowHTTPError {
                G.logger.debug("\nHTTP   ERROR:\(res.result.error?.description)\n")
            }
            
            if G.ShowHttpRespond {
                G.logger.debug("\nHTTP   RESPONSE:\(res.response?.description)\n")
            }
        #else
        #endif
    }
    
    class func log(res: Response<AnyObject, NSError>) {
    #if DEBUG
        if G.ShowHTTPURL {
            G.logger.debug("\nHTTP   URL: \(res.request?.HTTPMethod) ---  \(res.request?.URL?.absoluteString)\n")
        }
        
        if G.ShowHTTPError {
            G.logger.debug("\nHTTP   ERROR:\(res.result.error?.description)\n")
        }
        
        if G.ShowHttpRespond {
            G.logger.debug("\nHTTP   RESPONSE:\(res.response?.description)\n")
        }
    #else
    #endif
    }
}
