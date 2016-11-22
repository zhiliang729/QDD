//
//  MiscService.swift
//  Daker
//
//  Created by RHCT on 16/8/4.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation

import SwiftyJSON

class MiscService {
    //MARK: - 5. 获取图形验证码
    class func getPictureCaptcha(success: ((UIImage?) -> Void)?, fail:  ((RequestError) -> Void)? ) {
        HttpRequst.getImage(.GET, url: Daker.pictureCaptcha.routeUrl, parameters: nil, onSuccess: { (response, image) in
            success?(image)
        }) { (error) in
            fail?(error)
        }
    }
}


