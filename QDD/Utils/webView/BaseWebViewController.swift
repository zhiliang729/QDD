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
    
    var url: URL?
    
    //工具栏
    fileprivate var toolView: WebToolView!
    
    //添加webview的地方
    @IBOutlet fileprivate var placeHolderView: UIView!
    
    //webview
    fileprivate var mwebview: WKWebView!
    //delegate
    fileprivate var webDelegate: WebViewDeleClass!
    //useragent
    fileprivate var webDefaultUserAgent: String?
    //这个字段用来ViewWillAppear 控制是否需要刷新页面
    fileprivate var shouldRefresh: Bool = false
    
    fileprivate var sharePicUrl: String?//分享图片
    fileprivate var shareTitle: String?//分享title
    fileprivate var shareDesc: String?//分享desc
    fileprivate var shareUrl: String?//分享url
    
    //进度条
    @IBOutlet fileprivate weak var mprogressView: UIProgressView!
    
    //加载gif相关
    @IBOutlet fileprivate weak var loadGifView: UIView!
    @IBOutlet fileprivate weak var gifImgView: UIImageView!
    @IBOutlet fileprivate weak var gifNotiLabel: UILabel!
    
    //加载动画timer
    fileprivate var loadGifTimer: Timer?
    
    deinit {
        loadGifTimer?.invalidate()
        loadGifTimer = nil
        
        UserDefaults.standard.stopSpoofingUserAgent()
        
        mwebview.load(URLRequest(url: URL(string: "about:blank")!))
        
        mwebview.configuration.userContentController.removeScriptMessageHandler(forName: "WebCallUserLogin")
        mwebview.configuration.userContentController.removeScriptMessageHandler(forName: "ShareActivity")
        mwebview.configuration.userContentController.removeScriptMessageHandler(forName: "doLinkOnClick")
        
        mwebview.removeObserver(self, forKeyPath: "estimatedProgress")
        
        webDelegate.delegate = nil
        webDelegate.controller = nil
        webDelegate.webview = nil
        
        mwebview.uiDelegate = nil
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
        webDefaultUserAgent = webview.stringByEvaluatingJavaScript(from: "navigator.userAgent")
        
        shareUrl = url?.absoluteString
        
        loadWeb()
    }
    
    fileprivate func addToolView() {
        
        toolView = WebToolView(frame: CGRect(x: 0, y: G.SCREEN_HEIGHT - 55, width: G.SCREEN_WIDTH, height: 55))
        toolView.backButton.addTarget(self, action: #selector(backToUpLevel), for: .touchUpInside)
        toolView.lastButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        toolView.nextButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        toolView.refreshButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        toolView.shareButton.addTarget(self, action: #selector(showShareView), for: .touchUpInside)
        
        view.insertSubview(toolView, aboveSubview: placeHolderView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mprogressView.progress = 0.0
        mwebview.load(URLRequest(url: URL(string: "about:blank")!))
        
        shouldRefresh = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.stopSpoofingUserAgent()
        
        shouldRefresh = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if shouldRefresh {
            if mwebview != nil && url?.absoluteString.characters.count != 0 {
                loadWeb()
            }
            shouldRefresh = false
        }
        
        edgesForExtendedLayout = []
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
        toolView.lastButton.isEnabled = mwebview.canGoBack
        toolView.lastButton.setImage(UIImage(named:mwebview.canGoBack ? "v1_web_last_yes" : "v1_web_last_no"), for:.normal)
        
        //下一页
        toolView.nextButton.isEnabled = mwebview.canGoForward
        toolView.nextButton.setImage(UIImage(named: mwebview.canGoForward ? "v1_web_next_yes" : "v1_web_next_no"), for:.normal)
        
        toolView.refreshButton.setImage(UIImage(named: mwebview.isLoading ? "v1_web_stop" : "v1_web_refresh"), for:.normal)
        
        if mwebview.isLoading {
            toolView.refreshButton.removeTarget(self, action: #selector(reload), for: .touchUpInside)
            toolView.refreshButton.addTarget(self, action: #selector(stopLoading), for: .touchUpInside)
        } else {
            toolView.refreshButton.removeTarget(self, action: #selector(stopLoading), for: .touchUpInside)
            toolView.refreshButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        }
    }
    
    func showShareView() {
        
    }
}

//MARK: - web 相关
extension BaseWebViewController {
    
    fileprivate func load404Web() {
        webviewConfig()
        
        let htmlPath = Bundle.main.path(forResource: "404", ofType: "html")
        let htmlContent = try! String(contentsOfFile: htmlPath!, encoding: String.Encoding.utf8)
        mwebview!.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    fileprivate func loadWeb() {
        
        let urlStr = WebViewDeleClass.configUrl(url?.absoluteString)!
        
        guard let urlToLoad = URL(string: urlStr) else {
            G.showMessage("链接不可用")
            return
        }
        
        gifNotiLabel.text = "正在为您打开页面"
        
        startLoadGif()
        
        WebViewDeleClass.configIOS8UserAgent(url: urlToLoad, userAgent: webDefaultUserAgent ?? "")
        
        webviewConfig()
        
        WebViewDeleClass.configIOS9UA(webview: self.mwebview!, url: urlToLoad, userAgent: webDefaultUserAgent ?? "")
        
        let curRequest = WebViewDeleClass.request(url: urlToLoad)
        self.mwebview.load(curRequest)
    }
    
    fileprivate func webviewConfig() {
        if mwebview == nil {
            webDelegate = WebViewDeleClass()
            webDelegate!.controller = self
            webDelegate!.delegate = self
            webDelegate!.webDefaultUserAgent = webDefaultUserAgent ?? ""
            webDelegate!.canOpenAnotherView = false
            
            mwebview = WebViewDeleClass.webView(frame: CGRect(x: 0, y: 0, width: G.SCREEN_WIDTH, height: G.SCREEN_HEIGHT - 55 - 64), webDelegate: webDelegate!)
            placeHolderView.addSubview(mwebview!)
            
            mprogressView.isHidden = false
            mprogressView.trackTintColor = UIColor.clear
            mprogressView.progressTintColor = UIColor(hex:0xFD6534)
            
            mwebview!.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
}

//MARK: - WEB DELEGATE
extension BaseWebViewController: WebViewDelegate {
    
    func web(_ webview: WKWebView, didStartProvisionalNavigation navigation:WKNavigation?) {
        updateBottomButtons()
    }
    
    func web(_ webview: WKWebView, didFinish navigation:WKNavigation?) {
        stopLoadGif()
        updateBottomButtons()
    }
    
    func web(_ webview: WKWebView, didFail navigation: WKNavigation?, withError error: Error) {
        stopLoadGif()
        
        let err = error as NSError
        if err.domain == "NSURLErrorDomain" && err.code != NSURLErrorCancelled {
            
        }
        
        if webview.url?.absoluteString == url?.absoluteString && err.code != NSURLErrorCancelled {
            
        }
        
        updateBottomButtons()
    }
    
    //调起登录页面
    func toLoginViewcontroller() -> Void {
        
    }
}

//MARK: - 加载动画
extension BaseWebViewController {
    //开始动画
    fileprivate func startLoadGif() {
        stopLoadGif()
        
        loadGifView.isHidden = false
        
        var array: [UIImage] = []
        for i in 1 ... 32 {
            array.append(UIImage(named: "Topic_Load_\(i)")!)
        }
        
        gifImgView.animationImages = array
        gifImgView.animationDuration = Double(array.count) * 0.1
        gifImgView.startAnimating()
        
        loadGifTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(stopLoadGif), userInfo: nil, repeats: false)
    }
    
    //结束动画
    func stopLoadGif() {
        if let timer = loadGifTimer, timer.isValid {
            timer.invalidate()
        }
        
        loadGifTimer = nil
        
        gifImgView.stopAnimating()
        gifImgView.animationImages = nil
        loadGifView.isHidden = true
    }
}

//MARK: - 进度条处理
extension BaseWebViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let web = object as? WKWebView,  web == mwebview, let path = keyPath, path == "estimatedProgress" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        updateProgressBar(mwebview.estimatedProgress)
    }
    
    func updateProgressBar(_ value: Double?) {
        guard let progress = value else {
            return
        }
        
        if progress == 1.0 {
            mprogressView.setProgress(Float(progress), animated: true)
            
            UIView.animate(withDuration: 1.5, animations: {
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
