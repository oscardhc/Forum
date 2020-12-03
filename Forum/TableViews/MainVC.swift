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

extension UIViewController {
    @objc func esc() {
        self.dismiss(animated: true, completion: nil)
    }
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DoubleTappable {
    
    enum Scene: String {
        case main = "首页", my = "我的帖子", trends = "趋势", messages = "通知", floors = "Thread#", favour = "我的收藏"
    }
    
    var scene = Scene.main
    var d: BaseManager = Thread.Manager(type: .time)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topCornerBtn: UIBarButtonItem!
    @IBOutlet weak var replyCountLabel: StateLabel!
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var newThreadBtn: UIButton!
    @IBOutlet weak var barSecondBtn: UIBarButtonItem!
    @IBOutlet weak var topDist: NSLayoutConstraint!
    
    var inSearchMode = false
    
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
            vc.d = Floor.Manager(args[0] as! Thread)
        case .messages:
            vc.d = Message.Manager()
        case .main:
            fatalError()
        }
        return vc
    }
    
    var inPreview = false
    var isDoubleTapping = false, tryDoubleTapping = false, firstLoading = true
    var _topDist: CGFloat {
        inPreview
            ? 0
            : (UIApplication.shared.windows[0].safeAreaInsets.top == 20 ? 64 : 88)
    }
    
    lazy var refreshControl = UIRefreshControl()..{
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    lazy var dropDown = DropDown()..{
        $0.dataSource = Thread.Category.allCases.dropLast().map {
            $0.rawValue
        }
        $0.backgroundColor = .systemBackground
        $0.cellHeight = 40
        $0.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
    }
    lazy var search = SearchBarContainerView(customSearchBar: UISearchBar())..{
        $0.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        $0.searchBar.delegate = self
    }
    lazy var footer = MJRefreshAutoNormalFooter()..{
        $0.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        $0.heightPreset = .small
        $0.backgroundColor = .none
        $0.setTitle("正在加载...", for: .idle)
    }
    
    var floor: String = "0" {
        didSet {
            self.replyToLabel.text = "To #\(self.floor) \((self.d as! Floor.Manager).displayNameFor(Int(self.floor)!)):"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topDist.constant = _topDist
        
        UINavigationBarAppearance()..{
            $0.configureWithOpaqueBackground()
            $0.shadowImage = nil
            $0.shadowColor = nil
            $0.backgroundColor = .systemBackground
            navigationController?.navigationBar.standardAppearance = $0
            navigationController?.navigationBar.scrollEdgeAppearance = $0
        }
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView!..{
            $0.contentInsetAdjustmentBehavior = .always
            $0.delegate = self
            $0.dataSource = self
            $0.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
            $0.separatorStyle = .none
            
            $0.mj_footer = footer
            !inPreview => $0.refreshControl = refreshControl
            
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))..{
                $0.numberOfTouchesRequired = 1
                $0.cancelsTouchesInView = false
            })
            $0.isScrollEnabled = false
        }
        
        addKeyCommand(.init(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(esc)))
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        textView.delegate = self
        textViewDidChange(textView)
        replyToLabel.text = "To #0"
        refresh()
