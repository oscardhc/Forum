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
    
    static let formatter = DateFormatter()..{
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    static func dateToString(_ date: Date) -> String {
        formatter.string(from: date)
    }
    
    static let trans: [((DateComponents) -> Int?, String)] = [
        ({$0.year}, "年"), ({$0.month}, "月"), ({$0.day}, "天"), ({$0.hour}, "小时"), ({$0.minute}, "分钟")
    ]
    
    static func dateToDeltaString(_ date: Date) -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: Date())
        for (f, s) in trans {
            if let n = f(interval), n > 0 {
                return "\(n)\(s)前"
            }
        }
        return "刚刚"
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

@discardableResult func with<T>(_ value: T, _ block: (T) -> Void) -> T
{
    block(value)
    return value
}

final class Action {
    private let _action: () -> ()
    init(_ action: @escaping () -> ()) { _action = action; }
    @objc func action() { _action() }
}

precedencegroup LowestPrecedence {
    associativity: left
    lowerThan: AssignmentPrecedence
}
infix operator ..: MultiplicationPrecedence

@discardableResult func .. <T>(_ lhs: T, _ rhs: (T) -> Void) -> T {
    rhs(lhs)
    return lhs
}
@discardableResult func .. <T, K>(_ lhs: (T, K), _ rhs: (T, K) -> Void) -> (T, K) {
    rhs(lhs.0, lhs.1)
    return lhs
}
@discardableResult func .. <T, K>(_ lhs: T, _ rhs: KeyPath<T, K>) -> K {
    return lhs[keyPath: rhs]
}

infix operator => : LowestPrecedence
func => (_ lhs: @autoclosure () -> Bool, _ rhs: @autoclosure () -> Void) {
    if lhs() { rhs() }
}
func => (_ lhs: @autoclosure () -> Bool, _ rhs: () -> Void) {
    if lhs() { rhs() }
}
func => (_ lhs: () -> Bool, _ rhs: () -> Void) {
    if lhs() { rhs() }
}
func += (_ lhs: UIView, _ rhs: UIView) {
    lhs.addSubview(rhs)
}

prefix operator *
prefix func * (block: @escaping () -> ()) -> Selector {
    #selector(Action(block).action)
}

precedencegroup SecondaryTernaryPrecedence {
    associativity: right
    higherThan: TernaryPrecedence
    lowerThan: LogicalDisjunctionPrecedence
}
infix operator ?> : SecondaryTernaryPrecedence
infix operator ?< : TernaryPrecedence

func ?> <T>(lhs: @autoclosure () -> Bool, rhs: @escaping @autoclosure () -> T) -> (Bool, () -> T) { return (lhs(), rhs) }
func ?> <T>(lhs: () -> Bool, rhs: @escaping () -> T) -> (Bool, () -> T) { return (lhs(), rhs) }
@discardableResult func ?< <T>(lhs: (Bool, () -> T), rhs: @escaping @autoclosure () -> T) -> T { lhs.0 ? lhs.1() : rhs() }
@discardableResult func ?< <T>(lhs: (Bool, () -> T), rhs: @escaping () -> T) -> T { lhs.0 ? lhs.1() : rhs() }

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
    case aliceAndBob = "abc", usPresident = "us_president", tarot = "tarot"
    static let displayName = [
        aliceAndBob: "Alice and Bob", usPresident: "US President", tarot: "Tarot"
    ]
    static let list: [NameTheme: [String]] = [
        .aliceAndBob: ["Alice", "Bob", "Carol", "Dave", "Eve", "Forest", "George", "Harry", "Issac", "Justin", "Kevin", "Laura", "Mallory", "Neal", "Oscar", "Pat", "Quentin", "Rose", "Steve", "Trent", "Utopia", "Victor", "Walter", "Xavier", "Young", "Zoe"],
        .usPresident: ["Washington", "J.Adams", "Jefferson", "Madison", "Monroe", "J.Q.Adams", "Jackson", "Buren", "W.H.Harrison", "J.Tyler", "Polk", "Z.Tylor", "Fillmore", "Pierce", "Buchanan", "Lincoln", "A.Johnson", "Grant", "Hayes", "Garfield", "Arthur", "Cleveland", "B.Harrison", "McKinley", "T.T.Roosevelt","Taft", "Wilson", "Harding", "Coolidge", "Hoover", "F.D.Roosevelt", "Truman", "Eisenhower", "Kennedy", "L.B.Johnson", "Nixon", "Ford", "Carter", "Reagan", "G.H.W.Bush", "Clinton","G.W.Bush", "Obama", "Trump"],
//        .tarot: ["愚者", "魔术师", "女祭司", "皇后", "皇帝", "教皇", "恋人", "战车", "力量", "隐者", "命运之轮", "正义", "倒吊人", "死神", "节制", "恶魔", "塔", "星星", "月亮", "太阳", "审判", "世界"]
        .tarot: ["The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Justice", "The Hermit", "Wheel of Fortune", "Strength", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"]
    ]
    var displayText: String {Self.displayName[self]!}
}

