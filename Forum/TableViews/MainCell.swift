//
//  MainCell.swift
//  Forum
//
//  Created by Oscar on 2020/9/29.
//

import UIKit

class MainCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likedBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var realCommentBtn: UIButton!
    @IBOutlet weak var cornerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAs(thread t: Thread) -> Self {
        titleLabel.text = t.title
        idLabel.text = t.id
        contentLabel.text = t.summary
        likedBtn.setTitle("\(t.liked) liked", for: .normal)
        readLabel.text = "\(t.read) read"
        commentBtn.setTitle("\(t.commented) comments", for: .normal)
        cornerLabel.text = Util.dateToString(t.postTime)
        return self
    }
    
    func setAs(floor f: Floor) -> Self {
        idLabel.text = f.name + " -> " + (f.replyToName ?? "NIL")
        contentLabel.text = f.content
        contentLabel.frame = titleLabel.frame
        titleLabel.text = ""
        likedBtn.setTitle("\(f.liked) liked", for: .normal)
        cornerLabel.text = Util.dateToString(f.time)
        return self
    }
    
    func setAs(message m: Message) -> Self {
        titleLabel.text = m.title
        idLabel.text = m.id
        contentLabel.text = m.summary
        cornerLabel.text = Util.dateToString(m.time)
        return self
    }
    
    override func layoutSubviews() {
        mainView.applyCardStyle()
    }
    
}
