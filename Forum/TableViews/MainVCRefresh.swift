//
//  MainVCRefresh.swift
//  Forum
//
//  Created by Oscar on 2020/11/30.
//

import UIKit

extension MainVC {
    func hasTappedAgain() {
        print(">>>>>>>>>>>>>>>>>>>>>>>", tableView.refreshControl!.isRefreshing, tryDoubleTapping, firstLoading)
        if tableView.refreshControl!.isRefreshing || tryDoubleTapping || firstLoading {
            return
        }
        let y = self.tableView.refreshControl!.frame.maxY + self.tableView.adjustedContentInset.top
        let o = self.tableView.contentOffset.y
        
        if o < -30 || self.scene == .floors {
            self.isDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
            self.tableView.refreshControl?.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.refresh()
            }
        } else {
            self.tryDoubleTapping = true
            self.tableView.setContentOffset(CGPoint(x: 0, y: -y), animated: true)
        }
    }
    
    func updateFavour() {
        if scene == .floors {
            topCornerBtn.image = UIImage(systemName: (d as! Floor.Manager).thread.hasFavoured ? "star.fill" : "star")
            topCornerBtn.isEnabled = true
        }
    }
    
    func clearAll(thenRefresh: Bool = true) {
        let prev = self.d.count
        _ = self.d.clear()
        footer.setTitle("正在加载...", for: .idle)
        tableView.beginUpdates()
        if prev > self.d.count {
            tableView.deleteRows(at: (self.d.count..<prev).map{IndexPath(row: $0, section: 0)}, with: .fade)
        }
        tableView.endUpdates()
        if thenRefresh {
            refresh()
        }
    }
    
    @objc func refresh() {
//        print("refresh... topdist = ", topDist.constant)
        DispatchQueue.global().async {
            usleep(self.firstLoading ? 100000 : 300000)
            if !self.inSearchMode, let dm = self.d as? Thread.Manager, dm.searchFor != nil {
                dm.resetSearch()
            }
            self.inSearchMode = false
            
            let prev = self.d.count
            _ = self.d.clear()
            let count = self.d.getContent()
            
            DispatchQueue.main.async {
                self.updateFavour()
                self.scene == .floors => self.replyToLabel.text = "To #\(self.floor) \((self.d as! Floor.Manager).displayNameFor(Int(self.floor)!)):"
                self.tableView.refreshControl?.endRefreshing()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + (self.firstLoading ? 0 : 0.25)) {
                    
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
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: (prev..<self.d.count).map{IndexPath(row: $0, section: 0)}, with: .fade)
                        if self.scene == .floors {
                            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                        self.tableView.endUpdates()
                    }
                    self.firstLoading = false
                    
                    if count >= G.numberPerFetch {
                        self.tableView.mj_footer?.resetNoMoreData()
                    } else {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.footer.setTitle(count == -1 ? "网络异常，请稍后重试" : "已经全部加载完毕", for: .noMoreData)
                    }
                }
            }
        }
    }
    
    @objc func loadmore() {
        self.tableView.isScrollEnabled = false
        DispatchQueue.global().async {
            usleep(100000)
            let prev = self.d.count
            let count = self.d.getContent()
            DispatchQueue.main.async {
                self.tableView.mj_footer?.endRefreshing()
                
                if self.d.count > prev {
                    self.tableView.insertRows(at: (prev..<self.d.count).map {IndexPath(row: $0, section: 0)}, with: .automatic)
                }
                
                if count < G.numberPerFetch {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    self.footer.setTitle(count == -1 ? "网络异常，请稍后重试" : "已经全部加载完毕", for: .noMoreData)
                }
                
                self.tableView.isScrollEnabled = true
            }
        }
    }
}
