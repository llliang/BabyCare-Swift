//
//  Serializable
//  BabyCare
//
//  Created by Neo on 2017/12/13.
//  Copyright © 2017年 JiangLiang. All rights reserved.
//

import Foundation
import SQLite

protocol Serializable: Codable {
    init();
    func serializable() -> String?
    func reserve(data: String?) -> Self?
}

extension Serializable {
    func serializable() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let x = try! String.init(data: encoder.encode(self), encoding: .utf8)
        return x
    }
    
    func reserve(data: String?) -> Self? {
        if data == nil {
            return nil
        }
        let decoder = JSONDecoder()
        return try! decoder.decode(Self.self, from: (data?.data(using: .utf8)!)!)
    }
}

extension Array: Serializable{
    
}

extension Dictionary: Serializable {
    
}

