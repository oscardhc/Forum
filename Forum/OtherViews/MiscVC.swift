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
    var cellName: String { "MiscCell" }
    
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

class MiscVC: BaseTableVC {
    
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
            ("关于", {self << (*"AboutVC" as! AboutVC).withFather(self)})
        ]
    ]
    override var content: [[(title: String, fun: () -> Void)]] { misc_content }
    override var cellName: String { "MiscCell" }
    override var _tableView: UITableView! { tableView }
    
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
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let d = G.networkStat.content
        var s = "Failed: \(d[0])\n", sm = 0, cnt = 0
        for i in 1...100 where d[i] != 0 {
            s += "\(i): \(d[i]) \n"
            sm += d[i] * i
            cnt += d[i]
        }
        s += "Average: \(Double(sm) / Double(cnt))"
        tokenLabel.text = s
        
    }
    
}
