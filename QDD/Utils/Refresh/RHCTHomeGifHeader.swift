//
//  RHCTHomeGifHeader.swift
//  rhct_ios
//
//  Created by RHCT on 2017/1/3.
//  Copyright © 2017年 rhct. All rights reserved.
//

import UIKit
import MJRefresh

class RHCTHomeGifHeader: MJRefreshGifHeader {
    
    //MARK: - 重写方法
    //MARK: 在这里做一些初始化配置（比如添加子控件）
    override func prepare() {
        super.prepare()
        
        // 设置控件的高度   gif图高度加上70
        mj_h = 47 + 70
        
        // 隐藏时间 隐藏状态
        lastUpdatedTimeLabel.isHidden = true
        stateLabel.isHidden = false
        
        //title
        setTitle("下拉刷新", for: .idle)
        setTitle("松开立即刷新", for: .pulling)
        
        //状态label 配置
        stateLabel.textColor = UIColor(red: 200/250.0, green: 200/250.0, blue: 200/250.0, alpha: 1)
        stateLabel.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    //MARK: 在这里设置子控件的位置和尺寸
    override func placeSubviews() {
        super.placeSubviews()
        
        self.gifView.frame = self.bounds
        self.gifView.contentMode = .center
        self.gifView.mj_y = 0
        self.gifView.mj_w = self.mj_w * 0.5 - 90
        self.gifView.mj_x = (self.bounds.size.width - self.gifView.mj_w) / 2.0
        
        self.stateLabel.frame = CGRect(x: 0, y: 70, width: self.mj_w, height: self.mj_h * 0.55)
    }
    
    override func endRefreshing() {
        //延迟1秒再返回
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1)) {
            super.endRefreshing()
        }
    }
}
