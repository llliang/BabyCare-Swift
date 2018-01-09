//
//  JDataModel.swift
//  BabyCare
//
//  Created by Neo on 2017/12/22.
//  Copyright © 2017年 JiangLiang. All rights reserved.
//

import Foundation
import Alamofire

protocol DataModelHttpProtocol {
    
    func loadData(success: @escaping((_ result: Any?,_ error: Error?) -> (Void)))
    
    var parameters: Dictionary<String, String>? {get}
    var url: String? {get}
    var method: HTTPMethod {get}
}

extension DataModelHttpProtocol {

    var fetchLimited: Int? {
        return 20
    }
    var method: HTTPMethod {
        return .get
    }
}

class DataModel<T: Serializable>: DataModelHttpProtocol {
    
    var fetchLimited = 20
    
    var canLoadMore = true
    
    var loading = false
    var isReload = false
    
    var page = 0
    var code: Int = -1000
    
    var data: Serializable?
    
    var parameters: Dictionary<String, String>? {
        return [:]
    }
    var url: String? {
        return ""
    }
    
    func loadData(success: @escaping((Any?, Error?) -> Void)) {
        self.loading = true
        JHttpManager.requestAsynchronous(url: "", method: .get, parameters: parameters) { (result, error) -> (Void) in
            self.loading = false
            
            self.canLoadMore = false
            
            let res = result as! Dictionary<String, Any?>
            self.code = res["code"] as! Int
            
            let tmpData = res["data"] as? Serializable
            if tmpData is Array<Any> {
                var datas = tmpData as! Array<Any>
               
                var translations = Array<Serializable>()
                for item in datas {
                    let i = item as! Serializable
                    let t = T()
                    translations.append(t.reserve(data: i.serializable())!)
                }
                
                datas = translations
                if datas.count >= self.fetchLimited {
                    self.canLoadMore = true
                }
                
                if !self.isReload {
                    var oldDatas = self.data as! Array<Any>
                    oldDatas.append(contentsOf: datas)
                } else {
                    self.data = datas
                }
                
            } else if tmpData is Dictionary<String, Any> {
                let t = T()
                self.data = t.reserve(data: tmpData?.serializable())
            } else {
                self.data = tmpData
            }
            success(self.data, error)
        }
    }
}
