//
//  MainVCSearch.swift
//  Forum
//
//  Created by Oscar on 2020/11/30.
//

import UIKit

extension MainVC: UISearchBarDelegate {
    func commitSearch() {
        if let tx = search.searchBar.text {
            (self.d as! Thread.Manager)..{
                $0.searchFor = tx
            }
            inSearchMode = true
            clearAll()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarCancelButtonClicked(searchBar)
        commitSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(false)
        self.navigationItem.titleView = nil
    }
}


class SearchBarContainerView: UIView {

    let searchBar: UISearchBar

    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = UIColor.white
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .done
        searchBar.showsCancelButton = true
        addSubview(searchBar)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}
