//
//  WebViewDeleClass.swift
//  rhct_ios
//
//  Created by RHCT on 16/1/3.
//  Copyright © 2016年 rhct. All rights reserved.
//

import UIKit
import WebKit

@objc protocol RHCTWebViewDelegate {
    func web(webview: WKWebView, didStartProvisionalNavigation navigation:WKNavigation?)
    
    func web(webview: WKWebView, didFinishNavigation navigation:WKNavigation?)
    
    func web(webview: WKWebView, didFailNavigation navigation: WKNavigation?, withError error: NSError)

    optional func cancelOpenUrl() -> Void
    
    optional func openAnUrl() -> Void
}

@objc class WebViewDeleClass: NSObject {
    weak var controller: UIViewController?
    weak var delegate: RHCTWebViewDelegate?
    weak var webview: WKWebView?
    var webDefaultUserAgent: String?
    var canOpenAnotherView: Bool = false
    
    private var canOpenFenghuangClient = false//可否打开凤凰网
    
    deinit {
    }
    
    //定制url
    class func configUrl(url _url: String?) -> String? {
        var urlStr = _url
        // 测试js html
//        var urlStr: String? = "http://zhiliang729.github.io/testLogin.html";

        if var aurl = urlStr {
            if aurl.containsString("hothuati.com/topic") || aurl.containsString("lqxn1015.com/topic") {
                aurl = aurl.stringByAppendingFormat("?w=%d", Int(G.SCREEN_WIDTH))
            }
            urlStr = aurl
        }
        
        return urlStr
    }
    
