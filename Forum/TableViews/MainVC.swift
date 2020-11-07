//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import MJRefresh

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    
    enum Scene: String {
        case main = "Threads", myThreads = "My Threads", trends = "Trends", messages = "Messages", floors = "Thread#"
    }
    
    // This is the default value for MainThread(the enter interface), any other types must overwrite this two properties
    private var scene = Scene.main
    var d: DataManager = Thread.Manager(type: .time)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHieght: NSLayoutConstraint!
    @IBOutlet weak var newThreadButton: UIBarButtonItem!
    
    func my() -> Self {
        scene = .myThreads
        d = Thread.Manager(type: .my)
        return self
    }
    func tr() -> Self {
        scene = .trends
        d = Thread.Manager(type: .trending)
        return self
    }
    func fl(_ thread: Thread) -> Self {
        scene = .floors
        d = Floor.Manager(for: thread)
        return self
    }
    
    let footer = MJRefreshAutoNormalFooter()
    var originalOffset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarController?.viewControllers?.count == 2 {
            let nav = UINavigationController(rootViewController: (*"MainVC" as! MainVC).tr())
            nav.navigationBar.prefersLargeTitles = true
            tabBarController?.viewControllers?.insert(nav, at: 1)
            
            tabBarController?.tabBar.items?[0].image = UIImage(systemName: "house")
            tabBarController?.tabBar.items?[0].selectedImage = UIImage(systemName: "house.fill")
            tabBarController?.tabBar.items?[0].title = "首页"
            
            tabBarController?.tabBar.items?[1].image = UIImage(systemName: "crown")
            tabBarController?.tabBar.items?[1].selectedImage = UIImage(systemName: "crown.fill")
            tabBarController?.tabBar.items?[1].title = "趋势"
            
            tabBarController?.tabBar.items?[2].image = UIImage(systemName: "person")
            tabBarController?.tabBar.items?[2].selectedImage = UIImage(systemName: "person.fill")
            tabBarController?.tabBar.items?[2].title = "我"
        }
        navigationItem.title = scene.rawValue
        tableView.contentInsetAdjustmentBehavior = .always
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
        tableView.separatorStyle = .none
                
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        tableView.mj_footer = footer

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        textField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
        
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if scene == .floors {
            tabBarController?.tabBar.isHidden = true
            bottomViewHieght.constant = 90
        } else {
            tabBarController?.tabBar.isHidden = false
            bottomViewHieght.constant = 0
        }
        print("<", self.tableView.contentOffset, self.tableView.refreshControl?.frame, self.navigationController?.navigationBar.frame, self.navigationController?.navigationBar.frame.height, self.tableView.frame)
        
        if scene != .main {
            newThreadButton.title = ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if scene == .floors {
//            tabBarController?.tabBar.isHidden = false
        } else {
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("will begin")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("did end")
    }
    
    // MARK: - Selector functions
    
    @objc func refresh() {
        DispatchQueue.global().async {
            let count = self.d.getInitialContent()
            usleep(100000)
//            while self.tableView.refreshControl?.frame.height +
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                if count == G.numberPerFetch {
                    self.tableView.mj_footer?.resetNoMoreData()
                } else {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    @objc func loadmore() {
        DispatchQueue.global().async {
            let count = self.d.getMoreContent()
            usleep(100000)
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.reloadData()
                if count != G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        print("WILL SHOW!!!")
        let height = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
        var time: TimeInterval = 0
        (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
        print(height, time)
        bottomSpace.constant = height + G.bottomDelta
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        print("WILL HIDE!!!")
        var time: TimeInterval = 0
        (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
        bottomSpace.constant = G.bottomDelta
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func viewTapped(_ sender: Any) {
        print("VIEW TAPPED!!!")
        self.view.endEditing(false)
    }
    
    // MARK: - IBActions
    
    @IBAction func newComment(_ sender: Any) {
        if let content = textField.text, content != "" {
            let threadID = (d as! Floor.Manager).thread.id
            let success = Network.newReply(for: threadID, floor: nil, content: content)
            if success {
                refresh()
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
            ?  (tableView.dequeueReusableCell(withIdentifier: "HeadCell", for: indexPath) as! HeaderCell).forBlock()
            :  d.initializeCell(tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0
            ? (scene == .main ? 200 : 0)
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
