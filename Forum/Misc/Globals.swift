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

func updateCountingLabel(label: UILabel, text: String, lineLimit: Int, charLimit: Int) {
    let lc = text.linebreaks, cc = text.count
    let line = NSAttributedString(string: "\(lc)/\(lineLimit) 行\t", attributes: [NSAttributedString.Key.foregroundColor: lc > lineLimit ? UIColor.red : UIColor.gray])
    let char = NSMutableAttributedString(string: "\(cc)/\(charLimit) 字", attributes: [NSAttributedString.Key.foregroundColor: cc > charLimit ? UIColor.red : UIColor.gray])
    if lineLimit > 1 {
        char.insert(line, at: 0)
    }
    label.attributedText = char
}

extension UIButton {
    
    func setDropDownStyle(fontSize: CGFloat = 12) {
        self.contentHorizontalAlignment = .right
        self.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        self.setImage(UIImage(systemName: "chevron.compact.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
        self.semanticContentAttribute = .forceRightToLeft
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
    }
    
}

class CheckerButton: UIButton {
    
    var checked = false {
        didSet {
            self.setImage(UIImage(systemName: checked ? "checkmark.square" : "squareshape", withConfiguration: UIImage.SymbolConfiguration(scale: .small)), for: .normal)
        }
    }
    
    func setCheckBoxStyle(fontSize: CGFloat = 12) {
        self.contentHorizontalAlignment = .right
        self.setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        self.semanticContentAttribute = .forceRightToLeft
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        self.titleLabel!.font = UIFont.systemFont(ofSize: fontSize)
        self.addTarget(self, action: #selector(checked(_:)), for: .touchUpInside)
        checked = false
    }
    
    @objc func checked(_ sender: UIButton) {
        checked = !checked
    }
    
}
