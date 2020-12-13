//
//  MainCell.swift
//  Forum
//
//  Created by Oscar on 2020/9/29.
//

import UIKit
import DropDown

class MainCell: UITableViewCell, UITextViewDelegate {

    enum Scene {
        case thread, floor, message
    }
    
    var scene = Scene.thread
    
    var thread: Thread!
    var floor: Floor!
    var message: Message!
    var isFirstFloor = false
    var parentVC: MainVC!
    var name: String = "_"
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var idLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var headWidth: NSLayoutConstraint!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var cornerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDist: NSLayoutConstraint!
    @IBOutlet weak var commentDist: NSLayoutConstraint!
    @IBOutlet weak var idHeight: NSLayoutConstraint!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var mainTextView: UITextView!
    @IBOutlet weak var replyToName: UIButton!
    @IBOutlet weak var replyToNameDist: NSLayoutConstraint!
    @IBOutlet weak var cornerWidth: NSLayoutConstraint!
    @IBOutlet weak var cornerHeight: NSLayoutConstraint!
    @IBOutlet weak var orderBtn: UIButton!
    @IBOutlet weak var footerHeight: NSLayoutConstraint!
    @IBOutlet weak var higherTitleLabel: UILabel!
    @IBOutlet weak var higherTitleDist: NSLayoutConstraint!
    @IBOutlet weak var allTopDIst: NSLayoutConstraint!
    @IBOutlet weak var lessThanDIst: NSLayoutConstraint!
    @IBOutlet weak var higherTitleLeadingDist: NSLayoutConstraint!
    @IBOutlet weak var titleLeadingDist: NSLayoutConstraint!
    @IBOutlet weak var blockBottomDist: NSLayoutConstraint!
    
