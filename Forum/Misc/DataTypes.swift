//
//  Thread.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import Foundation
import UIKit

protocol DATA {
    var id: String {get}
}

class BaseManager {
    var count: Int { 0 }
    func initializeCell(_ cell: MainCell, index: Int) -> MainCell { cell }
    func clear() -> Self { return self }
    func getContent() -> Int { -1 }
    @discardableResult func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? { return nil }
}

class DataManager<T: DATA>: BaseManager {
    
    var data = [T]()
    override var count: Int { data.count }
    var last = "NULL"
    
    func networking() -> ([T], String)? { fatalError() }
    override func clear() -> Self {
        (data, last) = ([], "NULL")
        return self
    }
    override func getContent() -> Int {
        if let net = networking() {
            data += net.0
            last = net.1
            return net.0.count
        } else { return -1 }
    }
    
}

struct Thread: DATA {
    
    enum Category: String, CaseIterable {
        case all = "主干道", sport = "体育", music = "音乐", science = "科学", it = "数码", entertainment = "娱乐", emotion = "情感", social = "社会", others = "其他"
    }
    
    var id = "", title = "", content = ""
    var type: Category = .all
    var nLiked = 0, nRead = 0, nCommented = 0
    var hasLiked = false, hasFavoured = false, isTop = false, isFromFloorList = false
    var postTime = Date(), lastUpdateTime = Date()
    var name: NameG, color: ColorG
    
    static var cnt = 1
    
    init(json: Any, isfromFloorList li: Bool = false) {
        let thread  = json as! [String: Any]
        
        nCommented = thread["Comment"] as! Int
        id = thread["ThreadID"] as! String
        nRead = thread["Read"] as! Int
        content = thread["Summary"] as! String
        nLiked = thread["Like"] as! Int
        title = thread["Title"] as! String
        hasLiked = (thread["WhetherLike"] as? Int ?? 0) == 1
        hasFavoured = (thread["WhetherFavour"] as? Int ?? 0) == 1
        isTop = (thread["WhetherTop"] as? Int) == 1
        isFromFloorList = li
        
        name = NameG(
            theme: NameTheme.init(rawValue: thread["AnonymousType"] as! String) ?? .aliceAndBob,
            seed: thread["RandomSeed"] as! Int)
        color = ColorG(theme: .cold, seed: Int(id)!)
        
        lastUpdateTime = Util.stringToDate(thread["LastUpdateTime"] as! String)
        postTime = Util.stringToDate(thread["PostTime"] as! String)
    }
    
    init(_ s: String? = nil) {
        name = NameG(theme: .aliceAndBob, seed: 0)
        color = ColorG(theme: .cold, seed: 0)
        id = s ?? ""
    }
    
    func generateFirstFloor() -> Floor {
        var f = Floor()
        f.name = "0"
        f.id = "0"
        f.content = content
        f.nLiked = nLiked
        f.time = postTime
        f.hasLiked = hasLiked
        return f
    }
    
    class Manager: DataManager<Thread> {
        
        var sortType: Network.NetworkGetThreadType
        var block = Thread.Category.all
        var searchFor: String? = nil
        
        var filtered = [Thread]()
        
        override var data: [Thread] {
            didSet {
                let li = G.blockedList.content
                filtered = data.filter() {
                    !li.contains($0.id)
                }
            }
        }
        
        init(type: Network.NetworkGetThreadType) {
            sortType = type
        }
        
        func search(text: String?) {
            searchFor = text
        }
        
        func resetSearch() {
            searchFor = nil
        }
        
        override func networking() -> ([Thread], String)? {
            return searchFor == nil
                ? Network.getThreads(type: sortType, inBlock: block, lastSeenID: last)
                : Network.searchThreads(keyword: searchFor!, lastSeenID: last)
        }
        
        override var count: Int {
            filtered.count
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
//            cell.setAs(thread: filtered[index], topTrend: (sortType == .trending && index < 3) ? index : nil)
            cell.setAs(thread: index < self.count ? filtered[index] : Thread(), topTrend: (sortType == .trending && index < 3) ? index : nil)
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? {
            MainVC.new(.floors, filtered[index])..{
                commit => vc >> $0
            }
        }
        
        static func openCertainThread(_ vc: UIViewController, id: String) {
            MainVC.new(.floors, Thread(id))..{
                $0.inPreview = true
                vc << $0
            }
        }
        
    }
    
}

struct Floor: DATA {
    
    var id = ""
    var name = "1", content = ""
    var nLiked = 0
    var hasLiked = false
    var time = Date()
    
    var replyToName: String?
    var replyToFloor: Int?
    var fake = false
    
    init(fake: Bool = false) {self.fake = fake}
    init(json: Any) {
        let floor = json as! [String: Any]
        id = floor["FloorID"] as! String
        content = floor["Context"] as! String
        name = floor["Speakername"] as! String
        replyToName = floor["Replytoname"] as? String
        replyToFloor = floor["Replytofloor"] as? Int
        time = Util.stringToDate(floor["RTime"] as! String)
        hasLiked = (floor["WhetherLike"] as! Int) == 1
        nLiked = floor["Like"] as! Int
    }
    
    class Manager: DataManager<Floor> {
        
        var thread: Thread
        var reverse = false
        
        init(_ t: Thread) {
            thread = t
            super.init()
        }
        
        override var count: Int {data.count + 1}
        
        override func networking() -> ([Floor], String)? {
            Network.getFloors(for: thread.id, lastSeenID: last, reverse: reverse)..{
                if let t = $0.1 { thread = t }
            }..\.0
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            index == 0
                ? cell.setAs(floor: thread.generateFirstFloor(), forThread: thread, firstFloor: true, reversed: reverse)
                : cell.setAs(floor: index <= data.count ? data[index - 1] : Floor(fake: true), forThread: thread, firstFloor: false)
        }
        
        func displayNameFor(_ i: Int) -> String {
            thread.name[Int((i == 0 ? thread.generateFirstFloor() : data.first(where: {$0.id == "\(i)"}) ?? thread.generateFirstFloor()).name)!]
        }
        
    }
    
}

struct Message: DATA {
    
    class Manager: DataManager<Message> {
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(message: data[index % self.count])
        }
        
        override func networking() -> ([Message], String)? {
            Network.getMessages(lastSeenID: last)
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? {
            MainVC.new(.floors, data[index].thread)..{
                commit => vc >> $0
            }
        }
        
    }
    
    var thread: Thread
    var ty = 0, judge = 0
    var id: String { thread.id }
    
    init(json: Any) {
        let msg = json as! [String: Any]
        print(msg)
        thread = Thread(json: json)
        ty = msg["Type"] as! Int
        judge = msg["Judge"] as! Int
    }
    
    
}
