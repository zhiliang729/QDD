//
//  UIImageView+Extension.swift
//  Daker
//
//  Created by zhangliang on 16/8/4.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation
import Alamofire
import Kingfisher


//MARK: - kingfisher
extension UIImageView {    
    func kf_setImageWithURL(string: String?,
                                   placeholderImage: Image? = nil,
                                   optionsInfo: KingfisherOptionsInfo? = nil,
                                   progressBlock: DownloadProgressBlock? = nil,
                                   completionHandler: CompletionHandler? = nil) -> RetrieveImageTask?
    {
        
        guard let str = string, let url = NSURL(string: str) else {
            self.image = placeholderImage
            return nil
        }
        
        return kf_setImageWithURL(url, placeholderImage: placeholderImage, optionsInfo: optionsInfo, progressBlock: progressBlock, completionHandler: completionHandler)
    }
}

