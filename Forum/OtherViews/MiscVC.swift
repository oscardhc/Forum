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
        _tableView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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
            ("反馈", {self >> *"ReportVC"})
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
        [("被踩较多的帖子", {})] + Tag.allCases.map {
            ($0.rawValue, {})
        },
        [
            ("被踩较多的回复", {})
        ],
        [
            ("网络统计", {self >> *"TokenVC"}),
            ("关于", {self >> *"AboutMenuVC"}),
            ("退出登录", {
                G.token.content = ""
                self.showAlert("成功退出登录，App即将关闭", style: .success) {
                    Util.halt()
                }
            })
        ]
    ]
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! SettingCell
        cell.textLabel?.text = content[indexPath.section][indexPath.row].title
        let pr = G.viewStyle.content
        if indexPath.section == 0 {
            if indexPath.row > 0 {
                cell.forTag = Tag.allCases[indexPath.row - 1]
                cell.segment.selectedSegmentIndex = pr[String(describing: cell.forTag!)] ?? 1
            } else {
                cell.segment.selectedSegmentIndex = G.threadStyle.content
            }
            cell.selectionStyle = .none
        } else if indexPath.section == 1 {
            cell.selectionStyle = .none
            cell.segment.selectedSegmentIndex = G.floorStyle.content
            cell.forThread = false
        } else {
            cell.segment.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "帖子显示选项"
        } else if section == 1 {
            return "楼层显示选项"
        } else {
            return nil
        }
    }
    override var content: [[(title: String, fun: () -> Void)]] { setting_content }
    override var cellName: String { "SettingCell" }
    override var _tableView: UITableView! { tableView }
    
}

class AboutMenuVC: BaseTableVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var setting_content: [[(title: String, fun: () -> Void)]] = [
        [
            ("主页", {UIApplication.shared.open(URL(string: "http://wukefenggao.cn")!)}),
            ("社区规范", {UIApplication.shared.open(URL(string: "http://wukefenggao.cn/code")!)}),
            ("无可奉告之禅", {self << (*"AboutVC" as! AboutVC).withFather(self)})
        ]
    ]
    override var content: [[(title: String, fun: () -> Void)]] { setting_content }
    override var cellName: String { "AboutMenuCell" }
    override var _tableView: UITableView! { tableView }
    
}

class TokenVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
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
    var toHalt = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checker.setCheckBoxStyle(fontSize: 14)
        checker.semanticContentAttribute = .forceLeftToRight
        checker.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        checker.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        if toHalt {
            self.showAlert("无网络连接，即将退出程序", style: .failure, duration: 2.0) {
                Util.halt()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let s = G.blockContent {
            self << (UIAlertController(title: "很抱歉，你已被封禁", message: s, preferredStyle: .alert)..{
                $0.addAction(.init(title: "退出", style: .cancel, handler: { _ in
                    Util.halt()
                }))
            })
        }
        
    }
    
    func noNetwork() -> Self {
        toHalt = true
        return self
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
