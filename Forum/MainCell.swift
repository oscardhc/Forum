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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setAsPost(post p: Post) {
        titleLabel.text = p.title
        idLabel.text = p.id
        contentLabel.text = p.summary
        likedBtn.setTitle("\(p.liked) liked", for: .normal)
        readLabel.text = "\(p.read) read"
        commentBtn.setTitle("\(p.commented) comments", for: .normal)
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
