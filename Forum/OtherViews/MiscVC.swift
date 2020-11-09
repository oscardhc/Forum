//
//  AboutViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

class MiscVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var content: [[(title: String, fun: () -> Void)]] = G.hasLoggedIn
        ? [
            [
                ("头像", {}),
                ("账号", {}),
                ("通知", {self >> MainVC.new(.messages)}),
                ("收藏", {self >> MainVC.new(.favour)})
            ],
            [
                ("我的帖子", {self >> MainVC.new(.my)})
            ],
            [
                ("设置", {}),
                ("关于", {self << (*"AboutVC" as! AboutVC).withFather(self)})
            ]
        ]
        : [
            [
                ("请登录", {self << *"LoginVC"})
            ]
        ]
    
    func isIconIndex(_ indexPath: IndexPath) -> Bool {
        content[indexPath.section][indexPath.row].title == "头像"
    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiscCell", for: indexPath) as! MiscTableViewCell
        cell.textLabel?.text = content[indexPath.section][indexPath.row].title
        if isIconIndex(indexPath) {
            cell.icon.image = UIImage(named: "avator")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        isIconIndex(indexPath)
            ? 100
            : 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        content[indexPath.section][indexPath.row].fun()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.contentInsetAdjustmentBehavior = .always
        
    }
    
    func deselect() {
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselect()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
