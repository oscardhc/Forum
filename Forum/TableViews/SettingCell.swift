//
//  SettingCell.swift
//  Forum
//
//  Created by Oscar on 2020/12/5.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var segment: UISegmentedControl!
    var forTag: Tag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        segment.addTarget(self, action: #selector(segDidChange(_:)), for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    @objc func segDidChange(_ sender: Any) {
        var pr = G.viewStyle.content, npr = [String: Int]()
        for cs in Tag.allCases.map{String(describing: $0)} {
            npr[cs] = pr[cs] ?? 1
        }
        npr[String(describing: forTag!)] = segment.selectedSegmentIndex
        G.viewStyle.content = npr
        print(npr)
    }

}
