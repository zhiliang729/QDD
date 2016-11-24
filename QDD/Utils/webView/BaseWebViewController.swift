//
//  BaseWebViewController.swift
//  Daker
//
//  Created by RHCT on 16/8/25.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import WebKit

class BaseWebViewController: BaseViewController {
    
    var url: NSURL?
    
    //工具栏
    private var toolView: WebToolView!
    
    //添加webview的地方
    @IBOutlet private var placeHolderView: UIView!
    
    //webview
    private var mwebview: WKWebView!
    //delegate
    private var webDelegate: WebViewDeleClass!
    //useragent
    private var webDefaultUserAgent: String?
    //这个字段用来ViewWillAppear 控制是否需要刷新页面
    private var shouldRefresh: Bool = false
    
    private var sharePicUrl: String?//分享图片
    private var shareTitle: String?//分享title
    private var shareDesc: String?//分享desc
    private var shareUrl: String?//分享url
    
    //进度条
    @IBOutlet private weak var mprogressView: UIProgressView!
    
    //加载gif相关
    @IBOutlet private weak var loadGifView: UIView!
    @IBOutlet private weak var gifImgView: UIImageView!
    @IBOutlet private weak var gifNotiLabel: UILabel!
    
    //加载动画timer
    private var loadGifTimer: NSTimer?
    
    deinit {
        loadGifTimer?.invalidate()
        loadGifTimer = nil
        
        NSUserDefaults.standardUserDefaults().stopSpoofingUserAgent()
        
        mwebview.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
        
        mwebview.configuration.userContentController.removeScriptMessageHandlerForName("WebCallUserLogin")
        mwebview.configuration.userContentController.removeScriptMessageHandlerForName("ShareActivity")
        mwebview.configuration.userContentController.removeScriptMessageHandlerForName("doLinkOnClick")
        
        mwebview.removeObserver(self, forKeyPath: "estimatedProgress")
        
        webDelegate.delegate = nil
        webDelegate.controller = nil
        webDelegate.webview = nil
        
        mwebview.UIDelegate = nil
        mwebview.scrollView.delegate = nil
        mwebview.navigationDelegate = nil
        mwebview.removeFromSuperview()
        
        mwebview = nil
        
        webDelegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToolView()
        
        //通用ua获取
        let webview = UIWebView()
        webDefaultUserAgent = webview.stringByEvaluatingJavaScriptFromString("navigator.userAgent")
        
        shareUrl = url?.absoluteString
        
        loadWeb()
    }
    
