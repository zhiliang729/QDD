//
//  UserService.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire


class UserService {
    
    //MARK: - 1. 获取用户信息
    @discardableResult
    class func user(id: Int, success: @escaping (User) -> Void, fail: @escaping (RequestError) -> Void) -> DataRequest {
        
        let tmp = HttpRequest.request(UserAPI.userInfo(id: id), success: { (res, json) in
            let user = User(json: json["user"])
            success(user)
        }, fail: { (error) in
            fail(error)
        })
        
        return tmp
    }
    
    //MARK: - 2. 获取用户评论
    @discardableResult
    class func comments(id: Int, start: Int, success: @escaping (UserCommentsHandler) -> Void, fail: @escaping (RequestError) -> Void ) -> DataRequest {
        
        let tmp = HttpRequest.request(UserAPI.userComments(id: id, paras: ["start": start]), success: { (res, json) in
            let handler = UserCommentsHandler(json: json)
            success(handler)
        }, fail: { (error) in
            fail(error)
        })
        
        return tmp
    }
    
    //MARK: - 3. 获取用户收藏的文章
    @discardableResult
    class func topics(id: Int, start: Int, success: @escaping (UserTopicsHandler) -> Void, fail: @escaping (RequestError) -> Void ) -> DataRequest {
        
        let tmp = HttpRequest.request(UserAPI.userTopic(id: id, paras: ["start": start]), success: { (res, json) in
            let handler = UserTopicsHandler(json: json)
            success(handler)
        }, fail: { (error) in
            fail(error)
        })
        
        return tmp
    }
    
    //MARK: - 4. 获取用户订阅的收藏夹
    @discardableResult
    class func subNodes(id: Int, start: Int, success: @escaping (UserNodesHandler) -> Void, fail: @escaping (RequestError) -> Void ) -> DataRequest {
        
        let tmp = HttpRequest.request(UserAPI.userSubNode(id: id, paras: ["start": start]), success: { (res, json) in
            let handler = UserNodesHandler(json: json)
            success(handler)
        }, fail: { (error) in
            fail(error)
        })
        
        return tmp
    }
    
    //MARK: - 5. 获取用户创建的收藏夹
    @discardableResult
    class func nodes(id: Int, success: @escaping (UserNodesHandler) -> Void, fail: @escaping (RequestError) -> Void ) -> DataRequest {
        
        let tmp = HttpRequest.request(UserAPI.userCreateNode(id: id), success: { (res, json) in
            let handler = UserNodesHandler(json: json)
            success(handler)
        }, fail: { (error) in
            fail(error)
        })
        
        return tmp
    }
}