    var content = (title: "", content: "") {
        didSet {
            for v in higherTitleLabel.subviews {v.removeFromSuperview()}
            if let t = thread.tag?.rawValue, scene == .thread || isFirstFloor {
                let w = (t as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]).width + 10
                higherTitleLeadingDist.constant = w + 16
                higherTitleLabel += UILabel(frame: .init(x: -w-8, y: 0, width: w, height: 21)).setAsTagLabel(t)
                higherTitleLabel.clipsToBounds = false
                higherTitleLabel.layer.masksToBounds = false
            } else {
                higherTitleLeadingDist.constant = 8
            }
            titleLabel.text = content.title
            higherTitleLabel.text = content.title
            
            mainTextView.text = content.content
            
            if scene != .thread {
                titleLabel.isHidden = true
                titleDist.constant = -titleLabel.frame.height
            }
            if !isFirstFloor {
                higherTitleLabel.isHidden = true
                allTopDIst.constant = 0
                lessThanDIst.constant = 0
            } else {
                higherTitleLabel.isHidden = false
                allTopDIst.constant = 8
                lessThanDIst.constant = 100
            }
            
        }
    }
    
    var folded: Bool = false {
        didSet {
            (idLabel.subviews + cornerLabel.subviews).forEach({$0.removeFromSuperview()})
            if folded || (scene == .thread && thread.tag != nil) {
                let t = (scene == .thread ? thread.tag?.rawValue : nil) ?? "被踩过多"
                let w = (t as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]).width + 10
                (floor != nil ? cornerLabel : idLabel) += UILabel(frame: .init(x: floor != nil ? -10 : 65, y: 5, width: w, height: 20)).setAsTagLabel(t)
                mainView.bringSubviewToFront(floor != nil ? cornerLabel : idLabel)
            }
            if folded {
                blockBottomDist.constant = 6
                replyToName.isEnabled = false
            } else {
                blockBottomDist.constant = 3000
                replyToName.isEnabled = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        selectionStyle = .none
        likedBtn.adjustsImageWhenHighlighted = true
        likedBtn.adjustsImageWhenDisabled = false
        commentBtn.adjustsImageWhenDisabled = false
        readBtn.adjustsImageWhenDisabled = false
        timeLabel.textColor = .gray
        timeLabel.text = ""
        replyToName.setTitle("", for: .normal)
        replyToName.isEnabled = false
        contentView.clipsToBounds = false
        contentView.superview?.clipsToBounds = false
        
        mainTextView.translatesAutoresizingMaskIntoConstraints = false
        mainTextView.sizeToFit()
        mainTextView.isScrollEnabled = false
        mainTextView.contentInset = .zero
        mainTextView.textContainer.lineFragmentPadding = 0
        mainTextView.isEditable = false
        mainTextView.isSelectable = false
        mainTextView.isUserInteractionEnabled = false
        mainTextView.delegate = self
        mainTextView.backgroundColor = .tertiarySystemBackground
        
        footerHeight.constant = 0
        orderBtn.isHidden = true
        orderBtn.addTarget(self, action: #selector(orderBtnClicked(_:)), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print(URL, "\(interaction.rawValue)")
        if (URL.absoluteString.hasPrefix("http://wukefenggao.cn/viewThread/") || URL.absoluteString.hasPrefix("wukefenggao.cn/viewThread/")) && interaction == .invokeDefaultAction {
            let u = UIKit.URL(string: "wkfg://" + URL.absoluteString.replacingOccurrences(of: "http://wukefenggao.cn/viewThread/", with: "").replacingOccurrences(of: "wukefenggao.cn/viewThread/", with: ""))!
            UIApplication.shared.open(u)
            return false
        } else {
            return true
        }
    }
    
    var liked: LikeState = .none {
        didSet {
            likedBtn.setImage(
                UIImage(systemName: liked.rawValue,
                        withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                for: .normal
            )
        }
    }
    
    @IBAction func like(_ sender: Any) {
        self.likedBtn.isEnabled = false
        DispatchQueue.global().async {
            {() -> Bool in
                switch self.liked {
                case .none:
                    if sender is Int {
                        return self.floor.id == "0"
                            ? Network.dislikeThread(for: self.thread.id)
                            : Network.dislikeFloor(for: self.thread.id, floor: self.floor.id)
                    } else {
                        return self.floor.id == "0"
                            ? Network.likeThread(for: self.thread.id)
                            : Network.likeFloor(for: self.thread.id, floor: self.floor.id)
                    }
                case .like:
                    return self.floor.id == "0"
                        ? Network.cancelLikeThread(for: self.thread.id)
                        : Network.cancelLikeFloor(for: self.thread.id, floor: self.floor.id)
                case .disL:
                    return self.floor.id == "0"
                        ? Network.cancelDislikeThread(for: self.thread.id)
                        : Network.canceldislikeFloor(for: self.thread.id, floor: self.floor.id)
                }
            }()..{ success in
                DispatchQueue.main.async {
                    self.likedBtn.isEnabled = true
                    if success {
                        switch self.liked {
                        case .none:
                            if sender is Int {
                                self.liked = .disL; self.floor.nDisliked += 1
                            } else {
                                self.liked = .like; self.floor.nLiked += 1
                            }
                        case .like: self.liked = .none; self.floor.nLiked -= 1
                        case .disL: self.liked = .none; self.floor.nLiked += 1
                        }
                        if let dd = self.parentVC.d as? Floor.Manager, let i = dd.data.firstIndex(where: {$0.id == self.floor.id}) {
                            dd.data[i].setLikeStatus(nLiked: self.floor.nLiked, nDisliked: self.floor.nDisliked, hasLiked: self.liked)
                        }
                        self.likedBtn.setTitle("\(self.floor.nLiked - self.floor.nDisliked)", for: .normal)
                    } else { self.parentVC.showAlert("网络错误", style: .failure) }
                }
            }
        }
    }
    
    func withVC(_ vc: MainVC) -> Self {
        parentVC = vc
        return self
    }
    
    @IBAction func comment(_ sender: Any) {
        parentVC.tryToReplyTo(floor: floor.id)
    }
    
    // MARK: - Thread
    
    func setAs(thread t: Thread, allowFold: Bool = true) -> Self {
        thread = t
        scene = .thread
        
        idLabel.text = "#\(t.id)"
        
        var disp = "", limit = 4
        _ = t.content.components(separatedBy: "\n").reduce(0) {
            if $0 == limit {
                disp += "..."
            } else if $0 < limit {
                disp += ($0 == 0 ? "" : "\n") + $1
            }
            return $0 + Int(($1 as NSString).boundingRect(with: .init(width: mainView.frame.width - 16, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: mainTextView.font!], context: nil).height / mainTextView.font!.lineHeight)
        }
        mainTextView.textContainer.maximumNumberOfLines = limit
        mainTextView.textContainer.lineBreakMode = .byTruncatingTail
        content = (t.title, disp)
        
        likedBtn.setTitle("\(t.nLiked - t.nDislike)", for: .normal)
        readBtn.setTitle("\(t.nRead)", for: .normal)
        commentBtn.setTitle("\(t.nCommented)", for: .normal)
        
        cornerWidth.constant = 60
        cornerLabel.text = Util.dateToDeltaString(t.lastUpdateTime)
        
        if thread.isTop {
            headLabel.text = String("公告")
            headLabel.layer.backgroundColor = t.color[0].cgColor
            headLabel.layer.cornerRadius = 15
            headLabel.textColor = .white
            headLabel.font = .systemFont(ofSize: 12, weight: .medium)
            headImageView.image = UIImage()
            headImageView.backgroundColor = nil
        } else {
            headLabel.text = ""
            headLabel.layer.backgroundColor = .none
            headImageView.backgroundColor = t.color[0]
            headImageView.image = UIImage(named: "hatw80")
            headImageView.layer.cornerRadius = headImageView.frame.height / 2
        }
        idLabelHeight.constant = idHeight.constant
        
        likedBtn.isEnabled = false
        commentBtn.isEnabled = false
        readBtn.isEnabled = false
        
        folded = thread.folded && allowFold
        
        return self
    }
    
    // MARK: - Floor
    
    @objc func moveTo(_ sender: Any) {
        (parentVC.d as! Floor.Manager, String(floor.replyToFloor!))..{ (dd, to) in
            if floor.replyToFloor! > 0,  let idx = dd.data.firstIndex(where: {$0.id == to}) {
                parentVC.tableView.scrollToRow(at: .init(row: idx + 1, section: 0), at: dd.order == .earliest ? .top : .none, animated: true)
            } else {
                parentVC.showAlert("该楼层暂未加载或不存在", style: .warning)
            }
        }
    }
    
    func setAs(floor f: Floor, forThread t: Thread, firstFloor: Bool = false, order o: Order = .earliest) -> Self {
        if f.fake {
            return self
        }
        thread = t
        floor = f
        isFirstFloor = firstFloor
        scene = .floor
        order = o
        self.orderBtn.setTitle(order.rawValue, for: .normal)
        
        name = t.name[Int(f.name)!]
        
        idLabel.text = name +
            (((f.replyToFloor ?? 0) == 0)
                ? ""
                : " 回复 "
            )
        if (f.replyToFloor ?? 0) != 0 {
            replyToName.isEnabled = true
            replyToNameDist.constant = (idLabel.text! as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]).width + 8
            replyToName.setTitle("#\(f.replyToFloor!) \(t.name[Int(f.replyToName!)!])", for: .normal)
            replyToName.setTitleColor(t.color[Int(f.replyToName!)!], for: .normal)
            replyToName.addTarget(self, action: #selector(moveTo(_:)), for: .touchUpInside)
        } else {
            replyToName.isEnabled = false
            replyToName.setTitle("", for: .normal)
            replyToName.removeTarget(self, action: #selector(moveTo(_:)), for: .touchUpInside)
        }
        timeLabel.text = Util.dateToDeltaString(f.time)
        
        headLabel.text = String(name.components(separatedBy: " ").last!.first!)
        headLabel.layer.backgroundColor = t.color[Int(f.name)!].cgColor
        headLabel.layer.cornerRadius = 15
        headLabel.textColor = .white
        headLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        content = (isFirstFloor ? t.title : "", f.content)
        likedBtn.setTitle("\(f.nLiked - f.nDisliked)", for: .normal)
        cornerLabel.text = "#\(floor.id)"
        cornerLabel.fontSize = 14
        
        liked = f.hasLiked
        commentBtn.setTitle("回复", for: .normal)
        commentBtn.contentHorizontalAlignment = .right
        
        commentDist.constant = -readBtn.frame.width
        readBtn.isHidden = true
        mainTextView.isUserInteractionEnabled = true
        mainTextView.isSelectable = true
        
        
        likedBtn.adjustsImageWhenDisabled = true
        likedBtn.isHidden = isFirstFloor && !t.isFromFloorList
        orderBtn.isHidden = !isFirstFloor
        orderBtn.isEnabled = true
        footerHeight.constant = isFirstFloor ? 35 : 0
        
        folded = floor.folded && !isFirstFloor
        
        return self
    }
    
    var order: Order = .earliest
    
    
    @objc func orderBtnClicked(_ sender: UIButton) {
        DropDown(anchorView: sender, selectionAction: { (i, s) in
            if self.order.rawValue != s {
                self.order = Order.allCases.first{$0.rawValue == s}!
                self.orderBtn.setTitle(self.order.rawValue, for: .normal)
                self.orderBtn.isEnabled = false
                self.parentVC.setReplyOrder(self.order)
            }
        }, dataSource: Order.allCases.map{$0.rawValue}).show()
    }
    
    // MARK: - Message
    
    func setAs(message m: Message) -> Self {
        message = m
        _ = setAs(thread: m.thread, allowFold: false)
        cornerLabel.text = m.judge == 0 ? "未读" : "已读"
        cornerLabel.textColor = m.judge == 0 ? .systemBlue : .label
        content.content = m.ty == 0 ? "有人回复了你！" : "有\(m.ty)人赞了你！"
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.superview?.layer.masksToBounds = false
        mainView.applyCardStyle(clip: folded)
    }
    
}