enum ColorTheme: ProvideList {
    case cold
    static let list: [ColorTheme : [UIColor]] = [
        .cold: [0x5ebd3e, 0xffb900, 0xf78200, 0xe23838, 0x973999, 0x009cdf]
    ].mapValues {
        $0.map {
            UIColor(argb: $0 + (0xc0 << 24))
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

extension String {
    static prefix func * (name: String) -> UIViewController {
        UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(identifier: name)
    }
    
    var linebreaks: Int {
        self.reduce(1) {
            $0 + ($1 == "\n" ? 1 : 0)
        }
    }
}

extension UIViewController {
    static func >> (_ vc: UIViewController, _ to: UIViewController) {
        vc.navigationController?.pushViewController(to, animated: true)
    }
    
    static func << (_ vc: UIViewController, _ to: UIViewController) {
        vc.present(to, animated: true, completion: nil)
    }
    
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

func dealWithURLContext(_ urlContext: UIOpenURLContext) -> String? {
    let url = urlContext.url.absoluteString.replacingOccurrences(of: "wkfg://", with: "")
    print("url = \(url)")
    
    if let i = Int(url), i >= 1, i < 1000000 {
        return url
    } else {
        return nil
    }
}

extension UIBarButtonItem {
    
    static func imgItem(_ image: UIImage?, action: @autoclosure () -> Selector, to vc: UIViewController) -> UIBarButtonItem {
        UIBarButtonItem(customView: UIButton(frame: CGRect(x: 0, y: 0, width: image!.width, height: image!.height))..{
            $0.setBackgroundImage(image, for: .normal)
            $0.addTarget(vc, action: action(), for: .touchUpInside)
        })
    }
    
    func setImageTo(_ image: UIImage?) {
        (customView as! UIButton).setBackgroundImage(image, for: .normal)
    }
    
}

// MARK: - View Style

extension UIView {
    func applyCardStyle(clip: Bool = false) {
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 7
        self.layer.masksToBounds = clip
        self.layer.backgroundColor = UIColor.tertiarySystemBackground.cgColor
//        if traitCollection.userInterfaceStyle != .dark {
//            self.layer.shadowColor = UIColor.label.cgColor
//            self.layer.shadowOffset = CGSize(width: 0, height: 1);
//            self.layer.shadowOpacity = 0.1
//            self.layer.shadowRadius = 2
//            self.layer.borderColor = UIColor.systemBackground.cgColor
//        }
    }
    func applyShadow(opaque: Bool = true, offset: Double = 4, opacity: Float = 0.05) {
        if traitCollection.userInterfaceStyle == .dark {
            return
        }
        opaque => self.layer.backgroundColor = UIColor.systemBackground.cgColor
        self.layer.shadowColor = UIColor.label.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: offset);
        self.layer.shadowOpacity = opacity
    }
}

extension UILabel {
    func setAsTagLabel(_ t: String) -> Self {
        text = t
        fontSize = 14
        textColor = .white
        textAlignment = .center
        layer.cornerRadius = 5
        layer.backgroundColor = UIColor(rgb: 0x018786).cgColor
        return self
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
    func setAndHideAlert(_ bar: MBProgressHUD, _ message: String, style: AlertStyle, duration: TimeInterval = 0.8, completion: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            bar.mode = .customView
            bar.customView = BiggerImageView(image: UIImage(systemName: style.rawValue, withConfiguration: UIImage.SymbolConfiguration(scale: .large)))
            bar.label.text = message
            bar.completionBlock = completion
            bar.hide(animated: true, afterDelay: duration)
        }
    }
    func showAlert(_ message: String, style: AlertStyle, duration: TimeInterval = 0.8, completion: @escaping () -> Void = {}) {
        setAndHideAlert(MBProgressHUD.showAdded(to: self.view, animated: true), message, style: style, duration: duration, completion: completion)
    }
    func networkFailure(completion: @escaping () -> Void = {}) {
        showAlert("网络错误", style: .failure, completion: completion)
    }
    func showProgress() -> MBProgressHUD {
        MBProgressHUD.showAdded(to: self.view, animated: true)..{
            $0.mode = .indeterminate
        }
    }
}
