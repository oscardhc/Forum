//
//  MainTableViewController.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import UIKit
import MJRefresh
import UITextView_Placeholder
import DropDown

extension UIRefreshControl {
    func refreshManually() {
        if let scrollView = superview as? UIScrollView {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: false)
        }
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate, DoubleTapEnabled {
    
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
    @IBOutlet weak var topCornerBtn: UIBarButtonItem!
    @IBOutlet weak var replyCountLabel: StateLabel!
    @IBOutlet weak var newThreadBtn: UIButton!
    
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
        
//        if tabBarController?.viewControllers?.count == 2 {
//            let nav = UINavigationController(rootViewController: MainVC.new(.trends))
//            nav.navigationBar.prefersLargeTitles = true
//            tabBarController?.viewControllers?.insert(nav, at: 1)
//            
//            tabBarController?.tabBar.items?[0].image = UIImage(systemName: "house")
//            tabBarController?.tabBar.items?[0].selectedImage = UIImage(systemName: "house.fill")
//            tabBarController?.tabBar.items?[0].title = "首页"
//            
//            tabBarController?.tabBar.items?[1].image = UIImage(systemName: "crown")
//            tabBarController?.tabBar.items?[1].selectedImage = UIImage(systemName: "crown.fill")
//            tabBarController?.tabBar.items?[1].title = "趋势"
//            
//            tabBarController?.tabBar.items?[2].image = UIImage(systemName: "person")
//            tabBarController?.tabBar.items?[2].selectedImage = UIImage(systemName: "person.fill")
//            tabBarController?.tabBar.items?[2].title = "我"
//        }
        
        navigationItem.title = scene == .floors
            ? "#\((d as! Floor.Manager).thread.id)"
            : scene.rawValue
//        navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationController?.navigationBar.shadowImage = UIImage()
        
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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        textView.delegate = self
        textViewDidChange(textView)
        floor = "0"
        
        footer.setTitle("正在加载...", for: .idle)
        tableView.isScrollEnabled = false
        refresh()
    }
    
    let bottomInitialHeight: CGFloat = 80
    let bottomExpandHeight: CGFloat = 36 + 16 + 10
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if scene == .floors {
            tabBarController?.tabBar.isHidden = true
            bottomViewHeight.constant = bottomInitialHeight
        } else {
            tabBarController?.tabBar.isHidden = false
            bottomViewHeight.constant = 0
        }
        topCornerBtn.title = ""
        if scene == .main {
            topCornerBtn.image = UIImage(systemName: "magnifyingglass")
        }
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: "star")
            topCornerBtn.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if scene == .floors {
//            tabBarController?.tabBar.isHidden = false
        } else {
            
        }
    }
    
    func hasTappedAgain() {
        print("tapped again!!")
    }
    
    // MARK: - Selector functions
    
    func updateFavour() {
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star")
            topCornerBtn.isEnabled = true
        }
    }
    
    @objc func refresh() {
//        print("refresh...")
        DispatchQueue.global().async {
            usleep(100000)
            let count = self.d.getInitialContent()
            DispatchQueue.main.async {
                self.updateFavour()
                self.footer.setTitle("点击或上拉以加载更多", for: .idle)
                self.tableView.isScrollEnabled = true
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
            usleep(100000)
            let count = self.d.getMoreContent()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                
                if count > 0 {
                    var idx = [IndexPath]()
                    for i in 1...count {
                        idx.append(IndexPath(row: self.d.count - i, section: 0))
                    }
                    self.tableView.insertRows(at: idx, with: .automatic)
                }
                
                if count != G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        func changeBar(hide: Bool) {
            let bar = self.tabBarController?.tabBar
            let offset = UIScreen.main.bounds.height - (hide ? 0 : bar!.frame.height)
            if offset == bar?.frame.origin.y { return }
            UIView.animate(withDuration: 0.5) {
                bar?.frame.origin.y = offset
            }
        }
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            //scrolling down
            changeBar(hide: true)
        }
        else{
            //scrolling up
            changeBar(hide: false)
        }
        
    }
    
    var floor: String = "0" {
        didSet {
            textView.placeholder = "Replying to Floor #\(floor)"
        }
    }
    
    func tryToReplyTo(floor f: String) {
        floor = f
        textView.becomeFirstResponder()
        textView.text = ""
        textView.placeholder = "Replying to Floor #\(floor)"
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
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
        var time: TimeInterval = 0
        (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
        bottomViewHeight.constant = bottomInitialHeight
        bottomSpace.constant = 0
        UIView.animate(withDuration: time) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            let height = max(min(textView.contentSize.height, 100), 36)
            textViewHeight.constant = height
            bottomViewHeight.constant = height + 16 + 10
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        updateCountingLabel(label: replyCountLabel, text: textView.text, lineLimit: 20, charLimit: 817)
    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    // MARK: - IBActions
    
    @IBAction func newComment(_ sender: Any) {
        if let content = textView.text, content != "", replyCountLabel.ok {
            let threadID = (d as! Floor.Manager).thread.id
            if Network.newReply(for: threadID, floor: floor, content: content) {
                textView.text = ""
                self.view.endEditing(false)
                refresh()
            }
        } else {
            G.alert.message = "请输入合适长度的内容"
            self.present(G.alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func newThread(_ sender: Any) {
        self << (*"NewThreadVC" as! NewThreadVC).withFather(self)
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
        1
    }
    
    var headerHeight: CGFloat {
        scene == .main ? 50 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight
    }
    
    var dropDown: DropDown = ({
        let d = DropDown()
        d.dataSource = Thread.Category.allCases.dropLast().map {
            $0.rawValue
        }
        d.backgroundColor = .systemBackground
        return d
    })()
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.frame.width
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight))
        baseView.backgroundColor = .systemBackground
        
        let view = UIView(frame: CGRect(x: 0, y: 5, width: width, height: headerHeight - 5))
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10);
        view.layer.shadowOpacity = 0.03
        baseView.addSubview(view)
        
        // hide top shaddow
        let top = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 5))
        top.backgroundColor = baseView.backgroundColor
        baseView.addSubview(top)
        baseView.clipsToBounds = false
        
        if scene == .main {
            
            let lbl = UILabel(frame: CGRect(x: width/2, y: 0, width: width/4, height: headerHeight))
            lbl.text = "板块："
            lbl.textColor = .black
            lbl.textAlignment = .right
            lbl.font = UIFont.systemFont(ofSize: 12)
            view.addSubview(lbl)
            
            let btn = UIButton(frame: CGRect(x: width*3/4, y: 0, width: width/4 - 8, height: headerHeight))
            btn.addTarget(self, action: #selector(chooseBlock(_:)), for: .touchUpInside)
            btn.setTitle((d as! Thread.Manager).block.rawValue, for: .normal)
            btn.setDropDownStyle()
            
            dropDown.anchorView = btn
            dropDown.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                btn.setTitle(item, for: .normal)
                (self.d as! Thread.Manager).block = Thread.Category.init(rawValue: item)!
                self.refresh()
            }
            
            view.addSubview(btn)
        }
        return baseView
    }
    
    @objc func chooseBlock(_ sender: Any) {
        dropDown.show()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        d.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        d.initializeCell(tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell, index: indexPath.row).withVC(self)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        d.didSelectedRow(self, index: indexPath.row)
//        dropDown.show()
    }

}
