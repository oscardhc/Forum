//
//  Globals.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import Foundation
import UIKit

class G {
    
    static var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyaWQiOiIyM2EzMDhiNjgxYTIwYjQ5YjlmYzFiNzA0MjdlNWNmNjQyMTAyMDdmMDQwZWZiZTEyZGViZDYxM2VmZDJlMGI5IiwiZGV2aWNlaWQiOiI5QjAwODJDQy1DQjY3LTQ4OUItOTIwOS05RjFBNkQzRDY0QjUiLCJpYXQiOjE2MDUxNjQzMzYsImV4cCI6MTYwNzc1NjMzNn0.Qk9q5MnKlhvEOETSJ57QyDvv8nEKtChtd8WSV16Njvw"
//    static var token = ""
    static let numberPerFetch = 8
    
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

extension UIView {
    func applyCardStyle() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.gray.cgColor
    }
}

extension UIViewController {
    
    static func >> (_ vc: UIViewController, _ to: UIViewController) {
        vc.navigationController?.pushViewController(to, animated: true)
    }
    
    static func << (_ vc: UIViewController, _ to: UIViewController) {
        vc.present(to, animated: true, completion: nil)
    }
    
}

public func Init<Type>(_ value: Type, _ block: (_ object: Type) -> Void) -> Type
{
    block(value)
    return value
}
