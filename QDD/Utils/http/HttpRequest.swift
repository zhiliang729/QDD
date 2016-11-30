//
//  HttpRequest.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import AlamofireImage


class HttpRequest {
    
    @discardableResult
    class func request(_ req: APIRequestProtocol,
                       success: @escaping (DataResponse<Any>, JSON) -> Void,
                       fail: @escaping (RequestError) -> Void) -> DataRequest {
        let tmp = Alamofire.request(req)
            .validate()
            .responseJSON { (res) in
                log(res)
                
                switch res.result {
                case .success(let data):
                    success(res, JSON(data))
                case .failure(let error):
                    fail(RequestError(error: error, data: res.data, alert: req.alert))
                }
        }
        return tmp
    }
    
    class func uploadImage(_ req: APIRequestProtocol,
                           multipartFormData:@escaping ((MultipartFormData) -> Void),
                           success: @escaping (DataResponse<Any>, JSON) -> Void,
                           fail: @escaping (RequestError) -> Void) {
        upload(multipartFormData: multipartFormData,
               with: req,
               encodingCompletion: { (result) in
                switch result {
                case .success(let request, _, _):
                    request.validate()
                        .responseJSON(completionHandler: { (res) in
                            log(res)
                            
                            switch res.result {
                            case .success(let data):
                                success(res, JSON(data))
                            case .failure(let error):
                                fail(RequestError(error: error, data: res.data, alert: req.alert))
                            }
                        })
                case .failure(let error):
                    fail(RequestError(error: error, data: nil, alert: req.alert))
                }
        })
        
    }
    
    @discardableResult
    class func getImage(_ req: APIRequestProtocol,
                        success: @escaping (DataResponse<Image>, UIImage) -> Void,
                        fail: @escaping (RequestError) -> Void) -> DataRequest {
        
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        
        let tmp = Alamofire.request(req)
            .validate()
            .responseImage { (res) in
                logImage(res)
                
                switch res.result {
                case .success(let image):
                    success(res, image)
                case .failure(let error):
                    fail(RequestError(error: error, data: res.data, alert: req.alert))
                }
        }
        
        return tmp
    }
    
    //MARK: - LOG
    class func logImage(_ res: DataResponse<Image>) {
        #if DEBUG
            if G.ShowHTTPURL {
                G.logger.debug("\nHTTP   URL: \(res.request?.httpMethod) ---  \(res.request?.url?.absoluteString)")
            }
            
            if G.ShowHttpRespond {
                G.logger.debug("\nHTTP   RESPONSE:\(res.response?.description)\n")
            }
        #else
        #endif
    }
    
    class func log(_ res: DataResponse<Any>) {
        #if DEBUG
            if G.ShowHTTPURL {
                G.logger.debug("\nHTTP   URL: \(res.request?.httpMethod) ---  \(res.request?.url?.absoluteString)")
            }
            
            if G.ShowHttpRespond {
                G.logger.debug("\nHTTP   RESPONSE:\(res.response?.description)\n")
            }
        #else
        #endif
    }
}


