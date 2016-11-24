//
//  WebViewDeleClass.swift
//  rhct_ios
//
//  Created by RHCT on 16/1/3.
//  Copyright © 2016年 rhct. All rights reserved.
//

import UIKit
import WebKit

@objc protocol WebViewDelegate {
    func web(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    
    func web(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    
    func web(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    
    //调起登录页面
    func toLoginViewcontroller() -> Void
    
    @objc optional func cancelOpenUrl() -> Void
    
    @objc optional func openAnUrl() -> Void
}

class WebViewDeleClass: NSObject {
    
    weak var controller: UIViewController?
    weak var delegate: WebViewDelegate?
    weak var webview: WKWebView?
    
    var webDefaultUserAgent: String?
    var canOpenAnotherView: Bool = false
    
    fileprivate var canOpenFenghuangClient = false//可否打开凤凰网
    
    deinit {
    }
    
    //MARK: - 类方法
    //定制url
    class func configUrl(_ _url: String?) -> String? {
        var urlStr = _url
        // 测试js html
//        var urlStr: String? = "http://zhiliang729.github.io/testLogin.html";

        if var aurl = urlStr {
            if aurl.contains("hothuati.com/topic") || aurl.contains("lqxn1015.com/topic") {
                aurl = aurl.appendingFormat("?w=%d", Int(G.SCREEN_WIDTH))
            }
            urlStr = aurl
        }
        
        return urlStr
    }
    
    //ios9 之前，在webview实例化之前调用   设置ua
    class func configIOS8UserAgent(url: URL, userAgent agent: String) {
        if let host = url.host , host.contains("hothuati.com") || host.contains("lqxn1015.com") || host.contains("zhiliang729.github.io")   {//自定义ua
            let gagent = G.globalUserAgent()
            if #available(iOS 9.0, *) {
            } else {
                UserDefaults.standard.startSpoofing(userAgent: gagent)
            }
        } else {
            if #available(iOS 9.0, *) {
            } else {
                UserDefaults.standard.startSpoofing(userAgent: agent)
            }
        }
    }
    
    //ios9 webview 设置
    class func configIOS9UA(webview: WKWebView, url: URL, userAgent agent: String?) {
        if let host = url.host, host.contains("hothuati.com") || host.contains("lqxn1015.com") || host.contains("zhiliang729.github.io")   {//自定义ua
            let gagent = G.globalUserAgent()
            if #available(iOS 9.0, *) {
                webview.customUserAgent = gagent
            }
        } else {
            
            if #available(iOS 9.0, *) {
                if let scheme = url.scheme, scheme.contains("rhcturl") {
                    let gagent = G.globalUserAgent()
                    webview.customUserAgent = gagent
                } else {
                    webview.customUserAgent = agent
                }
                
            }
        }
    }
    
    //实例化 webview
    class func webView(frame: CGRect, webDelegate: WebViewDeleClass) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        
        //若一开始就知道需要设置什么cookies，则可以在此处写入  参见http://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303
        //        let cookieScript = WKUserScript(source: "document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';", injectionTime: .AtDocumentStart, forMainFrameOnly: false)
        //        userContentController.addUserScript(cookieScript);
        
        
        
        //ios8 以后js可以发送消息给本地  使用
        //var message = { 'message' : 'Hello, World!', 'numbers' : [ 1, 2, 3 ] };
        //window.webkit.messageHandlers.<name>.postMessage(message);  name就是下面方法中得name字段, message字段不可为nil
        userContentController.add(webDelegate, name: "WebCallUserLogin")
        userContentController.add(webDelegate, name: "ShareActivity")
        userContentController.add(webDelegate, name: "doLinkOnClick")
        //        userContentController.addScriptMessageHandler(webDelegate, name: "isVideoPlay")
        
        config.preferences.javaScriptCanOpenWindowsAutomatically = false//不可以在js中自动打开窗口
        config.userContentController = userContentController
        
        //js允许
        config.preferences.javaScriptEnabled = true
        
        //web启动可自动播放
        config.allowsInlineMediaPlayback = false
        
        if #available(iOS 9.0, *) {
            config.requiresUserActionForMediaPlayback = false
        } else {
            config.mediaPlaybackRequiresUserAction = false
        }
        
        let webview = WKWebView(frame: frame, configuration: config)
        webview.backgroundColor = UIColor.white
        webview.uiDelegate = webDelegate
        webview.navigationDelegate = webDelegate
        return webview
    }
    
    //定制requesturl
    class func request(url: URL) -> URLRequest {
        let curRequest: NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        //MARK: -- 把本地cookie带入webview
        if let host = url.host,
            host.contains("hothuati.com") || host.contains("lqxn1015.com") || host.contains("zhiliang729.github.io"),
            let baseUrl = URL(string: G.platformBaseUrl),
            let cookies = HTTPCookieStorage.shared.cookies(for: baseUrl) {
            
            let dict = HTTPCookie.requestHeaderFields(with: cookies)
            
            if let str = dict["Cookie"] {
                curRequest.setValue(str, forHTTPHeaderField: "Cookie")
            }
        }
        
        return curRequest as URLRequest
    }
    
    //MARK: - 实例方法
    fileprivate func isWhitelistedUrl(url: URL) -> Bool {
        for entry in G.whiteListedUrls {
            if let _ = url.absoluteString.range(of: entry, options: .regularExpression, range: nil, locale: nil) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    fileprivate func getController() -> UIViewController? {
        if let controller = self.controller {
            if controller === G.appdelegate.mainDelegate.curNavController?.viewControllers.last {
                return controller
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    fileprivate func openExternal(url: URL, prompt: Bool = false) {
        if prompt {
            // Ask the user if it's okay to open the url with UIApplication.
            let alert = UIAlertController(
                title: String(format: "打开 %@", url as CVarArg),
                message: nil/*String("将要打开另一个应用程序")*/,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: String("取消"), style: .cancel, handler: { [weak self] (action: UIAlertAction) in
                self?.delegate?.cancelOpenUrl?()
            }))
            
            alert.addAction(UIAlertAction(title: String("确定"), style: UIAlertActionStyle.default, handler: { [weak self] (action: UIAlertAction!) in
                UIApplication.shared.openURL(url)
                self?.delegate?.openAnUrl?()
            }))
            
            self.getController()?.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    internal func handleWeb(function: String, body: AnyObject?) {
        switch function {
        case "WebCallUserLogin":
            delegate?.toLoginViewcontroller()
        case "ShareActivity":
            let ff = function.appending(":")
            let selector: Selector = Selector(ff)
            var dict: [String:String] = [:]
            
            if let ass = body as? String,
                let query = ass.removingPercentEncoding,
                query.contains("title") && query.contains("link") && query.contains("image") && query.contains("desc") {
                
                let array = query.components(separatedBy: "&")
                if array.count == 4 {
                    let title = array[0].substring(from: "title=".endIndex) as String
                    let link = array[1].substring(from: "link=".endIndex) as String
                    let image = array[2].substring(from: "image=".endIndex) as String
                    let desc = array[3].substring(from: "desc=".endIndex) as String
                    dict["title"] = title
                    dict["link"] = link
                    dict["image"] = image
                    dict["desc"] = desc
                }
            }
            _ = self.getController()?.perform(selector, with: dict)
        case "doLinkOnClick":
            if let query = body as? String,
                query.contains("type") && query.contains("link") {
                
                let array = query.components(separatedBy: "&")
                
                if array.count == 2 {
                    let typeStr = array[0].substring(from: "type=".endIndex)
                    if Int32(typeStr) != nil {
                        let link = array[1].substring(from: "link=".endIndex)
                        
                        G.appdelegate.mainDelegate.handleUrl(URL(string: link))
                    }
                }
            }
        default:
            break
        }
    }
    
    func showAlert() {
        let alert = "alert('显示alert');"
        webview?.evaluateJavaScript(alert, completionHandler: { (object, error) -> Void in
            
        })
    }
    
    func showConfirm() {
        let confirm = "var confirmed = confirm('OK?');"
        webview?.evaluateJavaScript(confirm, completionHandler: { (object, error) -> Void in
            
        })
    }
    
    func showPrompt() {
        let prompt = "var person = prompt('请输入姓名', '你的名字');"
        webview?.evaluateJavaScript(prompt, completionHandler: { (object, error) -> Void in
            
        })
    }
}


//MARK: - WKNavigationDelegate
extension WebViewDeleClass: WKNavigationDelegate {
    
    // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        //debugPrint()
        //debugPrint("\n*******url: \(navigationAction.request.url?.absoluteString)\n")
        //debugPrint()
        
        guard let url: URL = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        WebViewDeleClass.configIOS8UserAgent(url: url, userAgent: self.webDefaultUserAgent ?? "")
        WebViewDeleClass.configIOS9UA(webview: webView, url: url, userAgent: self.webDefaultUserAgent)
        if #available(iOS 9.0, *) {
            //            debugPrint("UserAgent:\(webView.customUserAgent)")
        } else {
            //            debugPrint("UserAgent:\(NSUserDefaults.standardUserDefaults().objectForKey(kUserAgentKey))")
        }
        
        guard let scheme = url.scheme else {
            decisionHandler(.allow)
            return
        }
        
        switch scheme {
        case "about"://空页面允许，否则无法关闭音乐，视频
            decisionHandler(.allow)
        case "http", "https":
            if isWhitelistedUrl(url: url) {
                if url.absoluteString.contains("feng-huang-xin-wen") || url.absoluteString.contains("id299853944"){//凤凰网，新浪新闻，提示
                    if  canOpenFenghuangClient {//有客户端
                        
                    } else {
                        openExternal(url: url, prompt: true)
                    }
                    decisionHandler(.cancel)
                } else {
                    openExternal(url: url)
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.allow)
            }
        case "rhcturl":
            if url.path.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                let index = "1".index("1".startIndex, offsetBy: 1)
                let method: String = url.path.substring(from: index)
                handleWeb(function: method, body: url.query as AnyObject?)
                webView.stopLoading()
            }
            decisionHandler(.cancel)
        case "tel":
            decisionHandler(.cancel)
        case "comifengnewsclient", "sinanews"://凤凰新闻、新浪新闻的页面进入会直接提示，所以加上用户提示，防止实现防止循环跳转
            if  UIApplication.shared.canOpenURL(url) {
                canOpenFenghuangClient = true
                openExternal(url: url, prompt: true)
                decisionHandler(.cancel)
            } else {
                canOpenFenghuangClient = false
                decisionHandler(.allow)
            }
            
        default:
            if UIApplication.shared.canOpenURL(url) {
                openExternal(url: url)
                decisionHandler(.cancel)
            } else {//可以在此处显示错误提示
                decisionHandler(.allow)
            }
        }
    }
    
    //    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
    //        if let httpResponse = navigationResponse.response as? NSHTTPURLResponse {
    //            debugPrint("httpResponse.statusCode:\(httpResponse.statusCode)")
    //        }
    //
    //        decisionHandler(.Allow)
    //    }
    
    // 类似UIWebView的 -webViewDidStartLoad:
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.web(webView, didStartProvisionalNavigation: navigation)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    //    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
    //
    //    }
    
    //    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
    //
    //    }
    
    // 类似 UIWebView 的 －webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.delegate?.web(webView, didFinish: navigation)
    }
    
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.delegate?.web(webView, didFail: navigation, withError: error)
    }
    
    //    func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
    //
    //    }
    
    //9.0以后使用
    //    func webViewWebContentProcessDidTerminate(webView: WKWebView) {
    //
    //    }
}


//MARK: - WKUIDelegate
extension WebViewDeleClass: WKUIDelegate {
    // 接口的作用是打开新窗口
    //    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
    //
    //    }
    
    //9.0以后使用
    //    func webViewDidClose(webView: WKWebView) {
    //
    //    }
    
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel, handler: { (action) -> Void in
            completionHandler();
        }))
        self.getController()?.present(alert, animated: true, completion: nil)
    }
    
    //  js 里面的confirm实现，如果不实现，网页的Confirm函数无效
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) -> Void in
            completionHandler(true);
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) -> Void in
            completionHandler(false);
        }))
        self.getController()?.present(alert, animated: true, completion: nil)
    }
    
    //  js 里面的prompt实现，如果不实现，网页的Prompt函数无效  ,
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) -> Void in
            let input = alert.textFields?.first?.text
            completionHandler(input);
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) -> Void in
            completionHandler(nil);
        }))
        self.getController()?.present(alert, animated: true, completion: nil)
    }
}

//MARK: - WKScriptMessageHandler
extension WebViewDeleClass: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handleWeb(function: message.name, body: message.body as AnyObject?)
    }
}
