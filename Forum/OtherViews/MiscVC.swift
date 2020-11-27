//
//  AboutViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

protocol ProvideContent {
    var content: [[(title: String, fun: () -> Void)]] { get }
}

class BaseTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ProvideContent {
    
    var _tableView: UITableView! { nil }
    var content: [[(title: String, fun: () -> Void)]] { [] }
    var cellName: String { "" }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        cell.textLabel?.text = content[indexPath.section][indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        content[indexPath.section][indexPath.row].fun()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.tableFooterView = UIView(frame: CGRect.zero)
        _tableView.contentInsetAdjustmentBehavior = .always
    }
    
    func deselect() {
        if let selectionIndexPath = self._tableView.indexPathForSelectedRow {
            self._tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselect()
    }
    
}

class MiscVC: BaseTableVC, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var misc_content: [[(title: String, fun: () -> Void)]] = [
        [
            ("通知", {self >> MainVC.new(.messages)}),
            ("收藏", {self >> MainVC.new(.favour)})
        ],
        [
            ("我的帖子", {self >> MainVC.new(.my)})
        ],
        [
            ("设置", {self >> *"SettingVC"}),
            ("反馈", {self >> *"ReportVC"}),
            ("关于", {self << (*"AboutVC" as! AboutVC).withFather(self)})
        ]
    ]
    override var content: [[(title: String, fun: () -> Void)]] { misc_content }
    override var cellName: String { "MiscCell" }
    override var _tableView: UITableView! { tableView }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
}

class SettingVC: BaseTableVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var setting_content: [[(title: String, fun: () -> Void)]] = [
        [
            ("Network Stat", {self >> *"TokenVC"})
        ],
        [
            ("退出登录", {
                G.token.content = ""
                self.showAlert("成功退出登录，App即将关闭", style: .success) {
                    Util.halt()
                }
            })
        ]
    ]
    override var content: [[(title: String, fun: () -> Void)]] { setting_content }
    override var cellName: String { "SettingCell" }
    override var _tableView: UITableView! { tableView }
    
}

class TokenVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let d = G.networkStat.content
        textView.text = "Failed: \(Int(d[4]))\n Average: \(d[0] / d[1])ms\n Min: \(d[2])ms\n Max: \(d[3])ms"
        
    }
    
}

class ReportVC: UIViewController {
    
    @IBOutlet weak var threadID: DarkSupportTextField!
    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func report(_ sender: Any) {
        if (threadID.text ?? "") != "", textView.text != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showAlert("反馈成功", style: .success)
            }
        } else {
            showAlert("请输入反馈内容", style: .warning)
        }
    }
    
    
}

class TermVC: UIViewController {
    
    @IBOutlet weak var checker: CheckerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checker.setCheckBoxStyle(fontSize: 14)
        checker.semanticContentAttribute = .forceLeftToRight
        checker.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        checker.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    }
    
    @IBAction func confirm(_ sender: Any) {
        if checker.checked {
            showAlert("欢迎来到无可奉告", style: .success) {
                let vc = *"LoginVC"
                vc.modalPresentationStyle = .fullScreen
                self << vc
            }
        } else {
            showAlert("请同意用户协议", style: .warning)
        }
    }
    
}
