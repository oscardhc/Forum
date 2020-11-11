//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import MJRefresh
import UITextView_Placeholder

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    
    enum Scene: String {
        case main = "Threads", my = "My Threads", trends = "Trends", messages = "Messages", floors = "Thread#", favour = "Favoured"
    }
    
    // This is the default value for MainThread(the enter interface), any other types must overwrite this two properties
    private var scene = Scene.main
    var d: BaseManager = Thread.Manager(type: .time)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var newThreadButton: UIBarButtonItem!
    
    static func new(_ scene: Scene, _ args: Any...) -> MainVC {
        let vc = *"MainVC" as! MainVC
        vc.scene = scene
        switch vc.scene {
        case .my:
            vc.d = Thread.Manager(type: .my)
        case .trends:
            vc.d = Thread.Manager(type: .trending)
        case .favour:
            vc.d = Thread.Manager(type: .favoured)
        case .floors:
            vc.d = Floor.Manager(for: args[0] as! Thread)
        case .messages:
            vc.d = Message.Manager()
        case .main:
            fatalError()
        }
        return vc
    }
    
    let footer = MJRefreshAutoNormalFooter()
    var originalOffset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tabBarController?.viewControllers?.count == 2 {
            let nav = UINavigationController(rootViewController: MainVC.new(.trends))
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
        
        navigationItem.title = scene == .floors
            ? "Thread#\((d as! Floor.Manager).thread.id)"
            : scene.rawValue
        
        
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
        textView.delegate = self
        textView.placeholder = "Comment"
        textView.placeholderColor = .gray
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
        
        refresh()
    }
    
    let bottomInitialHeight: CGFloat = 80
    let bottomExpandHeight: CGFloat = 36 + 16
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if scene == .floors {
            tabBarController?.tabBar.isHidden = true
            bottomViewHeight.constant = bottomInitialHeight
        } else {
            tabBarController?.tabBar.isHidden = false
            bottomViewHeight.constant = 0
        }
        if scene != .main {
            newThreadButton.title = ""
        }
        if scene == .floors {
            newThreadButton.image = UIImage(systemName: "star")
//            newThreadButton.
            newThreadButton.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if scene == .floors {
//            tabBarController?.tabBar.isHidden = false
        } else {
            
        }
    }
    
    // MARK: - Selector functions
    
    func updateFavour() {
        if scene == .floors {
            newThreadButton.image = UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star")
            newThreadButton.isEnabled = true
        }
    }
    
    @objc func refresh() {
        DispatchQueue.global().async {
            usleep(300000)
            let count = self.d.getInitialContent()
            DispatchQueue.main.async {
                self.updateFavour()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadSections(IndexSet([1]), with: .automatic)
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
            usleep(300000)
            let count = self.d.getMoreContent()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.reloadSections(IndexSet([1]), with: .automatic)
                if count != G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    var floor: String = "-1" {
        didSet {
//            textView.placeholder = "Replying to Floor #\(floor)"
        }
    }
    
    func tryToReplyTo(floor f: String) {
        floor = f
        textView.becomeFirstResponder()
        textView.text = ""
        textView.placeholder = "Replying to Floor #\(floor)"
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        print("WILL SHOW!!!")
        let height = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
        var time: TimeInterval = 0
        (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
        bottomViewHeight.constant = bottomExpandHeight
        bottomSpace.constant = height
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        print("WILL HIDE!!!")
        var time: TimeInterval = 0
        (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
        bottomViewHeight.constant = bottomInitialHeight
        bottomSpace.constant = 0
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let height = max(min(textView.contentSize.height, 100), 36)
        textViewHeight.constant = height
        bottomViewHeight.constant = height + 16
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func viewTapped(_ sender: Any) {
        print("VIEW TAPPED!!!")
        self.view.endEditing(false)
    }
    
    // MARK: - IBActions
    
    @IBAction func newComment(_ sender: Any) {
        if let content = textView.text, content != "" {
            let threadID = (d as! Floor.Manager).thread.id
            let success = Network.newReply(for: threadID, content: content)
            if success {
                refresh()
            }
        }
    }
    
    @IBAction func barBtnClicked(_ sender: Any) {
        if scene == .main {
            self << (*"NewThreadVC" as! NewThreadVC).withFather(self)
        } else if scene == .floors {
            if ({
                if (d as! Floor.Manager).thread.hasFavoured {
                    return Network.cancelFavourThread(for: (d as! Floor.Manager).thread.id)
                } else {
                    return Network.favourThread(for: (d as! Floor.Manager).thread.id)
                }
            }()) {
                (d as! Floor.Manager).thread.hasFavoured = !(d as! Floor.Manager).thread.hasFavoured
                updateFavour()
            }
        }
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
            :  d.initializeCell(tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell, index: indexPath.row).withVC(self)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
//    var cellHeights = [IndexPath: CGFloat]()
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellHeights[indexPath] = cell.frame.size.height
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0
            ? (scene == .main ? 100 : 0)
//            : (d.height(width: tableView.frame.width - 30, for: indexPath.row))
//            : cellHeights[indexPath] ?? UITableView.automaticDimension
//            : 200
            : UITableView.automaticDimension
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
