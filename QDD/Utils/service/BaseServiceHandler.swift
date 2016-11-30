//
//  BaseServiceHandler.swift
//  QDD
//
//  Created by RHCT on 2016/11/29.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON


public class BaseServiceHandler {
    public var request: URLRequest?//请求信息
    public var response: HTTPURLResponse?//响应信息
    
    public init(json: JSON) {
    }
}

