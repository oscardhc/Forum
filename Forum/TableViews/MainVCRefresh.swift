//
//  MainVCRefresh.swift
//  Forum
//
//  Created by Oscar on 2020/11/30.
//

import UIKit

extension MainVC {
    func hasTappedAgain() {
        if tableView.refreshControl!.isRefreshing || tryDoubleTapping || firstLoading || isDoubleTapping {
            return
        }
        let y = self.tableView.refreshControl!.frame.maxY + self.tableView.adjustedContentInset.top
        let o = self.tableView.contentOffset.y
        
        if o < -30 || self.scene == .floors {
            self.isDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentOffset.y + 1), animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
                self.tableView.refreshControl?.beginRefreshing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.refresh()
//                    self.clearAll()
                }
            }
        } else {
            self.tryDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
        }
    }
    
    func updateFavour() {
        if scene == .floors {
            navigationItem.rightBarButtonItems![2].setImageTo(UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star"))
            navigationItem.rightBarButtonItems![2].isEnabled = true
//            barThirdBtn.image = UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star")
//            barThirdBtn.isEnabled = true
        }
    }
    
    func clearAll(thenRefresh: Bool = true) {
        let prev = self.d.count
        _ = self.d.clear()
        self.tableView.mj_footer?.resetNoMoreData()
        footer.setTitle("正在加载...", for: .idle)
        tableView.beginUpdates()
        print("++++++++++++++ begin")
        if prev > self.d.count {
            tableView.deleteRows(at: (self.d.count..<prev).map{IndexPath(row: $0, section: 0)}, with: .fade)
        }
        print("-------------- end")
        tableView.endUpdates()
        if thenRefresh {
            refresh()
        }
    }
    
    @objc func refresh() {
//        print("refresh... topdist = ", topDist.constant)
        if isRefreshing {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        isRefreshing = true
        let prev = self.d.count
        
        scene == .floors && prev <= (self.scene == .floors ? 1 : 0) => self.tableView.beginUpdates()
//        print("++++++++++++++ begin")
        
        DispatchQueue.global().async {
            usleep(self.firstLoading ? 100000 : 200000)
            if !self.inSearchMode, let dm = self.d as? Thread.Manager, dm.searchFor != nil {
                dm.resetSearch()
            }
            self.inSearchMode = false
            
            _ = self.d.clear()
            let count = self.d.getContent()
            
            DispatchQueue.main.async {
                self.updateFavour()
                
                if self.scene == .floors {
                    self.floor = "0"
                    self.view.endEditing(false)
                    self.textView.text = ""
                }
                self.tableView.refreshControl?.endRefreshing()
                
                self.scene != .floors && prev <= (self.scene == .floors ? 1 : 0) => self.tableView.beginUpdates()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (self.firstLoading ? 0.0 : 0.25)) {
                    
                    self.footer.setTitle("点击或上拉以加载更多", for: .idle)
                    self.tableView.isScrollEnabled = true
                    
                    if self.isDoubleTapping {
                        let y = self.tableView.refreshControl!.frame.maxY + self.tableView.adjustedContentInset.top
                        self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
                        self.isDoubleTapping = false
                    }
                    
                    if prev > (self.scene == .floors ? 1 : 0) {
                        print("RELOADING!!!")
                        self.tableView.reloadData()
                    } else {
                        self.tableView.insertRows(at: (prev..<self.d.count).map{IndexPath(row: $0, section: 0)}, with: .fade)
                        if self.scene == .floors {
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: self.d.count == 1 ? .automatic : .none)
                        }
//                        print("-------------- end insert", prev, self.d.count)
                        self.tableView.endUpdates()
                    }
                    self.firstLoading = false
                    
                    if count >= G.numberPerFetch {
                        self.tableView.mj_footer?.resetNoMoreData()
                    } else {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.footer.setTitle(count == -1 ? "加载失败" : "已经全部加载完毕", for: .noMoreData)
                    }
                    
                    self.isRefreshing = false
                    
                }
            }
        }
    }
    
    @objc func loadmore() {
//        self.tableView.isScrollEnabled = false
        DispatchQueue.global().async {
            usleep(100000)
            let prev = self.d.count
            let count = self.d.getContent()
            DispatchQueue.main.async {
                self.tableView.isScrollEnabled = false
//                self.tableView.bounces = false
                self.tableView.mj_footer?.endRefreshing()
                
                if self.d.count > prev {
                    self.tableView.insertRows(at: (prev..<self.d.count).map {IndexPath(row: $0, section: 0)}, with: .automatic)
                }
                
                if count < G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    self.footer.setTitle(count == -1 ? "加载失败" : "已经全部加载完毕", for: .noMoreData)
                }
                
                self.tableView.isScrollEnabled = true
//                self.tableView.bounces = true
            }
        }
    }
}
