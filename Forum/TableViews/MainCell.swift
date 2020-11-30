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
    
    let lbl = UILabel(frame: .init(x: 5, y: 5, width: 20, height: 20))..{
        $0.fontSize = 15
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10
        $0.layer.backgroundColor = UIColor.orange.cgColor
        $0.isHidden = true
    }
    
    var content = (title: "", content: "") {
        didSet {
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
    
    var liked = false {
        didSet {
            likedBtn.setImage(
                UIImage(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup",
                        withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
                for: .normal
            )
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        selectionStyle = .none
        likedBtn.adjustsImageWhenDisabled = false
        commentBtn.adjustsImageWhenDisabled = false
        readBtn.adjustsImageWhenDisabled = false
        timeLabel.textColor = .gray
        timeLabel.text = ""
        replyToName.setTitle("", for: .normal)
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
        
        cornerLabel.addSubview(lbl)
        footerHeight.constant = 0
        orderBtn.isHidden = true
        orderBtn.addTarget(self, action: #selector(orderBtnClicked(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        mainView.layer.backgroundColor = UIColor.systemGray6.cgColor
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        true
    }
    
    @IBAction func like(_ sender: Any) {
        if ({
            if liked {
                if floor.id == "0" {
                    return Network.cancelLikeThread(for: thread.id)
                } else {
                    return Network.cancelLikeFloor(for: thread.id, floor: floor.id)
                }
            } else {
                if floor.id == "0" {
                    return Network.likeThread(for: thread.id)
                } else {
                    return Network.likeFloor(for: thread.id, floor: floor.id)
                }
            }
        }()) {
            if liked {
                floor.nLiked -= 1
            } else {
                floor.nLiked += 1
            }
            likedBtn.setTitle("\(floor.nLiked)", for: .normal)
            liked = !liked
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
    
    func setAs(thread t: Thread, topTrend: Int? = nil) -> Self {
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
        
        likedBtn.setTitle("\(t.nLiked)", for: .normal)
        readBtn.setTitle("\(t.nRead)", for: .normal)
        commentBtn.setTitle("\(t.nCommented)", for: .normal)
        
        if let i = topTrend {
            cornerWidth.constant = 30
            lbl.text = "\(i + 1)"
            lbl.isHidden = false
            cornerLabel.text = ""
        } else {
            cornerWidth.constant = 60
            lbl.isHidden = true
            cornerLabel.text = Util.dateToDeltaString(t.lastUpdateTime)
        }

        
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
        
        return self
    }
    
    // MARK: - Floor
    
    @objc func moveTo(_ sender: Any) {
        (parentVC.d as! Floor.Manager, String(floor.replyToFloor!))..{ (dd, to) in
            if floor.replyToFloor! > 0,  let idx = dd.data.firstIndex(where: {$0.id == to}) {
                parentVC.tableView.scrollToRow(at: .init(row: idx + 1, section: 0), at: dd.reverse ? .bottom : .top, animated: true)
            }
        }
//        if let  floor.replyToFloor!
//        parentVC.tableView.scrollToRow(at: .init(row: floor.replyToFloor!, section: 0), at: .top, animated: true)
    }
    
    func setAs(floor f: Floor, forThread t: Thread, firstFloor: Bool = false, reversed: Bool = false) -> Self {
        thread = t
        floor = f
        isFirstFloor = firstFloor
        scene = .floor
        orderReversed = reversed
        updateOrder()
        
        let color = t.color[Int(f.name)!]
        
        idLabel.text = t.name[Int(f.name)!] +
            (((f.replyToFloor ?? 0) == 0)
                ? ""
                : " 回复 "
            )
        if (f.replyToFloor ?? 0) != 0 {
            replyToNameDist.constant = (idLabel.text! as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]).width + 8
            replyToName.setTitle("#\(f.replyToFloor!) \(t.name[Int(f.replyToName!)!])", for: .normal)
            replyToName.addTarget(self, action: #selector(moveTo(_:)), for: .touchUpInside)
        } else {
            replyToName.setTitle("", for: .normal)
            replyToName.removeTarget(self, action: #selector(moveTo(_:)), for: .touchUpInside)
        }
        timeLabel.text = Util.dateToDeltaString(f.time)
        
        headLabel.text = String(t.name[Int(f.name)!].components(separatedBy: " ").last!.first!)
        headLabel.layer.backgroundColor = color.cgColor
        headLabel.layer.cornerRadius = 15
        headLabel.textColor = .white
        headLabel.font = .systemFont(ofSize: 20, weight: .medium)
        
        content = (isFirstFloor ? t.title : "", f.content)
        likedBtn.setTitle("\(f.nLiked)", for: .normal)
        cornerLabel.text = "#\(floor.id)"
        cornerLabel.fontSize = 14
        
        liked = f.hasLiked
        commentBtn.setTitle("回复", for: .normal)
        commentBtn.contentHorizontalAlignment = .right
        
        commentDist.constant = -readBtn.frame.width
        readBtn.isHidden = true
        mainTextView.isUserInteractionEnabled = true
        mainTextView.isSelectable = true
        
        if isFirstFloor {
            footerHeight.constant = 35
            orderBtn.isHidden = false
        } else {
            footerHeight.constant = 0
            orderBtn.isHidden = true
        }
        
        return self
    }
    
//    lazy var dropdown = DropDown(anchorView: orderBtn)..{
//        $0.dataSource = ["最早回复", "最新回复"]
//        $0.backgroundColor = .systemBackground
//        $0.cellHeight = 50
//        $0.textColor = self.traitCollection.userInterfaceStyle == .dark ? .lightText : .darkText
//        $0.selectionAction = { (index: Int, item: String) in
//            self.orderBtn.setTitle(item, for: .normal)
//            self.orderBtn.setImage(
//                UIImage(systemName: index == 1 ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle",
//                        withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
//                for: .normal
//            )
//            self.parentVC.setReplyOrder(reverse: index == 1)
//        }
//    }
    
    var orderReversed = false
    func updateOrder() {
        self.orderBtn.setTitle(orderReversed ? "最新回复" : "最早回复", for: .normal)
        self.orderBtn.setImage(
            UIImage(systemName: orderReversed ? "arrowtriangle.down.circle" : "arrowtriangle.up.circle",
                    withConfiguration: UIImage.SymbolConfiguration(scale: .small)),
            for: .normal
        )
    }
    @objc func orderBtnClicked(_ sender: Any) {
//        dropdown.show()
        orderReversed = !orderReversed
        updateOrder()
        self.orderBtn.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {self.orderBtn.isEnabled = true})
        self.parentVC.setReplyOrder(reverse: orderReversed)
    }
    
    // MARK: - Message
    
    func setAs(message m: Message) -> Self {
        message = m
        _ = setAs(thread: m.thread)
        cornerLabel.text = m.judge == 0 ? "未读" : "已读"
        cornerLabel.textColor = m.judge == 0 ? .systemBlue : .label
        content.content = m.ty == 0 ? "有人回复了你！" : "有\(m.ty)人赞了你！"
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.applyCardStyle()
        
    }
    
}
