//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import MJRefresh

class MainTableViewController: UITableViewController {
    
    enum Scene: String {
        case main = "Threads", myThreads = "My Threads", trends = "Trends"
    }
    private var scene = Scene.main
    
    var threads = [Thread]()
    var sortType = Network.NetworkGetThreadType.Default
    
    func my() -> Self {
        scene = .myThreads
        return self
    }
    func tr() -> Self {
        scene = .trends
        return self
    }
    
    let footer = MJRefreshAutoNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if tabBarController?.viewControllers?.count == 2 {
            let nav = UINavigationController(rootViewController: (*"MainVC" as! MainTableViewController).tr())
            nav.navigationBar.prefersLargeTitles = true
            tabBarController?.viewControllers?.insert(nav, at: 1)
            tabBarController?.tabBar.items?[1].title = "Thrends"
        }
        navigationItem.title = scene.rawValue
        
        tableView.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadMore))
        self.tableView.mj_footer = footer

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        
        refresh()
    }
    
    
    @objc func refresh() {
        threads = Network.getThreads(type: sortType)
        tableView.reloadData()
        refreshControl?.endRefreshing()
        tableView.mj_footer?.resetNoMoreData()
    }
    
    @objc func loadMore() {
        var data = [Thread]()
        if let last = threads.last?.id {
            data = Network.getThreads(type: sortType, lastSeenID: last)
            threads += data
            tableView.reloadData()
        }
        tableView.mj_footer?.endRefreshing()
        if data.isEmpty {
            tableView.mj_footer?.endRefreshingWithNoMoreData()
        }
    }
    
    @IBAction func newThread(_ sender: Any) {
        present((*"NewThreadVC" as! NewThreadViewController).withFather(self), animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0
            ? 1
            : threads.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0
            ?  tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath)
            : (tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell).setAsThread(thread: threads[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0
            ? (scene == .main ? 150 : 0)
            : 200
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        (tableView.cellForRow(at: indexPath) as! ContentTableViewCell).mainView.backgroundColor = .red
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        (tableView.cellForRow(at: indexPath) as! ContentTableViewCell).mainView.backgroundColor = .white
        
        if tableView.cellForRow(at: indexPath) is MainCell {
            
            self.navigationController?.pushViewController(
                (*"DetailTableVC" as! DetailTableViewController)
                    .forThread(threads[indexPath.row]),
                animated: true
            )
            
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
