//
//  MiscService.swift
//  QDD
//
//  Created by RHCT on 2016/11/30.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


class MiscService {
    
    //MARK: - 1.获取是否有新版本
    @discardableResult
    class func checkVersion(success: ((VersionHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(MISCAPI.graphicCaptcha, success:{ (_, json) in
            let handler = VersionHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 2.获取闪屏图片
    @discardableResult
    class func splashScreen(success: ((SplashScreenHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(MISCAPI.splashScreen, success:{ (_, json) in
            let handler = SplashScreenHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    //MARK: - 3.获取banner
    @discardableResult
    class func banner(area: Banner.Area, success: ((BannerHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(MISCAPI.banner(paras: ["show_area": area.rawValue]), success:{ (_, json) in
            let handler = BannerHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 4.设备激活
    @discardableResult
    class func activate(success: (() -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(MISCAPI.deviceActivating, success: { (_, _) in
            success?()
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 5. 获取图形验证码
    @discardableResult
    class func graphicCaptcha(success: ((UIImage?) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.getImage(MISCAPI.graphicCaptcha, success:{ (_, image) in
            success?(image)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    
    //MARK: - 8.获取 app 的后台配置信息 是否显示广告等
    @discardableResult
    class func settings(success: ((SettingsHandler) -> Void)?, fail: ((RequestError) -> Void)? ) -> DataRequest {
        
        let tmp = HttpRequest.request(MISCAPI.settings, success: { (_, json) in
            let handler = SettingsHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
        
        return tmp
    }
    
    //MARK: - 15.上传图片
    class func upload(image: Data, attach: String, success: ((UploadImageHandler) -> Void)?, fail: ((RequestError) -> Void)? ) {
        
        HttpRequest.uploadImage(MISCAPI.imageUpload(paras: ["attach": attach]), multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(image, withName: "image", fileName: "image.png", mimeType: "image/png")
            
        }, success: { (_, json) in
            let handler = UploadImageHandler(json: json)
            success?(handler)
        }, fail: { (error) in
            fail?(error)
        })
    }
}

