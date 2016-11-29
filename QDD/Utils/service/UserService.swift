//
//  UserService.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

class UserService {
    //MARK: - 1. 获取用户信息
    class func user(id: Int, success: ((User) -> Void)?, fail: ((RequestError) -> Void)? ) {
        HttpRequest.request(UserAPI.userInfo(id: id), success: { (res, json) in
            let user = User(json: json["user"])
            success?(user)
        }, fail: { (error) in
            fail?(error)
        })
    }
    
//    //MARK: - 2. 获取用户评论
//    class func comments(id: Int, start: Int, success: ((UserCommentsHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
//        HttpRequest.request(UserAPI.userInfo(id: id), success: { (res, json) in
//            let user = User(json: json["user"])
//            success?(user)
//        }, fail: { (error) in
//            fail?(error)
//        })
//        HttpRequst.get(Daker.userComments(id: userID).routeUrl, parameters: ["start": "\(start)"], onSuccess: { (response, json) in
//            let handler = UserCommentsHandler(json: json)
//            success?(handler)
//        }) { (error) in
//            fail?(error)
//        }
//    }
//    
//    //MARK: - 3. 获取用户收藏的文章
//    class func topics(userID: Int, start: Int, success: ((UserTopicsHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
//        
//        HttpRequst.get(Daker.userTopic(id: userID).routeUrl, parameters: ["start": "\(start)"], onSuccess: { (res, json) in
//            let handler = UserTopicsHandler(json: json)
//            success?(handler)
//        }) { (error) in
//            fail?(error)
//        }
//    }
//    
//    //MARK: - 5. 获取用户创建的收藏夹
//    class func nodes(userID: Int, success: ((UserNodesHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
//        
//        HttpRequst.get(Daker.userCreateNode(id: userID).routeUrl, parameters: nil, onSuccess: { (res, json) in
//            let handler = UserNodesHandler(json: json)
//            success?(handler)
//        }) { (error) in
//            fail?(error)
//        }
//    }
}
