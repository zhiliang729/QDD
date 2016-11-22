//
//  WebToolView.swift
//  Daker
//
//  Created by RHCT on 16/8/25.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit

class WebToolView: UIView {
    
    //返回
    @IBOutlet var backButton: UIButton!
    
    //上一页
    @IBOutlet var lastButton: UIButton!
    //下一页
    @IBOutlet var nextButton: UIButton!
    
    //刷新
    @IBOutlet var refreshButton: UIButton!
    //分享
    @IBOutlet var shareButton: UIButton!

    @IBOutlet private var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        NSBundle.mainBundle().loadNibNamed("WebToolView", owner: self, options: nil)
        self.view.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 55)
        addSubview(self.view)
    }
    
}
