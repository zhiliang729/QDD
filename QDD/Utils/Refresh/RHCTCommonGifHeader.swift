//
//  RHCTCommonGifHeader.swift
//  rhct_ios
//
//  Created by RHCT on 2017/1/3.
//  Copyright © 2017年 rhct. All rights reserved.
//

import UIKit
import MJRefresh

class RHCTCommonGifHeader: MJRefreshGifHeader {
    //MARK: - 重写方法
    //MARK: 在这里做一些初始化配置（比如添加子控件）
    override func prepare() {
        super.prepare()
        
        // 设置控件的高度   gif图高度加上70
        mj_h = 54
        
        // 隐藏时间 隐藏状态
        lastUpdatedTimeLabel.isHidden = true
        stateLabel.isHidden = true
    }

    override func endRefreshing() {
        //延迟500毫秒再返回
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.microseconds(500)) {
            super.endRefreshing()
        }
    }

}
