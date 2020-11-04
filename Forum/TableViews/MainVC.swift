//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import MJRefresh

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    enum Scene: String {
        case main = "Threads", myThreads = "My Threads", trends = "Trends", messages = "Messages", floors = "Thread#"
    }
    
    // This is the default value for MainThread(the enter interface), any other types must overwrite this two properties
    private var scene = Scene.main
    var d: DataManager = ThreadData(type: .time)
    
    @IBOutlet weak var tableView: UITableView!
    
    func my() -> Self {
        scene = .myThreads
        d = ThreadData(type: .my)
        return self
    }
    func tr() -> Self {
        scene = .trends
        d = ThreadData(type: .trending)
        return self
    }
    func fl(_ thread: Thread) -> Self {
        scene = .floors
        d = FloorData(for: thread)
        return self
    }
    
    let footer = MJRefreshAutoNormalFooter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarController?.viewControllers?.count == 2 {
            let nav = UINavigationController(rootViewController: (*"MainVC" as! MainVC).tr())
            nav.navigationBar.prefersLargeTitles = true
            tabBarController?.viewControllers?.insert(nav, at: 1)
            tabBarController?.tabBar.items?[1].title = "Thrends"
        }
        navigationItem.title = scene.rawValue
//        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.contentInsetAdjustmentBehavior = .always
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        tableView.mj_footer = footer

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        refresh()
    }
    
    @objc func refresh() {
//        threads = Network.getThreads(type: sortType) + [Thread.samplePost()]
        print("REFRESHING.....")
        DispatchQueue.global().async {
            self.d.getInitialContent()
            usleep(1000000)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
    @objc func loadmore() {
        DispatchQueue.global().async {
            let noMore = self.d.getMoreContent()
            usleep(1000000)
            DispatchQueue.main.async {
                if noMore {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self.tableView.reloadData()
                    self.tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
    
    @IBAction func newThread(_ sender: Any) {
        print("new thread!")
        present((*"NewThreadVC" as! NewThreadViewController).withFather(self), animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0
            ? 1
            : d.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        indexPath.section == 0
            ?  tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath)
            :  d.initializeCell(tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0
            ? (scene == .main ? 150 : 0)
            : 200
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            d.didSelectedRow(self, index: indexPath.row)
        }
    }

}
