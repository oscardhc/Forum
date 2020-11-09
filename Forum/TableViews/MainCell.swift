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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var realCommentBtn: UIButton!
    @IBOutlet weak var cornerLabel: UILabel!
    
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
        likedBtn.titleLabel?.textAlignment = .left
        commentBtn.titleLabel?.textAlignment = .left
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(_ sender: Any) {
        if liked {
            Network.cancelLikeFloor(for: thread.id, floor: floor.id)
            floor.nLiked -= 1
        } else {
            Network.likeFloor(for: thread.id, floor: floor.id)
            floor.nLiked += 1
        }
        likedBtn.setTitle("\(floor.nLiked)", for: .normal)
        
        liked = !liked
    }
    
    // MARK: - Thread
    
    func setAs(thread t: Thread) -> Self {
        thread = t
        scene = .thread
        
        titleLabel.text = t.title
        idLabel.text = "#\(t.id)"
        contentLabel.text = t.summary
        likedBtn.setTitle("\(t.nLiked)", for: .normal)
        readLabel.text = "\(t.nRead) read"
        commentBtn.setTitle("\(t.nCommented)", for: .normal)
        cornerLabel.text = Util.dateToString(t.postTime)
        liked = t.hasLiked
        return self
    }
    
    // MARK: - Floor
    
    func setAs(floor f: Floor, forThread t: Thread) -> Self {
        thread = t
        floor = f
        scene = .floor
        
        idLabel.text = f.name + " -> " + (f.replyToName ?? "NIL")
        contentLabel.text = f.content
        contentLabel.frame = titleLabel.frame
        titleLabel.text = ""
        likedBtn.setTitle("\(f.nLiked)", for: .normal)
        cornerLabel.text = Util.dateToString(f.time) + " #\(floor.id)"
        liked = f.hasLiked
        
        commentBtn.isHidden = true
        readLabel.isHidden = true
        
        return self
    }
    
    // MARK: - Message
    
    func setAs(message m: Message) -> Self {
        message = m
        scene = .message
        
        titleLabel.text = m.title
        idLabel.text = m.id
        contentLabel.text = m.summary
        cornerLabel.text = Util.dateToString(m.time)
        
        likedBtn.isHidden = true
        commentBtn.isHidden = true
        readLabel.isHidden = true
        
        return self
    }
    
    override func layoutSubviews() {
        mainView.applyCardStyle()
    }
    
}
