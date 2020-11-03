//
//  Globals.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import Foundation
import UIKit
import GTMRefresh

class G {
    
    static let bottomDelta: CGFloat = 0
    static var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyaWQiOiIyM2EzMDhiNjgxYTIwYjQ5YjlmYzFiNzA0MjdlNWNmNjQyMTAyMDdmMDQwZWZiZTEyZGViZDYxM2VmZDJlMGI5IiwiZGV2aWNlaWQiOiJDRDAwNTMwMS02RDlDLTQ2MEMtOUZBNS03RjZGRTRBQzkwMzUiLCJpYXQiOjE2MDMxNzU3NDIsImV4cCI6MTYwNTc2Nzc0Mn0.BqAbK7QDOOhR-IYl-PJI3lYDY8Lyd1fXbx4ERrA9jmQ"
//    static var token = ""
    
    static var hasLoggedIn: Bool {token != ""}
    
}

func sugar<T>(_ content: (cond: () -> Bool, value: () -> T)...) -> T {
    for c in content {
        if c.cond() {
            return c.value()
        }
    }
    return content.last!.value()
}

prefix operator *

extension String {
    static prefix func * (name: String) -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: name)
    }
}