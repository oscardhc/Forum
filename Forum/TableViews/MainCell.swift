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
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var headDistance: NSLayoutConstraint!
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
    
    var content = (title: "", content: "") {
        didSet {
            if scene != .thread {
                titleLabel.isHidden = true
                titleDist.constant = -titleLabel.frame.height
            }
            titleLabel.text = content.title
//            contentLabel.text = content.content
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
        content = (t.title, t.content)
        likedBtn.setTitle("\(t.nLiked)", for: .normal)
        readBtn.setTitle("\(t.nRead)", for: .normal)
        commentBtn.setTitle("\(t.nCommented)", for: .normal)
        cornerLabel.text = Util.dateToDeltaString(t.lastUpdateTime)
        headImageView.backgroundColor = t.color[0]
        headImageView.image = UIImage(named: "hat40")
        headImageView.layer.cornerRadius = headImageView.frame.height / 2
        
        likedBtn.isEnabled = false
        commentBtn.isEnabled = false
        readBtn.isEnabled = false
//        headDistance.constant = -headWidth.constant
        
        return self
    }
    
    // MARK: - Floor
    
    func setAs(floor f: Floor, forThread t: Thread, firstFloor: Bool = false) -> Self {
        thread = t
        floor = f
        isFirstFloor = firstFloor
        scene = .floor
        
        let color = t.color[Int(f.name)!]
        
        let ss = t.name[Int(f.name)!] +
            (((f.replyToFloor ?? 0) == 0)
                ? ""
                : " -> #\(f.replyToFloor!) \(t.name[Int(f.replyToName!)!])"
            )
        let speaker = NSMutableAttributedString(string: ss + "\n", attributes: [:])
        
        let tt = Util.dateToDeltaString(f.time)
        let time = NSAttributedString(string: tt, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        speaker.append(time)
        
        let cons: CGFloat = 30
        
        idLabel.attributedText = speaker
        idHeight.constant = cons
        headWidth.constant = cons
        headLabel.text = String(ss.first!)
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
        scene = .message
        
        idLabel.text = m.id
        content = (m.title, m.content)
        cornerLabel.text = Util.dateToDeltaString(m.time)
        
        likedBtn.isHidden = true
        commentBtn.isHidden = true
        readBtn.isHidden = true
        
        return self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainView.applyCardStyle()
    }
    
}
