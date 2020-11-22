//
//  Globals.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import Foundation
import UIKit

extension String {
    var linebreaks: Int {
        self.reduce(1) {
            $0 + ($1 == "\n" ? 1 : 0)
        }
    }
}

class StoredObject<T> {
    var id: String
    var nothing: () -> T
    init(_ i: String, _ n: @escaping () -> T) {
        id = i
        nothing = n
    }
    var content: T {
        get {
            (UserDefaults.standard.object(forKey: id) as? T) ?? nothing()
        }
        set(val) {
            UserDefaults.standard.setValue(val, forKey: id)
        }
    }
}

class G {
    
    static let token = StoredObject<String>("ForumUserToken", { .init() })
    static let networkStat = StoredObject<[Int]>("ForumNetworkStat", { .init() })
    static func updateStat(_ i: Int) {
        var d = G.networkStat.content
        if d == [] {
            d = Array(repeating: 0, count: 202)
        }
        d[i] += 1
        G.networkStat.content = d
    }
    static let numberPerFetch = 8
    static let blockedList = StoredObject<[String]>("ForumBlockedList", { .init() })
    
    static var hasLoggedIn: Bool {token.content != ""}
}


