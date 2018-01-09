//
//  JHttpManager.swift
//  BabyCare
//
//  Created by Neo on 2017/12/22.
//  Copyright © 2017年 JiangLiang. All rights reserved.
//

import Foundation
import Alamofire

struct JHttpManager {
    
    static func requestAsynchronous(url: String,method: HTTPMethod, parameters: Dictionary<String, String>?, completion:@escaping (_ data: Any?, _ error: Error?) -> (Void)) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.httpBody, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                completion(response.result.value, nil)
            } else {
                completion(response.result.value, response.result.error)
            }
        }
    }
}
