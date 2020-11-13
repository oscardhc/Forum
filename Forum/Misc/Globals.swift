//
//  Globals.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import Foundation
import UIKit

extension String {
    var spaces: Int {
        self.reduce(0) {
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
        }
    }
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
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.systemBackground.cgColor
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
