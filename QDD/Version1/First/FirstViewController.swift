//
//  FirstViewController.swift
//  QDD
//
//  Created by RHCT on 2016/11/23.
//  Copyright © 2016年 RHCT. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FirstViewController: BaseTabItemViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func request(_ sender: UIButton) {
        _ = Alamofire.request("https://api.hothuati.com/account/login/", method: HTTPMethod.post, parameters: ["account": "13810720431", "password": "qweree"], encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: { (response) in
            debugPrint("request " + response.request.debugDescription)
            debugPrint("response " + response.response.debugDescription)
            debugPrint("result data " + response.data.debugDescription)
            debugPrint("result " + response.result.debugDescription)
                
            switch response.result {
            case .success(let _):
                
                break
            case .failure(let error):
                if let err = error as? AFError {
                    
                    switch err {
                    case .invalidURL(let url):
                        break
                    case .multipartEncodingFailed(let reason):
                        break
                    case .parameterEncodingFailed(let reason):
                        break
                    case .responseValidationFailed(let reason):
                        if let data = response.data {
                            let json = JSON(data: data)
                            debugPrint(json.dictionaryValue)
                        }
                        break
                    case .responseSerializationFailed(let reason):
                        break
                    }
                    
                } else {
                    let err = error as NSError
                    debugPrint("error: " + err.debugDescription)
                }
                
                
                
                break
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
