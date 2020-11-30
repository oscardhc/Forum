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

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIScrollViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, DoubleTappable {
    
    
    enum Scene: String {
        case main = "首页", my = "我的帖子", trends = "趋势", messages = "通知", floors = "Thread#", favour = "我的收藏"
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
    @IBOutlet weak var replyToLabel: UILabel!
    @IBOutlet weak var newThreadBtn: UIButton!
    @IBOutlet weak var barSecondBtn: UIBarButtonItem!
    @IBOutlet weak var topDist: NSLayoutConstraint!
    @IBOutlet weak var tableBottomSpace: NSLayoutConstraint!
    
    var inSearchMode = false
    func search() {
        if let tx = s.searchBar.text {
            (self.d as! Thread.Manager)..{
                $0.searchFor = tx
            }
            inSearchMode = true
            clearAll()
        }
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
            vc.d = Floor.Manager(args[0] as! Thread)
        case .messages:
            vc.d = Message.Manager()
        case .main:
            fatalError()
        }
        return vc
    }
    
    let footer = MJRefreshAutoNormalFooter()
    var originalOffset: CGFloat?
    
    lazy var s = SearchBarContainerView(customSearchBar: UISearchBar())..{
        $0.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44)
        $0.searchBar.delegate = self
    }
    
    var inPreview = false
    var _topDist: CGFloat {
        inPreview
            ? 0
            : (UIApplication.shared.windows[0].safeAreaInsets.top == 20 ? 64 : 88)
    }
    
    lazy var refreshControl = UIRefreshControl()..{
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
        
        tableView.contentInsetAdjustmentBehavior = .always
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MainCell", bundle: .main), forCellReuseIdentifier: "MainCell")
        tableView.separatorStyle = .none
                
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadmore))
        footer.heightPreset = .custom(110)
        footer.backgroundColor = .none
        tableView.mj_footer = footer

        if !inPreview { tableView.refreshControl = refreshControl }
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))..{
            $0.numberOfTouchesRequired = 1
            $0.cancelsTouchesInView = false
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        textView.delegate = self
        textViewDidChange(textView)
        replyToLabel.text = "To #0"
        
        footer.setTitle("正在加载...", for: .idle)
        tableView.isScrollEnabled = false
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newThreadBtn.applyShadow(opaque: false, offset: 2, opacity: 0.3)
        navigationItem.largeTitleDisplayMode = scene == .floors ? .never : .always
        navigationItem.title = scene == .floors
            ? "\((d as! Floor.Manager).thread.title)"
            : scene.rawValue
        
        if scene == .floors {
            tabBarController?.tabBar.isHidden = true
            bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 20
        } else {
            tabBarController?.tabBar.isHidden = false
            bottomViewHeight.constant = 0
        }
        topCornerBtn.title = ""
        barSecondBtn.title = ""
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
    
    var isDoubleTapping = false, tryDoubleTapping = false, firstLoading = true
    func hasTappedAgain() {
        if tableView.refreshControl!.isRefreshing || tryDoubleTapping {
            return
        }
        let y = self.tableView.refreshControl!.frame.maxY + self.tableView.adjustedContentInset.top
        let o = self.tableView.contentOffset.y
        
        if o < -30 || self.scene == .floors {
            self.isDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
            self.tableView.refreshControl?.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.refresh()
            }
        } else {
            self.tryDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
        }
    }
    
    // MARK: - Selector functions
    
    func updateFavour() {
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star")
            topCornerBtn.isEnabled = true
        }
    }
    
    func clearAll(thenRefresh: Bool = true) {
        let prev = self.d.count
        self.d.clear()
        footer.setTitle("正在加载...", for: .idle)
        tableView.beginUpdates()
        if prev > self.d.count {
            tableView.deleteRows(at: (self.d.count..<prev).map{IndexPath(row: $0, section: 0)}, with: .top)
        }
        tableView.endUpdates()
        if thenRefresh {
            refresh()
        }
    }
    
    @objc func refresh() {
        print("refresh... topdist = ", topDist.constant)
        DispatchQueue.global().async {
            usleep(self.firstLoading ? 100000 : 300000)
            if !self.inSearchMode, let dm = self.d as? Thread.Manager, dm.searchFor != nil {
                dm.resetSearch()
            }
            self.inSearchMode = false
            
            let prev = self.d.count
            self.d.clear()
            let count = self.d.getContent()
            
            DispatchQueue.main.async {
                self.updateFavour()
                self.scene == .floors => self.replyToLabel.text = "To #\(self.floor) \((self.d as! Floor.Manager).displayNameFor(Int(self.floor)!)):"
                self.tableView.refreshControl?.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (self.firstLoading ? 0 : 0.25)) {
                    
                    self.footer.setTitle("点击或上拉以加载更多", for: .idle)
                    self.tableView.isScrollEnabled = true
                    
                    if self.isDoubleTapping {
                        let y = self.tableView.refreshControl!.frame.maxY + self.tableView.adjustedContentInset.top
                        self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
                        self.isDoubleTapping = false
                    }
                    
                    if prev > (self.scene == .floors ? 1 : 0) {
                        print("RELOADING!!!")
                        self.tableView.reloadData()
                    } else {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: (prev..<self.d.count).map{IndexPath(row: $0, section: 0)}, with: .top)
                        if self.scene == .floors {
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        }
                        self.tableView.endUpdates()
                    }
                    self.firstLoading = false
                    
                    if count >= G.numberPerFetch {
                        self.tableView.mj_footer?.resetNoMoreData()
                    } else {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                }
            }
        }
    }
    
    @objc func loadmore() {
        self.tableView.isScrollEnabled = false
        DispatchQueue.global().async {
            usleep(100000)
            let prev = self.d.count
            let count = self.d.getContent()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                
                if self.d.count > prev {
                    self.tableView.insertRows(at: (prev..<self.d.count).map {IndexPath(row: $0, section: 0)}, with: .automatic)
                }
                
                if count < G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                
                self.tableView.isScrollEnabled = true
            }
        }
    }
    
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (scrollView.panGestureRecognizer.translation(in: scrollView).y < 0)
            ?< self.changeBar(hide: true)
            ?> self.changeBar(hide: false)
        
        if scene == .floors {
            let ntitle = scrollView.contentOffset.y > 30
                ? "\((d as! Floor.Manager).thread.title)"
                : "#\((d as! Floor.Manager).thread.id)"
            if ntitle != navigationItem.title {
                navigationController?.navigationBar.layer.add(
                    CATransition()..{
                        $0.duration = 0.2
                        $0.type = .fade
                    }, forKey: "fadeText")
                navigationItem.title = ntitle
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.tryDoubleTapping {
            self.tryDoubleTapping = false
            self.hasTappedAgain()
        }
    }
    
    var floor: String = "0"
    func tryToReplyTo(floor f: String) {
        floor = f
        textView.becomeFirstResponder()
        textView.text = ""
        replyToLabel.text = "To #\(floor) \((d as! Floor.Manager).displayNameFor(Int(floor)!)):"
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if scene == .floors {
            let height = (sender.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue.height
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 16
            bottomSpace.constant = height
            let delta = bottomSpace.constant
            tableBottomSpace.constant = -bottomSpace.constant
            UIView.animate(withDuration: time) {
                self.tableView.contentOffset..{
                    self.tableView.setContentOffset(.init(x: 0, y: $0.y + delta), animated: false)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if scene == .floors {
            var time: TimeInterval = 0
            (sender.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSValue).getValue(&time)
            bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 20 + 16
            let delta = bottomSpace.constant
            bottomSpace.constant = 0
            tableBottomSpace.constant = -bottomSpace.constant
            UIView.animate(withDuration: time) {
                self.tableView.contentOffset..{
                    self.tableView.setContentOffset(.init(x: 0, y: $0.y - delta), animated: false)
                }
                self.view.layoutIfNeeded()
            }
        }
        self.navigationItem.titleView = nil
    }
    func adjustTextView() {
        if scene == .floors {
            if textView.text.count > 0 {
                let height = max(min(textView.contentSize.height, 100), 36)
                textViewHeight.constant = height
                bottomViewHeight.constant = textViewHeight.constant + 16 + 10 + 16
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            updateCountingLabel(label: replyCountLabel, text: textView.text, lineLimit: 20, charLimit: 817)
        }
    }
    
    @objc func keyboardDidHide(_ sender: Notification) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextView()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        adjustTextView()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        adjustTextView()
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        adjustTextView()
    }
    
    @objc func viewTapped(_ sender: Any) {
        self.view.endEditing(false)
    }
    
    // MARK: - IBActions
    
    @IBAction func newComment(_ sender: Any) {
        if let content = textView.text, content != "", replyCountLabel.ok {
            let threadID = (d as! Floor.Manager).thread.id
            if Network.newReply(for: threadID, floor: floor, content: content) {
                textView.text = " "
                self.textViewDidChange(textView)
                textView.text = ""
                self.view.endEditing(false)
                showAlert("评论成功", style: .success) {
                    self.d.count > 1
                        ?< self.loadmore()
                        ?> self.refresh()
                }
            }
        } else {
            showAlert("请输入合适长度的内容", style: .warning)
        }
    }
    
    @IBAction func newThread(_ sender: Any) {
        self << (*"NewThreadVC" as! NewThreadVC).withFather(self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
        search()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(false)
        self.navigationItem.titleView = nil
    }
    
    @IBAction func barBtnClicked(_ sender: Any) {
        if scene == .floors {
            (d as! Floor.Manager)..{ dd in
                dd.thread.hasFavoured
                    ? Network.cancelFavourThread(for: dd.thread.id)
                    : Network.favourThread(for: dd.thread.id)
                => {
                    dd.thread.hasFavoured = !dd.thread.hasFavoured
                    self.updateFavour()
                }
            }
//            if ({
//                if (d as! Floor.Manager).thread.hasFavoured {
//                    return Network.cancelFavourThread(for: (d as! Floor.Manager).thread.id)
//                } else {
//                    return Network.favourThread(for: (d as! Floor.Manager).thread.id)
//                }
//            }()) {
//                (d as! Floor.Manager).thread.hasFavoured = !(d as! Floor.Manager).thread.hasFavoured
//                updateFavour()
//            }
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
            self.navigationItem.titleView = s
            s.searchBar.becomeFirstResponder()
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
    
    lazy var dropDown = DropDown()..{
        $0.dataSource = Thread.Category.allCases.dropLast().map {
            $0.rawValue
        }
        $0.backgroundColor = .systemBackground
        $0.cellHeight = 40
        $0.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if scene != .main {
            return UIView()
        }
        let width = tableView.frame.width
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: headerHeight))
        baseView.backgroundColor = .systemBackground
        
        // hide top shaddow
        let bot = UIView(frame: CGRect(x: 0, y: headerHeight - 5, width: width, height: 5))
        bot.backgroundColor = .systemBackground
        bot.applyShadow()
        baseView.addSubview(bot)
        baseView.clipsToBounds = false
        
        let view = UIView(frame: CGRect(x: 0, y: -20, width: width, height: headerHeight + 20))
        view.backgroundColor = .systemBackground
        baseView.addSubview(view)
        
        if scene == .main {
            let lbl = UILabel(frame: CGRect(x: width/2, y: 17, width: width/4, height: headerHeight))
            lbl.text = "板块："
            lbl.textColor = .label
            lbl.textAlignment = .right
            lbl.font = UIFont.systemFont(ofSize: 12)
            view.addSubview(lbl)
            
            let btn = UIButton(frame: CGRect(x: width*3/4, y: 17, width: width/4 - 8, height: headerHeight))
            btn.addTarget(self, action: #selector(chooseBlock(_:)), for: .touchUpInside)
            btn.setTitle((d as! Thread.Manager).block.rawValue, for: .normal)
            btn.setDropDownStyle()
            
            dropDown.anchorView = btn
            dropDown.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                btn.setTitle(item, for: .normal)
                (self.d as! Thread.Manager).block = Thread.Category.init(rawValue: item)!
//                self.refresh()
                self.clearAll()
            }
            
            view.addSubview(btn)
        } else if scene == .floors {
            let lbl = UILabel(frame: .init(x: 8, y: 0, width: width/2, height: headerHeight))..{
                $0.text = (d as! Floor.Manager).thread.title
                $0.fontSize = 15
            }
            view.addSubview(lbl)
        }
        return baseView
    }
    
    @objc func chooseBlock(_ sender: Any) {
        dropDown.show()
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
    
    // MARK: - Context Menu
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        scene == .floors ? nil :
        UIContextMenuConfiguration(identifier: nil, previewProvider: {
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if navigationItem.largeTitleDisplayMode == .always {
            navigationItem.title = ""
        }
        d.didSelectedRow(self, index: indexPath.row)
    }

}

class SearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = UIColor.white
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .done
        searchBar.showsCancelButton = true
        addSubview(searchBar)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}
