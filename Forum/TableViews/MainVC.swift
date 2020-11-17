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

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate, DoubleTappable {
    
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
    
    lazy var searchControl = Init(UIAlertController(title: "请输入搜索内容", message: "", preferredStyle: .alert)) {
        $0.addTextField()
        $0.addAction(.init(title: "取消", style: .cancel, handler: nil))
        $0.addAction(.init(title: "确认", style: .default, handler: search))
    }
    
    func search(_ alert: UIAlertAction) {
        (d as! Thread.Manager).search(text: searchControl.textFields?[0].text)
        hasTappedAgain()
    }
    
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
        
        navigationItem.title = scene == .floors
            ? "#\((d as! Floor.Manager).thread.id)"
            : scene.rawValue
        
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.contentInsetAdjustmentBehavior = .always
//        edgesForExtendedLayout = .all
        
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
            newThreadBtn.frame.origin = CGPoint(x: newThreadBtn.frame.minX, y: UIScreen.main.bounds.height - tabBarController!.tabBar.frame.height - 80)
        } else {
            newThreadBtn.isHidden = true
        }
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: "star")
            topCornerBtn.isEnabled = false
        }
    }
    
    var isDoubleTapping = false
    func hasTappedAgain() {
        if tableView.refreshControl!.isRefreshing {
            return
        }
        
        let top = self.tableView.adjustedContentInset.top
        let y = self.tableView.refreshControl!.frame.maxY + top
        self.tableView.setContentOffset(CGPoint(x: 0, y: -y-52), animated: true)
        tableView.refreshControl?.beginRefreshing()
        isDoubleTapping = true
        DispatchQueue.global().async {
            usleep(300000)
            self.refresh()
        }
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
            print("end refreshing")
            
            DispatchQueue.main.async {
                self.updateFavour()
                self.footer.setTitle("点击或上拉以加载更多", for: .idle)
                self.tableView.isScrollEnabled = true
                
                self.tableView.refreshControl?.endRefreshing()
                
                if self.isDoubleTapping {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: -170), animated: true)
                    self.isDoubleTapping = false
                }
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
                    idx.reverse()
                    print(count, self.d.count, idx)
//                    self.tableView.insert
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
            if let bar = self.tabBarController?.tabBar {
                let offset = UIScreen.main.bounds.height - (hide ? 0 : bar.frame.height)
                if offset == bar.frame.origin.y { return }
                UIView.animate(withDuration: 0.3) {
                    self.newThreadBtn.frame.origin = CGPoint(x: self.newThreadBtn.frame.minX, y: offset - 80)
                    bar.frame.origin.y = offset
                }
            }
        }
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            changeBar(hide: true)
        }
        else{
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
        if scene == .floors {
            let height = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = bottomExpandHeight
            bottomSpace.constant = height
            UIView.animate(withDuration: time) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if scene == .floors {
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = bottomInitialHeight
            bottomSpace.constant = 0
            UIView.animate(withDuration: time) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if scene == .floors {
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
                showAlert("评论成功", style: .success) {
                    self.refresh()
                }
            }
        } else {
            showAlert("请输入合适长度的内容", style: .warning)
        }
    }
    
    @IBAction func newThread(_ sender: Any) {
        self << (*"NewThreadVC" as! NewThreadVC).withFather(self)
    }
    
    @IBAction func barBtnClicked(_ sender: Any) {
        if scene == .main {
            self << searchControl
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
    }

}
