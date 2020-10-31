//
//  AboutViewController.swift
//  Forum
//
//  Created by Oscar on 2020/10/5.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let content: [[(String, () -> Void)]] = [
        [
            ("头像", {}),
            ("账号", {}),
            ("通知", {}),
            ("收藏", {})
        ],
        [
            ("我的帖子", {})
        ],
        [
            ("设置", {}),
            ("关于", {})
        ]
    ]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        content.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath)
        cell.textLabel?.text = content[indexPath.section][indexPath.row].0
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        content[indexPath.section][indexPath.row].1()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func accountBtnClicked(_ sender: Any) {
        present(
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(identifier: "LoginVC"),
            animated: true, completion: nil
        )
//        self.navigationController?.pushViewController(
//            UIStoryboard(name: "Main", bundle: nil)
//                .instantiateViewController(identifier: "LoginVC"),
//            animated: true
//        )
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
