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

class G {
    
    static var token: String {
        get {
            UserDefaults.standard.string(forKey: "ForumUserToken") ?? ""
        }
        set(val) {
            UserDefaults.standard.setValue(val, forKey: "ForumUserToken")
            print("set to: ", val)
            print(UserDefaults.standard.string(forKey: "ForumUserToken"))
        }
    }
    static let numberPerFetch = 8
    
    static var hasLoggedIn: Bool {token != ""}
}