    private func addToolView() {
        
        toolView = WebToolView(frame: CGRect(x: 0, y: G.SCREEN_HEIGHT - 55 - 64, width: G.SCREEN_WIDTH, height: 55))
        toolView.backButton.addTarget(self, action: #selector(backToUpLevel), forControlEvents: .TouchUpInside)
        toolView.lastButton.addTarget(self, action: #selector(goBack), forControlEvents: .TouchUpInside)
        toolView.nextButton.addTarget(self, action: #selector(goForward), forControlEvents: .TouchUpInside)
        toolView.refreshButton.addTarget(self, action: #selector(reload), forControlEvents: .TouchUpInside)
        toolView.shareButton.addTarget(self, action: #selector(showShareView), forControlEvents: .TouchUpInside)
        
        view.insertSubview(toolView, aboveSubview: placeHolderView)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        mprogressView.progress = 0.0
        mwebview.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
        
        shouldRefresh = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSUserDefaults.standardUserDefaults().stopSpoofingUserAgent()
        
        shouldRefresh = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldRefresh {
            if mwebview != nil && url?.absoluteString.characters.count != 0 {
                loadWeb()
            }
            shouldRefresh = false
        }
        
        edgesForExtendedLayout = .None
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Web Navi
extension BaseWebViewController {
    
    func goBack() {
        mwebview.goBack()
        updateBottomButtons()
    }
    
    func goForward() {
        mwebview.goForward()
        updateBottomButtons()
    }
    
    func reload() {
        mwebview.reload()
        updateBottomButtons()
    }
    
    func stopLoading() {
        mwebview.stopLoading()
        updateBottomButtons()
    }
    
    //MARK: -- 刷新工具栏状态
    func updateBottomButtons() {
        //上一页
        toolView.lastButton.enabled = mwebview.canGoBack
        toolView.lastButton.setImage(UIImage(named:mwebview.canGoBack ? "v1_web_last_yes" : "v1_web_last_no"), forState:.Normal)
        
        //下一页
        toolView.nextButton.enabled = mwebview.canGoForward
        toolView.nextButton.setImage(UIImage(named: mwebview.canGoForward ? "v1_web_next_yes" : "v1_web_next_no"), forState:.Normal)
        
        toolView.refreshButton.setImage(UIImage(named: mwebview.loading ? "v1_web_stop" : "v1_web_refresh"), forState:.Normal)
        
        if mwebview.loading {
            toolView.refreshButton.removeTarget(self, action: #selector(reload), forControlEvents: .TouchUpInside)
            toolView.refreshButton.addTarget(self, action: #selector(stopLoading), forControlEvents: .TouchUpInside)
        } else {
            toolView.refreshButton.removeTarget(self, action: #selector(stopLoading), forControlEvents: .TouchUpInside)
            toolView.refreshButton.addTarget(self, action: #selector(reload), forControlEvents: .TouchUpInside)
        }
    }
    
    func showShareView() {
        
    }
}

//MARK: - web 相关
extension BaseWebViewController {
    
    private func load404Web() {
        webviewConfig()
        
        let htmlPath = NSBundle.mainBundle().pathForResource("404", ofType: "html")
        let htmlContent = try! String(contentsOfFile: htmlPath!, encoding: NSUTF8StringEncoding)
        mwebview!.loadHTMLString(htmlContent ?? "", baseURL: nil)
    }
    
    private func loadWeb() {
        
        let urlStr = WebViewDeleClass.configUrl(url: url?.absoluteString)!
        
        guard let urlToLoad = NSURL(string: urlStr) else {
            G.showMessage("链接不可用")
            return
        }
        
        gifNotiLabel.text = "正在为您打开页面"
        
        startLoadGif()
        
        WebViewDeleClass.configIOS8UserAgentWithUrl(urlToLoad, userAgent: webDefaultUserAgent ?? "")
        
        webviewConfig()
        
        WebViewDeleClass.configIOS9UA(self.mwebview!, url: urlToLoad, userAgent: webDefaultUserAgent ?? "")
        
        let curRequest = WebViewDeleClass.getRequestWithUrl(urlToLoad)
        self.mwebview.loadRequest(curRequest)
    }
    
    private func webviewConfig() {
        if mwebview == nil {
            webDelegate = WebViewDeleClass()
            webDelegate!.controller = self
            webDelegate!.delegate = self
            webDelegate!.webDefaultUserAgent = webDefaultUserAgent ?? ""
            webDelegate!.canOpenAnotherView = false
            
            mwebview = WebViewDeleClass.getWebViewWithFrame(CGRectMake(0, 0, G.SCREEN_WIDTH, G.SCREEN_HEIGHT - 55 - 64), webDelegate: webDelegate!)
            placeHolderView.addSubview(mwebview!)
            
            mprogressView.hidden = false
            mprogressView.trackTintColor = UIColor.clearColor()
            mprogressView.progressTintColor = UIColor(hex:0xFD6534)
            mwebview!.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        }
    }
}

//MARK: - WEB DELEGATE
extension BaseWebViewController: RHCTWebViewDelegate {
    func web(webview: WKWebView, didStartProvisionalNavigation navigation: WKNavigation?) {
        updateBottomButtons()
    }
    
    func web(webview: WKWebView, didFinishNavigation navigation: WKNavigation?) {
        stopLoadGif()
        updateBottomButtons()
    }
    
    func web(webview: WKWebView, didFailNavigation navigation: WKNavigation?, withError error: NSError) {
        stopLoadGif()
        
        if error.domain == "NSURLErrorDomain" && error.code != NSURLErrorCancelled {
            
        }
        
        if webview.URL?.absoluteString == url?.absoluteString && error.code != NSURLErrorCancelled {
            
        }
        updateBottomButtons()
    }
}

//MARK: - 加载动画
extension BaseWebViewController {
    //开始动画
    private func startLoadGif() {
        stopLoadGif()
        
        loadGifView.hidden = false
        
        var array: [UIImage] = []
        for i in 1 ... 32 {
            array.append(UIImage(named: "Topic_Load_\(i)")!)
        }
        
        gifImgView.animationImages = array
        gifImgView.animationDuration = Double(array.count) * 0.1
        gifImgView.startAnimating()
        
        loadGifTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(stopLoadGif), userInfo: nil, repeats: false)
    }
    
    //结束动画
    func stopLoadGif() {
        if let timer = loadGifTimer where timer.valid {
            timer.invalidate()
        }
        
        loadGifTimer = nil
        
        gifImgView.stopAnimating()
        gifImgView.animationImages = nil
        loadGifView.hidden = true
    }
}

extension BaseWebViewController {
    func scrollToTop() {
        if mwebview.subviews.count > 0 {
            let scroll = mwebview.subviews[0]
            guard let cls = NSClassFromString("WKScrollView") else {
                return
            }
            if cls.isSubclassOfClass(UIScrollView) {
                if let scrollview = scroll as? UIScrollView {
                    scrollview.setContentOffset(CGPointMake(0, 0), animated: true)
                }
            }
        }
    }
}

//MARK: - 进度条处理
extension BaseWebViewController {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let web = object as? WKWebView where web == mwebview else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return;
        }
        
        guard let path = keyPath where path == "estimatedProgress" else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        updateProgressBar(mwebview.estimatedProgress)
    }
    
    func updateProgressBar(value: Double?) {
        guard let progress = value else {
            return
        }
        
        if progress == 1.0 {
            mprogressView.setProgress(Float(progress), animated: true)
            
            UIView.animateWithDuration(1.5, animations: {
                self.mprogressView.alpha = 0.0
                }, completion: { (finished) in
                    if finished {
                        self.mprogressView.setProgress(Float(0.0), animated: false)
                    }
            })
        } else {
            if mprogressView.alpha < 1.0 {
                mprogressView.alpha = 1.0;
            }
            mprogressView.setProgress(Float(progress), animated: (Float(progress) > self.mprogressView.progress))
        }
    }
}
