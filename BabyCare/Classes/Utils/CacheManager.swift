//
//  CacheManager.swift
//  BabyCare
//
//  Created by Neo on 2017/12/1.
//  Copyright © 2017年 JiangLiang. All rights reserved.
//

import Foundation
import SQLite


class CacheManager {
    
    static let manager = CacheManager()
    fileprivate let _table = Table("cacheData")
    fileprivate let _key = Expression<String>("key")
    fileprivate let _data = Expression<String>("data")
    fileprivate let _expiry = Expression<Date?>("expiry")
    
    var _db: Connection!
    init() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        print(path)
        do {
            _db = try Connection("\(path)/db.sqlite3")
            
        } catch let error as NSError{
            print("initialize CacheManager Error \(error.localizedDescription)")
        }
        self.createTable()
        self.clearExpiryCache()
    }
    
    private func createTable() {
        
        _ = try? _db.run(_table.create(block: { (t) in
            t.column(_key, primaryKey: true)
            t.column(_data)
            t.column(_expiry)
        }))
    }
    
    private func clearExpiryCache() {

        let datas = _table.filter(_expiry < Date().datetime)
        _ = try? _db.run(datas.delete())
    }
    
    func setCache<T: Serializable>(cache: T?, forKey key: String) -> Void {
        let data = cache?.serializable();
        let insert = _table.insert(_key <- key , _data <- data!, _expiry <- Date(timeIntervalSinceNow: 30*24*60*60).datetime)
        _ = try? _db.run(insert)
    }
    
    func cacheForKey<T: Serializable>(_ key: String) -> T? {
        for row in try! _db.prepare(_table.filter(_key == key)) {
            let data = try! row.get(_data)
            let t = T();
            return t.reserve(data:data);
        }
        return nil
    }
    
    func containCache(key: String) -> Bool {
        for _ in try! _db.prepare(_table.filter(_key == key)) {
            return true
        }
        return false
    }
    
    func removeCache(key: String) {
        let datas = _table.filter(_key == key)
        _ = try? _db.run(datas.delete())
    }
    
    func clearCache() {
        _ = try? _db.run(_table.drop())
    }
}

