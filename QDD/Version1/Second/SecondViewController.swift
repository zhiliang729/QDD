//
//  SecondViewController.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import MJRefresh

class SecondViewController: BaseTabItemViewController {

    @IBOutlet weak var mtableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let header = MJRefreshNormalHeader()
        mtableview.mj_header = header
        
        let footer = MJRefreshFooter()
        mtableview.mj_footer = footer
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