//        hasTappedAgain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newThreadBtn.applyShadow(opaque: false, offset: 2, opacity: 0.3)
        navigationItem.largeTitleDisplayMode = scene == .floors ? .never : .always
        navigationItem.title = scene == .floors
            ? "\((d as! Floor.Manager).thread.title)"
            : scene.rawValue
        
        if scene == .floors {
            self.tabBarController?.tabBar.isHidden = true
            self.bottomViewHeight.constant = self.textViewHeight.constant + 16 + 10 + 20
        } else {
            self.tabBarController?.tabBar.isHidden = false
            self.bottomViewHeight.constant = 0
        }
        if scene == .main {
            barSecondBtn.image = UIImage(systemName: "magnifyingglass")
            newThreadBtn.frame.origin = CGPoint(x: newThreadBtn.frame.minX, y: UIScreen.main.bounds.height - tabBarController!.tabBar.frame.height - 80)
            navigationController?.navigationBar.layer.shadowOpacity = 0
        } else {
            barSecondBtn.image = UIImage()
            newThreadBtn.isHidden = true
            navigationController?.navigationBar.applyShadow()
        }
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: "star")
            barSecondBtn.image = UIImage(systemName: "ellipsis")
            topCornerBtn.isEnabled = false
            !firstLoading => updateFavour()
            barSecondBtn.isEnabled = true
        } else {
            topCornerBtn.isEnabled = false
            topCornerBtn.image = UIImage()
        }
        
        if let id = G.openThreadID {
            G.openThreadID = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Thread.Manager.openCertainThread(self, id: id)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changeBar(hide: false)
    }
    
    func tryToReplyTo(floor f: String) {
        floor = f
        textView.becomeFirstResponder()
        textView.text = ""
    }
    
    // MARK: - IBActions
    
    @IBAction func newComment(_ sender: Any) {
        if let content = textView.text, content != "", replyCountLabel.ok {
            let threadID = (d as! Floor.Manager).thread.id
            self.view.endEditing(false)
            self.showProgress()..{ bar in
                DispatchQueue.global().async {
//                    print("start to reply...", threadID, self.)
                    if Network.newReply(for: threadID, floor: self.floor, content: content) {
                        self.setAndHideAlert(bar, "评论成功", style: .success) {
                            self.textView.text = ""
                            (self.d as! Floor.Manager)..{
                                $0.count > 1 && !$0.reverse
                                    ?> self.loadmore()
                                    ?< self.refresh()
                            }
                        }
                    } else { self.setAndHideAlert(bar, "评论失败", style: .failure) }
                }
            }
        } else { showAlert("请输入合适长度的内容", style: .warning) }
    }
    
    @IBAction func newThread(_ sender: Any) {
        self << (*"NewThreadVC" as! NewThreadVC).withFather(self)
    }
    
    @IBAction func barBtnClicked(_ sender: Any) {
        scene == .floors => {
            topCornerBtn.isEnabled = false
            (d as! Floor.Manager)..{ dd in
                DispatchQueue.global().async {
                    let success = dd.thread.hasFavoured
                        ? Network.cancelFavourThread(for: dd.thread.id)
                        : Network.favourThread(for: dd.thread.id)
                    DispatchQueue.main.async {
                        self.topCornerBtn.isEnabled = true
                        if success {
                            dd.thread.hasFavoured = !dd.thread.hasFavoured
                            self.updateFavour()
                        } else { self.showAlert("收藏失败", style: .failure) }
                    }
                }
            }
        }
    }
    
    func blockThread(_ msg: String) {
        let id = (self.d as! Floor.Manager).thread.id
        let li = G.blockedList.content
        !li.contains(id) => G.blockedList.content = li + [id]
        self.showAlert(msg, style: .success) {
            (self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 2] as! MainVC).refresh()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func secondBarBtnClicked(_ sender: UIBarItem) {
        if scene == .floors {
            let al = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            al.addAction(.init(title: "屏蔽", style: .default, handler: { (a) in
                self.blockThread("屏蔽成功")
            }))
            al.addAction(.init(title: "举报", style: .destructive, handler: { (a) in
                self.blockThread("举报成功")
            }))
            al.addAction(.init(title: "取消", style: .cancel, handler: { (a) in
                
            }))
            if let popoverPresentationController = al.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                let fr = self.navigationController!.navigationBar.frame
                popoverPresentationController.sourceRect = .init(x: fr.maxX - 1.0, y: fr.minY, width: 1.0, height: fr.height)
                popoverPresentationController.permittedArrowDirections = .init(rawValue: 0)
            }
            self << al
        } else {
            self.navigationItem.titleView = search
            search.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    var headerHeight: CGFloat {
        scene == .main ? 20 : 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        headerHeight
    }
    
    @objc func chooseBlock(_ sender: Any) {
        dropDown.show()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.frame.width
        return scene != .main
            ? UIView()
            : UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight))..{
                $0.backgroundColor = .systemBackground
                $0.clipsToBounds = false
                
                // hide top shaddow
                $0 += UIView(frame: CGRect(x: 0, y: headerHeight - 5, width: width, height: 5))..{ bot in
                    bot.backgroundColor = .systemBackground
                    bot.applyShadow()
                }
                $0 += UIView(frame: CGRect(x: 0, y: -20, width: width, height: headerHeight + 20))..{ top in
                    top.backgroundColor = .systemBackground
                    if scene == .main {
                        top += UILabel(frame: CGRect(x: width/2, y: 17, width: width/4, height: headerHeight))..{
                            $0.text = "板块："
                            $0.textColor = .label
                            $0.textAlignment = .right
                            $0.font = UIFont.systemFont(ofSize: 12)
                        }
                        
                        top += UIButton(frame: CGRect(x: width*3/4, y: 17, width: width/4 - 8, height: headerHeight))..{ btn in
                            btn.addTarget(self, action: #selector(chooseBlock(_:)), for: .touchUpInside)
                            btn.setTitle((d as! Thread.Manager).block.rawValue, for: .normal)
                            btn.setDropDownStyle()
                            
                            dropDown.anchorView = btn
                            dropDown.selectionAction = { (index: Int, item: String) in
                                print("Selected item: \(item) at index: \(index)")
                                btn.setTitle(item, for: .normal)
                                (self.d as! Thread.Manager).block = Thread.Category.init(rawValue: item)!
                                self.clearAll()
                            }
                        }
                    }
                }
            }
    }
    
    func setReplyOrder(reverse: Bool) {
        (d as! Floor.Manager)..{
            if $0.reverse != reverse {
                $0.reverse = reverse
                clearAll()
            }
        }
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
        !tableView.refreshControl!.isRefreshing && !tableView.mj_footer!.isRefreshing => {
            navigationItem.largeTitleDisplayMode == .always => navigationItem.title = ""
            d.didSelectedRow(self, index: indexPath.row)
        }
    }
    
    // MARK: - Context Menu
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        scene == .floors ? nil
            : UIContextMenuConfiguration(identifier: nil, previewProvider: {
                (self.d.didSelectedRow(self, index: indexPath.row, commit: false) as! MainVC)..{
                    $0.inPreview = true
                }
            } , actionProvider: nil)
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let dest = animator.previewViewController {
            animator.addAnimations {
                self.show(dest, sender: self)
                with ((dest as! MainVC)) {
                    $0.inPreview = false
                    $0.topDist.constant = $0._topDist
                    $0.updateFavour()
                    $0.tableView.refreshControl = $0.refreshControl
                }
            }
        }
    }

}
