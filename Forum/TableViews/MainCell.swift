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
    @IBOutlet weak var idBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var cornerLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topDist: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDist: NSLayoutConstraint!
    @IBOutlet weak var commentDist: NSLayoutConstraint!
    @IBOutlet weak var idHeight: NSLayoutConstraint!
    
    var content = (title: "", content: "") {
        didSet {
            if scene != .floor || content.title == "" {
                topLabel.isHidden = true
                topDist.constant = -topLabel.frame.height
            } else {
                topLabel.isHidden = false
                topDist.constant = 8
            }
            if scene != .thread {
                titleLabel.isHidden = true
                titleDist.constant = -titleLabel.frame.height
            }
            topLabel.text = content.title
            titleLabel.text = content.title
            contentLabel.text = content.content
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
        idBtn.adjustsImageWhenDisabled = false
        idBtn.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        idBtn.setTitle("#\(t.id)", for: .normal)
        content = (t.title, t.content)
        likedBtn.setTitle("\(t.nLiked)", for: .normal)
        readBtn.setTitle("\(t.nRead)", for: .normal)
        commentBtn.setTitle("\(t.nCommented)", for: .normal)
        cornerLabel.text = Util.dateToDeltaString(t.postTime)
        
        likedBtn.isEnabled = false
        commentBtn.isEnabled = false
        readBtn.isEnabled = false
        
        return self
    }
    
    // MARK: - Floor
    
    func setAs(floor f: Floor, forThread t: Thread, firstFloor: Bool = false) -> Self {
        thread = t
        floor = f
        isFirstFloor = firstFloor
        scene = .floor
        
        let ss = f.name.getName(theme: t.theme) +
            (((f.replyToFloor ?? 0) == 0)
                ? ""
                : " -> #\(f.replyToFloor!) \(f.replyToName!.getName(theme: t.theme))"
            )
        let speaker = NSMutableAttributedString(string: ss + "\n", attributes: [:])
        
        let tt = Util.dateToDeltaString(f.time)
        let time = NSAttributedString(string: tt, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        speaker.append(time)
        
        idBtn.setAttributedTitle(speaker, for: .normal)
        idHeight.constant = 40
        
        content = (isFirstFloor ? t.title : "", f.content)
        likedBtn.setTitle("\(f.nLiked)", for: .normal)
        cornerLabel.text = " #\(floor.id)"
        liked = f.hasLiked
        commentBtn.setTitle("回复", for: .normal)
        commentBtn.contentHorizontalAlignment = .right
        
        commentDist.constant = -readBtn.frame.width
        readBtn.isHidden = true
        
        return self
    }
    
    // MARK: - Message
    
    func setAs(message m: Message) -> Self {
        message = m
        scene = .message
        
        idBtn.setTitle(m.id, for: .normal)
        content = (m.title, m.content)
        cornerLabel.text = Util.dateToDeltaString(m.time)
        
        likedBtn.isHidden = true
        commentBtn.isHidden = true
        readBtn.isHidden = true
        
        return self
    }
    
    override func layoutSubviews() {
//        print("layout", content, self.frame.height)
        super.layoutSubviews()
        mainView.applyCardStyle()
    }
    
}
