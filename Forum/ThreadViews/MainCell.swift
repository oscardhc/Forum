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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAsThread(thread t: Thread) {
        titleLabel.text = t.title
        idLabel.text = t.id
        contentLabel.text = t.summary
        likedBtn.setTitle("\(t.liked) liked", for: .normal)
        readLabel.text = "\(t.read) read"
        commentBtn.setTitle("\(t.commented) comments", for: .normal)
    }
    
    func setAsFloorHead(floor f: Floor) {
        idLabel.text = f.name + " -> " + (f.replyToName ?? "NIL")
        
        contentLabel.text = f.content
        contentLabel.frame = titleLabel.frame
        titleLabel.text = ""
        likedBtn.setTitle("\(f.liked) liked", for: .normal)
    }
    
    override func layoutSubviews() {
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = false
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0, height: 3);
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.borderWidth = 1.0
        mainView.layer.borderColor = UIColor.gray.cgColor
//        mainView.backgroundColor = .lightGray
    }
    
}
