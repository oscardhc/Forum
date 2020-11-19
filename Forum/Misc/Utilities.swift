//
//  Utilities.swift
//  Forum
//
//  Created by Oscar on 2020/10/20.
//

import Foundation
import UIKit
import MBProgressHUD
import Material
import DropDown

class Util {
    
    static let formatter =  Init(DateFormatter()) {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    static func dateToString(_ date: Date) -> String {
        formatter.string(from: date)
    }
    
    static let trans: [((DateComponents) -> Int?, String)] = [
        ({$0.year}, "year"), ({$0.month}, "month"), ({$0.day}, "day"), ({$0.hour}, "hour"), ({$0.minute}, "minute")
    ]
    
    static func dateToDeltaString(_ date: Date) -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: Date())
        for (f, s) in trans {
            if let n = f(interval), n > 0 {
                return "\(n) \(s)\(n > 1 ? "s" : "") ago"
            }
        }
        return "just now"
    }
    
    static func stringToDate(_ string: String) -> Date {
        formatter.date(from: string)!
    }
    
    static func halt() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
    
}

class DarkSupportTextField: TextField {
    override func prepare() {
        super.prepare()
        textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
    }
}

public func Init<Type>(_ value: Type, _ block: (_ object: Type) -> Void) -> Type
{
    block(value)
    return value
}

// MARK: - Generator

extension Array {
    mutating func shuffle(seed s: Int) {
        let random = RandomN(s)
        for i in 1..<count {
            swapAt(i, random.next() % (i + 1))
        }
    }
}

class RandomN {
    var seed, a, b: Int
    init(_ s: Int) {(seed, a, b) = (s, s, 19260817)}
    
    func next() -> Int {
        if seed == 0 {
            a += 1
            return a
        } else {
            var t = a, s = b
            a = s
            t ^= t << 23;
            t ^= t >> 17;
            t ^= s ^ (s >> 26);
            b = t
            return (s &+ t) & (Int.max) // allow overflow
        }
    }
}

protocol ProvideList: Hashable {
    associatedtype T
    static var list: [Self: [T]] { get }
}

class Generator<K: Hashable & ProvideList> {
    var vals: [K.T]
    
    init(theme t: K, seed s: Int) {
        vals = K.list[t]!
        vals.shuffle(seed: s)
    }
    subscript(i: Int) -> K.T {
        vals[i % vals.count]
    }
}


enum NameTheme: String, CaseIterable, ProvideList {
    case aliceAndBob = "abc", usPresident = "us_president"
    static let displayName = [
        aliceAndBob: "Alice and Bob", usPresident: "US President"
    ]
    static let list: [NameTheme: [String]] = [
        .aliceAndBob: ["Alice", "Bob", "Carol", "Dave", "Eve", "Forest", "George", "Harry", "Issac", "Justin", "Kevin", "Laura", "Mallory", "Neal", "Oscar", "Pat", "Quentin", "Rose", "Steve", "Trent", "Utopia", "Victor", "Walter", "Xavier", "Young", "Zoe"],
        .usPresident: ["Washington", "J.Adams", "Jefferson", "Madison", "Monroe", "J.Q.Adams", "Jackson", "Buren", "W.H.Harrison", "J.Tyler", "Polk", "Z.Tylor", "Fillmore", "Pierce", "Buchanan", "Lincoln", "A.Johnson", "Grant", "Hayes", "Garfield", "Arthur", "Cleveland", "B.Harrison", "McKinley", "T.T.Roosevelt","Taft", "Wilson", "Harding", "Coolidge", "Hoover", "F.D.Roosevelt", "Truman", "Eisenhower", "Kennedy", "L.B.Johnson", "Nixon", "Ford", "Carter", "Reagan", "G.H.W.Bush", "Clinton","G.W.Bush", "Obama", "Trump"]
    ]
    var displayText: String {Self.displayName[self]!}
}

enum ColorTheme: ProvideList {
    case cold
    static let list: [ColorTheme : [UIColor]] = [
        .cold: ["89e1ae", "8ad3bf", "8ec4ca", "8fb1cf", "899dd1", "7f86d3", "7a75d3", "7c67d1", "6850d0"]
    ].mapValues {
        $0.map {
            var s = Scanner(string: $0), res: UInt64 = 0
            s.scanHexInt64(&res)
            return UIColor(
                red: CGFloat(res >> 16 & 255)  / 255,
                green: CGFloat(res >> 8 & 255) / 255,
                blue: CGFloat(res & 255) / 255,
                alpha: 0.25
            )
        }
    }
}

class NameG: Generator<NameTheme> {
    override subscript(i: Int) -> String {
        i >= vals.count
            ? "\(vals[i % vals.count]).\(i / vals.count + 1)"
            : vals[i]
    }
}

class ColorG: Generator<ColorTheme> {
}

//class ColorG: Generator<Color>

// MARK: - Navigation Utilities


protocol DoubleTappable {
    func hasTappedAgain()
}

prefix operator *

extension String {
    static prefix func * (name: String) -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: name)
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

// MARK: - View Style

extension UIView {
    func applyCardStyle() {
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3);
        self.layer.shadowOpacity = 0.2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.systemBackground.cgColor
    }
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

func updateCountingLabel(label: StateLabel, text: String, lineLimit: Int, charLimit: Int) {
    let lc = text.linebreaks, cc = text.count
    let line = NSAttributedString(string: "\(lc)/\(lineLimit) 行\t", attributes: [NSAttributedString.Key.foregroundColor: lc > lineLimit ? UIColor.red : UIColor.gray])
    let char = NSMutableAttributedString(string: "\(cc)/\(charLimit) 字", attributes: [NSAttributedString.Key.foregroundColor: cc > charLimit ? UIColor.red : UIColor.gray])
    if lineLimit > 1 {
        char.insert(line, at: 0)
    }
    label.attributedText = char
    label.ok = lc <= lineLimit && cc <= charLimit
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

class StateLabel: UILabel {
    var ok = true
}

extension UIViewController {    
    class BiggerImageView: UIImageView {
        override var intrinsicContentSize: CGSize {
            image!.size.applying(.init(scaleX: 2.0, y: 2.0))
        }
    }

    enum AlertStyle: String {
        case success = "checkmark.circle", failure = "xmark.octagon", warning = "exclamationmark.triangle"
    }
    func showAlert(_ message: String, style: AlertStyle, duration: TimeInterval = 1.0, completion: @escaping () -> Void = {}) {
        let mark = MBProgressHUD.showAdded(to: self.view, animated: true)
//        mark.isUserInteractionEnabled = false
        mark.mode = .customView
        mark.customView = BiggerImageView(image: UIImage(systemName: style.rawValue, withConfiguration: UIImage.SymbolConfiguration(scale: .large)))
        mark.label.text = message
        mark.hide(animated: true, afterDelay: duration)
        mark.completionBlock = completion
    }
}
