//
//  StartHelpView.swift
//  QDD
//
//  Created by RHCT on 2016/12/1.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import Kingfisher

public class StartHelpView: UIView {
    
    var enterAppHandler: (() -> Void)?
    
    fileprivate var scrollview: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: G.SCREEN_WIDTH, height: G.SCREEN_HEIGHT))
    fileprivate var enterAppButton: UIButton?
    fileprivate var defaultImgView: UIImageView = UIImageView(frame: .zero)
    fileprivate var iconView: UIImageView = UIImageView(frame: .zero)
    fileprivate var timer: Timer?
    deinit {
        
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        scrollview.isPagingEnabled = true
        scrollview.bounces = false
        scrollview.showsHorizontalScrollIndicator = false
        scrollview.showsVerticalScrollIndicator = false
        addSubview(scrollview)
        
        var imgName = "Introduce_bgIcon"
        if G.SCREEN_WIDTH - 320 < 1 {
            imgName = "Introduce_bgIcon_320"
        }
        
        let image = UIImage(named: imgName)!
        iconView.frame = CGRect(x: 0, y: G.SCREEN_HEIGHT - image.size.height, width: image.size.width, height: image.size.height)
        iconView.image = image
        iconView.isHidden = false
        addSubview(iconView)
    }
    
    func configDefaultImg() {
        
        
        if let timer = timer, timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
        
        var startImgName = "Start_up"
        if G.SCREEN_HEIGHT - 480 < 1 {
            startImgName = "Start_up_480"
        }
        
        var introImg = UIImage(named: startImgName)!
        let height = G.SCREEN_WIDTH * introImg.size.height / introImg.size.width
        
        if let screen = SplashScreen.validScreen(),
            let url = screen.imageUrl,
            let img = ImageCache.default.retrieveImageInDiskCache(forKey: url) {
             introImg = img
        }
        
        defaultImgView.frame = CGRect(x: 0, y: 0, width: G.SCREEN_WIDTH, height: height)
        defaultImgView.contentMode = .redraw
        defaultImgView.image = introImg
        defaultImgView.alpha = 0
        addSubview(defaultImgView)
        bringSubview(toFront: iconView)
        
        UIView.animate(withDuration: 0.3) {
            self.defaultImgView.alpha = 1.0
        }
        
        perform(#selector(defaultViewFrameAnimation), on: .main, with: nil, waitUntilDone: false)
    }
    
    func defaultViewFrameAnimation() {
        perform(#selector(hiddenView), with: nil, afterDelay: 3)
    }
    
    func hiddenView() {
        if UserDefaults.standard.bool(forKey: UserDefaults.Key.AlreadyShowStartHelp) {
            UIView.animate(withDuration: 0.5, animations: {
                self.defaultImgView.alpha = 0.5
            }, completion: { (finish) in
                self.iconView.isHidden = true
                self.defaultImgView.isHidden = true
                self.enterApp()
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.defaultImgView.alpha = 0.5
            }, completion: { (finish) in
                self.iconView.isHidden = true
                self.defaultImgView.isHidden = true
                self.showNext()
            })
        }
    }
    
    func enterApp() {
        UserDefaults.standard.set(true, forKey: UserDefaults.Key.AlreadyShowStartHelp)
        enterAppHandler?()
    }
    
    func showNext() {
        var allShowImg: [String] {
            var array: [String] = []
            
            if G.SCREEN_HEIGHT - 480 < 1 {
                array.append(contentsOf: ["v4_start_4_1", "v4_start_4_2", "v4_start_4_3"])
            } else {
                array.append(contentsOf: ["v4_start_1", "v4_start_2", "v4_start_3"])
            }
            
            return array
        }
        
        func addImg(rect: CGRect, image name: String) -> UIImageView {
            let imgView = UIImageView(frame: rect)
            imgView.backgroundColor = UIColor.clear
            imgView.image = UIImage(named: name)
            scrollview.addSubview(imgView)
            return imgView
        }
        
        scrollview.contentSize = CGSize(width: G.SCREEN_WIDTH * CGFloat(allShowImg.count), height: frame.size.height)
        var x: CGFloat = 0
        
        for i in 0 ..< allShowImg.count {
            let name = allShowImg[i]
            
            let imageview = addImg(rect: CGRect(x: x, y: 0, width: G.SCREEN_WIDTH, height: G.SCREEN_HEIGHT), image: name)
            imageview.tag = 100 + i
            x += G.SCREEN_WIDTH
            
            if i == allShowImg.count - 1 {
                
                var height: CGFloat = 60
                
                if G.SCREEN_HEIGHT == 480 {
                    height = 60
                } else if G.SCREEN_HEIGHT == 568 {
                    height = 85
                } else if G.SCREEN_HEIGHT == 667 {
                    height = 95
                } else if G.SCREEN_HEIGHT == 736 {
                    height = 79
                } else if G.SCREEN_HEIGHT > 736 {
                    height = 79
                }
                
                imageview.isUserInteractionEnabled = true
                
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: (G.SCREEN_WIDTH - 147) / 2.0, y: G.SCREEN_HEIGHT - height, width: 147, height: 40)
                button.backgroundColor = UIColor.clear
                button.addTarget(self, action: #selector(enterApp), for: .touchUpInside)
                imageview.addSubview(button)
            }
        }
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    public func show() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(outOfTime), userInfo: nil, repeats: false)
        timer?.fireDate = Date(timeIntervalSinceNow: 2)
        
        G.getScreen { (result) in
            if let timer = self.timer, timer.isValid {
                self.perform(#selector(self.configDefaultImg), on: .main, with: nil, waitUntilDone: false)
            }
        }
    }
    
    func outOfTime() {
        configDefaultImg()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
