//
//  HeaderCell.swift
//  Forum
//
//  Created by Oscar on 2020/11/8.
//

import UIKit

class HeaderCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var gridView: GridBtnView!
    
    func forBlock() -> Self {
        gridView = GridBtnView.basedOn(view: contentView)
        return self
    }

}
