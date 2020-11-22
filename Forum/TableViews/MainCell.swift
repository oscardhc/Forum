//
//  MainCell.swift
//  Forum
//
//  Created by Oscar on 2020/9/29.
//

import UIKit

class MainCell: UITableViewCell {

    enum Scene {
        case thread, floor, message
    }
    
    var scene = Scene.thread
    
    var thread: Thread!
    var floor: Floor!
    var message: Message!
    var isFirstFloor: Bool!
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
    
    var content = (title: "", content: "") {
        didSet {
            if scene != .thread {
                titleLabel.isHidden = true
                titleDist.constant = -titleLabel.frame.height
            }
            titleLabel.text = content.title
            mainTextView.text = content.content
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
        
        mainTextView.translatesAutoresizingMaskIntoConstraints = false
        mainTextView.sizeToFit()
        mainTextView.isScrollEnabled = false
        mainTextView.contentInset = .zero
        mainTextView.textContainer.lineFragmentPadding = 0
        mainTextView.isEditable = false
        mainTextView.isSelectable = false
        mainTextView.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        mainView.layer.backgroundColor = UIColor.systemGray6.cgColor
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
    
    func setAs(thread t: Thread) -> Self {
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
        cornerLabel.text = Util.dateToDeltaString(t.lastUpdateTime)
        headImageView.backgroundColor = t.color[0]
        headImageView.image = UIImage(named: "hat40")
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
        idLabelHeight.constant = idHeight.constant
        
        likedBtn.isEnabled = false
        commentBtn.isEnabled = false
        readBtn.isEnabled = false
        
        return self
    }
    
    // MARK: - Floor
    
    @objc func moveTo(_ sender: Any) {
        parentVC.tableView.scrollToRow(at: .init(row: floor.replyToFloor!, section: 0), at: .top, animated: true)
    }
    
    func setAs(floor f: Floor, forThread t: Thread, firstFloor: Bool = false) -> Self {
        thread = t
        floor = f
        isFirstFloor = firstFloor
        scene = .floor
        
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
        
        let cons: CGFloat = 30
        idHeight.constant = cons
        headWidth.constant = cons
        headLabel.text = String(idLabel.text!.first!)
        headLabel.layer.backgroundColor = color.cgColor
        headLabel.layer.cornerRadius = cons / 2
        
        content = (isFirstFloor ? t.title : "", f.content)
        likedBtn.setTitle("\(f.nLiked)", for: .normal)
        cornerLabel.text = " #\(floor.id)"
        liked = f.hasLiked
        commentBtn.setTitle("回复", for: .normal)
        commentBtn.contentHorizontalAlignment = .right
        
        commentDist.constant = -readBtn.frame.width
        readBtn.isHidden = true
        mainTextView.isUserInteractionEnabled = true
        mainTextView.isSelectable = true
        
        return self
    }
    
    // MARK: - Message
    
    func setAs(message m: Message) -> Self {
        message = m
        _ = setAs(thread: m.thread)
        cornerLabel.text = m.judge == 0 ? "未读" : "已读"
        content.content = m.ty == 0 ? "有人回复了你！" : "有\(m.ty)人赞了你！"
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.applyCardStyle()
    }
    
}
