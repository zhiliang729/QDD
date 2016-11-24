//
//  ShareSDK_Ext.swift
//  QDD
//
//  Created by RHCT on 2016/11/24.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import Foundation


/// 成功 与 失败
typealias ResultHandler = ((Bool) -> Void)

//MARK: - 第三方登录
extension ShareSDK {
    
    /// 成功之后同步用户结果
    typealias UserSyncHandler = (_ user: SSDKUser?, _ handler: ResultHandler) -> Void
    
    /**
     调用sharesdk第三方
     
     - parameter type: 登录类型
     - parameter userSync: sharesdk成功之后回调，因为接着要与服务器同步账户，为了统一由result来处理结果，在userSync加入回调
     - parameter result:   统一处理是否成功登录
     */
    class func login(type: AccountType, userSync: @escaping UserSyncHandler, result: ResultHandler?) {
        //未安装客户端时，授权视图样式设置  弹出认证页面的配置
        SSDKAuthViewStyle.setNavigationBarBackgroundColor(UIColor(hex: 0xFFFFFF))
        
        // 左侧取消按钮
        SSDKAuthViewStyle.setCancelButtonLabel("取消")
        SSDKAuthViewStyle.setCancelButtonLeftMargin(20)
        SSDKAuthViewStyle.setCancelButtonLabel(UIColor(hex: 0x303030))
        
        var title = ""
        var shareSDKType: SSDKPlatformType = .typeUnknown
        switch type {
        case .weibo:
            title = "新浪微博"
            shareSDKType = .typeSinaWeibo
        case .qq:
            title = "腾讯QQ"
            shareSDKType = .typeQQ
        case .wechat:
            title = "微信"
            shareSDKType = .typeWechat
        default:
            break
        }
        
        if shareSDKType == .typeUnknown {
            G.showMessage("授权失败")
            result?(false)
            return
        }
        
        //中间title view
        SSDKAuthViewStyle.setTitle(title)
        SSDKAuthViewStyle.setTitleColor(UIColor(hex: 0x303030))
        
        //右侧按钮
        SSDKAuthViewStyle.setRightButtonRightMargin(20)
        
        //sharesdk 第三方登录调用
        ShareSDK.getUserInfo(shareSDKType) { (state, user, error) in
            if (state == .success) { //成功
                userSync(user) { tmpResult in
                    result?(tmpResult)
                }
            } else if (state == .cancel) { //取消
                G.showMessage("授权取消")
                result?(false)
            } else {
                G.showMessage("授权失败")
                result?(false)
            }
        }
    }
}

//MARK: - 第三方分享
extension ShareSDK {
    /**
     分享到第三方
     
     - parameter type:       要分享到的第三方类型
     - parameter content:    分享的内容
     - parameter imgURL:     分享图片
     - parameter title:      分享title
     - parameter desc:       分享描述
     - parameter contentURL: 分享url
     */
    class func share(type: SSDKPlatformType, content: String, imgURL: String, title: String, desc: String, contentURL: String) {
        
        guard let shareUrl = URL(string:contentURL) else {
            G.showMessage("分享失败：链接异常")
            return
        }
        
        //授权页面style
        SSDKAuthViewStyle.setNavigationBarBackgroundColor(UIColor(hex: 0xFFFFFF))
        
        //左侧取消按钮
        SSDKAuthViewStyle.setCancelButtonLabel("取消")
        SSDKAuthViewStyle.setCancelButtonLeftMargin(20)
        SSDKAuthViewStyle.setCancelButtonLabel(UIColor(hex: 0x303030))
        
        var authorizeTitle = ""
        switch (type) {
        case .typeSinaWeibo:
            authorizeTitle = "新浪微博"
            
        case .typeQQ, .subTypeQQFriend, .subTypeQZone:
            authorizeTitle = "腾讯QQ"
            
        case .typeWechat, .subTypeWechatSession, .subTypeWechatTimeline:
            authorizeTitle = "微信"
        default:
            break;
        }
        
        SSDKAuthViewStyle.setTitle(authorizeTitle)
        SSDKAuthViewStyle.setTitleColor(UIColor(hex: 0x303030))
        
        SSDKAuthViewStyle.setRightButtonRightMargin(20)
        
        //设置分享边界页面style
        SSUIEditorViewStyle.setiPhoneNavigationBarBackgroundColor(UIColor(hex: 0xFFFFFF))
        
        SSUIEditorViewStyle.setTitleColor(UIColor(hex: 0x303030))
        SSUIEditorViewStyle.setTitle("分享")
        
        SSUIEditorViewStyle.setCancelButtonLabel("取消")
        SSUIEditorViewStyle.setCancelButtonLabel(UIColor(hex: 0x303030))
        
        SSUIEditorViewStyle.setShareButtonLabel("发布")
        SSUIEditorViewStyle.setShareButtonLabel(UIColor(hex: 0x303030))
        
        let params = NSMutableDictionary()
        
        /**
         分享结果处理
         
         - parameter state: 状态
         */
        let handler = { (state: SSDKResponseState) -> Void in
            switch state {
            case .success:
                G.showMessage("分享成功")
            case .fail:
                G.showMessage("分享失败")
            case .cancel:
                G.showMessage("取消分享")
            default:
                break
            }
        }
        
        if type == .subTypeWechatSession || type == .subTypeWechatTimeline {
            
            params.ssdkSetupShareParams(byText: content, images: imgURL, url: shareUrl, title: title, type: .auto)
            share(type, parameters: params, onStateChanged: { (state, _, _, _) in
                handler(state)
            })
            
        } else if type == .typeSinaWeibo {
            
            params.ssdkSetupSinaWeiboShareParams(byText: content + " " + shareUrl.absoluteString, title: title, image: imgURL, url: shareUrl, latitude: 0, longitude: 0, objectID: nil, type: .image)
            showShareEditor(type, otherPlatformTypes: nil, shareParams: params, onShareStateChanged: { (state, _, _, _, _, _) in
                handler(state)
            })
            
        } else if type == .subTypeQQFriend {
            
            params.ssdkSetupQQParams(byText: content, title: title, url: shareUrl, thumbImage: nil, image: imgURL, type: .auto, forPlatformSubType: .subTypeQQFriend)
            share(type, parameters: params, onStateChanged: { (state, _, _, _) in
                handler(state)
            })
            
        } else if type == .subTypeQZone {
            
            params.ssdkSetupQQParams(byText: content, title: title, url: shareUrl, thumbImage: nil, image: imgURL, type: .webPage, forPlatformSubType: .subTypeQZone)
            share(type, parameters: params, onStateChanged: { (state, _, _, _) in
                handler(state)
            })
            
        }
    }
}