    //ios9 之前，在webview实例化之前调用   设置ua
    class func configIOS8UserAgentWithUrl(url: NSURL, userAgent agent: String) {
        if let host = url.host where host.containsString("hothuati.com") || host.containsString("lqxn1015.com") || host.containsString("zhiliang729.github.io")   {//自定义ua
            let userAgent = G.globalUserAgent()
            if #available(iOS 9.0, *) {
            } else {
                NSUserDefaults.standardUserDefaults().startSpoofingUserAgent(userAgent)
            }
        } else {
            if #available(iOS 9.0, *) {
            } else {
                NSUserDefaults.standardUserDefaults().startSpoofingUserAgent(agent)
            }
        }
    }
    
    //ios9 webview 设置
    class func configIOS9UA(webview: WKWebView, url: NSURL, userAgent agent: String?) {
        if let host = url.host where host.containsString("hothuati.com") || host.containsString("lqxn1015.com") || host.containsString("zhiliang729.github.io")   {//自定义ua
            let userAgent = G.globalUserAgent()
            if #available(iOS 9.0, *) {
                webview.customUserAgent = userAgent
            }
        } else {
            
            if #available(iOS 9.0, *) {
                if url.scheme.containsString("rhcturl") {
                    let userAgent = G.globalUserAgent()
                    webview.customUserAgent = userAgent
                } else {
                    webview.customUserAgent = agent
                }
                
            }
        }
    }
    
    //实例化 webview
    class func getWebViewWithFrame(frame: CGRect, webDelegate: WebViewDeleClass) -> WKWebView {
        let config = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        
        //若一开始就知道需要设置什么cookies，则可以在此处写入  参见http://stackoverflow.com/questions/26573137/can-i-set-the-cookies-to-be-used-by-a-wkwebview/26577303#26577303
//        let cookieScript = WKUserScript(source: "document.cookie = 'TeskCookieKey1=TeskCookieValue1';document.cookie = 'TeskCookieKey2=TeskCookieValue2';", injectionTime: .AtDocumentStart, forMainFrameOnly: false)
//        userContentController.addUserScript(cookieScript);
        
        
        
        //ios8 以后js可以发送消息给本地  使用
        //var message = { 'message' : 'Hello, World!', 'numbers' : [ 1, 2, 3 ] };
        //window.webkit.messageHandlers.<name>.postMessage(message);  name就是下面方法中得name字段, message字段不可为nil
        userContentController.addScriptMessageHandler(webDelegate, name: "WebCallUserLogin")
        userContentController.addScriptMessageHandler(webDelegate, name: "ShareActivity")
        userContentController.addScriptMessageHandler(webDelegate, name: "doLinkOnClick")
        
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
        webview.backgroundColor = UIColor.whiteColor();
        webview.UIDelegate = webDelegate;
        webview.navigationDelegate = webDelegate;
        return webview
    }
    
    //定制requesturl
    class func getRequestWithUrl(url: NSURL) -> NSURLRequest {
        let curRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        //MARK: -- 把本地cookie带入webview
        if let host = url.host where host.containsString("hothuati.com") || host.containsString("lqxn1015.com") || host.containsString("zhiliang729.github.io") {
            if let baseUrl = NSURL(string: G.platformBaseUrl) {
                if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(baseUrl) {
                    let dict = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
                    let cookiesString = dict["Cookie"]
                    
                    if let str = cookiesString {
                        curRequest.setValue(str, forHTTPHeaderField: "Cookie")
                    }
                }
            }
        }
        
        return curRequest
    }
    
    //MARK: - 实例方法
    private func isWhitelistedUrl(url: NSURL) -> Bool {
        for entry in G.whiteListedUrls {
            if let _ = url.absoluteString.rangeOfString(entry, options: .RegularExpressionSearch) {
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    private func getController() -> UIViewController? {
        if let controller = self.controller {
            if controller === G.appdelegate.mainDelegate.curNavController?.viewControllers.last {
                return self.controller
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    private func openExternal(url: NSURL, prompt: Bool = false) {
        if prompt {
            // Ask the user if it's okay to open the url with UIApplication.
            let alert = UIAlertController(
                title: String(format: "打开 %@", url),
                message: nil/*String("将要打开另一个应用程序")*/,
                preferredStyle: .Alert
            )
            
            alert.addAction(UIAlertAction(title: String("取消"), style: .Cancel, handler: { [weak self] (action: UIAlertAction) in
                self?.delegate?.cancelOpenUrl?()
            }))
            
            alert.addAction(UIAlertAction(title: String("确定"), style: UIAlertActionStyle.Default, handler: { [weak self] (action: UIAlertAction!) in
                UIApplication.sharedApplication().openURL(url)
                self?.delegate?.openAnUrl?()
            }))
            
            self.getController()?.presentViewController(alert, animated: true, completion: nil)
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    private func callExternal(url: NSURL) {
        if let phoneNumber = url.resourceSpecifier.stringByRemovingPercentEncoding {
            let alert = UIAlertController(title: phoneNumber, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: String("取消"), style: .Cancel, handler: { [weak self] (action: UIAlertAction!) in
                self?.delegate?.cancelOpenUrl?()
            }))
            alert.addAction(UIAlertAction(title: String("拨打"), style: .Default, handler: { [weak self] (action: UIAlertAction!) in
                UIApplication.sharedApplication().openURL(url)
                self?.delegate?.openAnUrl?()
            }))
            self.getController()?.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    internal func handleWebFuc(let function: String, body: AnyObject?) {
        switch function {
        case "WebCallUserLogin":
            G.appdelegate.mainDelegate.pushLoginViewController()
        case "ShareActivity":
            var ff = function
            ff.appendContentsOf(":")
            let selector: Selector = Selector(ff)
            var dict = [String:String]()
            if let ass: String = body as? String {
                if let ss = ass.stringByRemovingPercentEncoding {
                    let query = ss
                    if query.containsString("title") && query.containsString("link") && query.containsString("image") && query.containsString("desc") {
                        let array = query.componentsSeparatedByString("&")
                        if array.count == 4 {
                            let title = array[0].substringFromIndex("title=".endIndex) as String
                            let link = array[1].substringFromIndex("link=".endIndex) as String
                            let image = array[2].substringFromIndex("image=".endIndex) as String
                            let desc = array[3].substringFromIndex("desc=".endIndex) as String
                            dict["title"] = title
                            dict["link"] = link
                            dict["image"] = image
                            dict["desc"] = desc
                        }
                    }
                }
            }
            self.getController()?.performSelector(selector, withObject: dict)
        case "doLinkOnClick":
            if let query: String = body as? String {
                if query.containsString("type") && query.containsString("link") {
                    let array = query.componentsSeparatedByString("&")
                    if array.count == 2 {
                        let typeStr = array[0].substringFromIndex("type=".endIndex)
                        if let _ = Int32(typeStr) {
                            let link = array[1].substringFromIndex("link=".endIndex)
                            //TODO: 一些操作
                            G.appdelegate.mainDelegate.handleUrl(NSURL(string: link))
                        }
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

extension WebViewDeleClass: WKNavigationDelegate {
    
    // 类似 UIWebView 的 -webView: shouldStartLoadWithRequest: navigationType:
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {

        //        NSLog(@"absoluteString:%@", navigationAction.request.URL.absoluteString);
        //        NSLog(@"relativeString:%@", navigationAction.request.URL.relativeString);
        //        NSLog(@"baseURL:%@", navigationAction.request.URL.baseURL);
        //        NSLog(@"absoluteURL:%@", navigationAction.request.URL.absoluteURL);
        //        NSLog(@"scheme:%@", navigationAction.request.URL.scheme);
        //        NSLog(@"host:%@", navigationAction.request.URL.host);
        //        NSLog(@"port:%@", navigationAction.request.URL.port);
        //        NSLog(@"user:%@", navigationAction.request.URL.user);
        //        NSLog(@"password:%@", navigationAction.request.URL.password);
        //        NSLog(@"path:%@", navigationAction.request.URL.path);
        //        NSLog(@"fragment:%@", navigationAction.request.URL.fragment);
        //        NSLog(@"parameterString:%@", navigationAction.request.URL.parameterString);
        //        NSLog(@"query:%@", navigationAction.request.URL.query);
        //        NSLog(@"relativePath:%@", navigationAction.request.URL.relativePath);
        
//        NSLog("navigationaction:%@", navigationAction.request.URL!);
//        NSLog("navigation:%ld", navigationAction.navigationType.rawValue);
        
        guard let url: NSURL = navigationAction.request.URL else {
            decisionHandler(.Cancel);
            return;
        }
        
        WebViewDeleClass.configIOS8UserAgentWithUrl(url, userAgent: self.webDefaultUserAgent ?? "")
        WebViewDeleClass.configIOS9UA(webView, url: url, userAgent: self.webDefaultUserAgent)
        
        switch url.scheme {
        case "about"://空页面允许，否则无法关闭音乐，视频
            decisionHandler(.Allow)
        case "http", "https":
            if isWhitelistedUrl(url) {
                if url.absoluteString.containsString("feng-huang-xin-wen") || url.absoluteString.containsString("id299853944"){//凤凰网，新浪新闻，提示
                    if  canOpenFenghuangClient {//有客户端
                        
                    } else {
                        self.openExternal(url, prompt: true)
                    }
                    decisionHandler(.Cancel)
                } else {
                    self.openExternal(url)
                    decisionHandler(.Cancel)
                }
            } else {
                if canOpenAnotherView {
                    if navigationAction.navigationType == .LinkActivated {
                        G.appdelegate.mainDelegate.handleUrl(url)
                        decisionHandler(.Cancel)
                    } else {
                        decisionHandler(.Allow)
                    }
                } else {
                    if navigationAction.navigationType == .LinkActivated {
                        
                    } else if navigationAction.navigationType == .BackForward {
                        
                    }
                    
                    decisionHandler(.Allow)
                }
            }
        case "rhcturl":
            if let path: String? = url.path {
                if path!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                    let index = "1".startIndex.advancedBy(1)
                    let method: String = path!.substringFromIndex(index)
                    handleWebFuc(method, body: url.query)
                    webView.stopLoading()
                }
            }
            decisionHandler(.Cancel)
        case "tel":
            callExternal(url)
            decisionHandler(.Cancel)
        case "comifengnewsclient", "sinanews"://凤凰新闻、新浪新闻的页面进入会直接提示，所以加上用户提示，防止实现防止循环跳转
            if  UIApplication.sharedApplication().canOpenURL(url) {
                canOpenFenghuangClient = true
                openExternal(url, prompt: true)
                decisionHandler(.Cancel)
            } else {
                canOpenFenghuangClient = false
                decisionHandler(.Allow)
            }
            
        default:
            if UIApplication.sharedApplication().canOpenURL(url) {
                openExternal(url)
                decisionHandler(.Cancel)
            } else {//可以在此处显示错误提示
                decisionHandler(.Allow)
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
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.delegate?.web(webView, didStartProvisionalNavigation: navigation)
    }
    
    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
//    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
//        
//    }
    
//    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
//        
//    }
    
    // 类似 UIWebView 的 －webViewDidFinishLoad:
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.delegate?.web(webView, didFinishNavigation: navigation)
    }
    
    // 类似 UIWebView 的- webView:didFailLoadWithError:
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        self.delegate?.web(webView, didFailNavigation: navigation, withError: error)
    }
    
//    func webView(webView: WKWebView, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
//        
//    }
    
    //9.0以后使用
//    func webViewWebContentProcessDidTerminate(webView: WKWebView) {
//        
//    }
}

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
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (action) -> Void in
            completionHandler();
        }))
        self.getController()?.presentViewController(alert, animated: true, completion: nil)
    }
    
    //  js 里面的confirm实现，如果不实现，网页的Confirm函数无效
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
            completionHandler(true);
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
            completionHandler(false);
        }))
        self.getController()?.presentViewController(alert, animated: true, completion: nil)
    }
    
    //  js 里面的prompt实现，如果不实现，网页的Prompt函数无效  ,
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
            let input = alert.textFields?.first?.text
            completionHandler(input);
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
            completionHandler(nil);
        }))
        self.getController()?.presentViewController(alert, animated: true, completion: nil)
    }
}

extension WebViewDeleClass: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        handleWebFuc(message.name, body: message.body)
    }
}
