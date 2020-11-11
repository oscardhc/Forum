//
//  HeaderCell.swift
//  Forum
//
//  Created by Oscar on 2020/11/8.
//

import UIKit

class HeaderCell: UITableViewCell {
    
    var gridView: GridBtnView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        gridView = GridBtnView.basedOn(view: contentView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gridView.setFrame(basedOn: contentView.frame)
    }
    
}
