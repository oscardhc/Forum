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
    func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? { return nil }
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

enum LikeState: String {
    case none = "hand.thumbsup", like = "hand.thumbsup.fill", disL = "hand.thumbsdown.fill"
    static func with(_ i: Int) -> LikeState {
        [.disL, .none, .like][i + 1]
    }
}

enum Tag: String, CaseIterable {
    case unconfortable = "令人不适", sexRelated = "性相关", policsRelated = "政治相关", unconfirmed = "未经证实", abuse = "引战"
}

struct Thread: DATA {
    
    enum Category: String, CaseIterable {
        case all = "主干道", sport = "校园", music = "音乐", science = "科学", it = "数码", entertainment = "娱乐", emotion = "情感", social = "社会", others = "其他"
    }
    
    var id = "", title = "", content = "", tag: Tag?, folded = true
    var type: Category = .all
    var nLiked = 0, nRead = 0, nCommented = 0
    var hasLiked = LikeState.like, hasFavoured = false, isTop = false, isFromFloorList = false
    var postTime = Date(), lastUpdateTime = Date()
    var name: NameG, color: ColorG
    
    static var cnt = 1
    
    init(json: Any, isfromFloorList li: Bool = false) {
        let thread  = json as! [String: Any]
        
        nCommented = thread["Comment"] as! Int
        id = thread["ThreadID"] as! String
        nRead = thread["Read"] as! Int
        content = thread["Summary"] as! String
        nLiked = (thread["Like"] as! Int) - (thread["Dislike"] as! Int)
        title = thread["Title"] as! String
        hasLiked = {$0 == nil ? .like : LikeState.with($0!)}(thread["WhetherLike"] as? Int)
        hasFavoured = (thread["WhetherFavour"] as? Int ?? 0) == 1
        isTop = (thread["WhetherTop"] as? Int) == 1
        isFromFloorList = li
        
        tag = Int(id)! % 3 != 0 ? (nLiked % 3 == 2 ? .sexRelated : .unconfortable) : nil
        
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
    
    func setedFolded(_ b: Bool) -> Self {
        var res = self; res.folded = b; return res;
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
        
        var pr = G.viewStyle.content
        var filtered = [Thread]()
        
        override var data: [Thread] {
            didSet {
                let li = G.blockedList.content
                pr = G.viewStyle.content
                filtered = data.compactMap() {
                    if li.contains($0.id) { return nil }
                    if $0.tag == nil { return $0.setedFolded(false) }
                    switch pr[String(describing: $0.tag!)] ?? 0 {
                    case 2: return nil
                    case 1: return $0.setedFolded($0.folded)
                    default: return $0.setedFolded(false)
                    }
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
            cell.setAs(thread: index < self.count ? filtered[index] : Thread(), topTrend: (sortType == .trending && index < 3) ? index : nil)
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? {
            if filtered[index].folded && commit {
                let i = data.firstIndex(where: {$0.id == filtered[index].id})!
                data[i].folded = false
                (vc as! MainVC).tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                return nil
            } else {
                return MainVC.new(.floors, filtered[index])..{
                    commit => vc >> $0
                }
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
    var hasLiked = LikeState.none
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
        hasLiked = LikeState.with(floor["WhetherLike"] as! Int)
        nLiked = floor["Like"] as! Int
    }
    
    class Manager: DataManager<Floor> {
        
        var thread: Thread
        var reverse = false
        
//        var filtered: [Floor]
        
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
        
        override func didSelectedRow(_ vc: UIViewController, index: Int, commit: Bool = true) -> UIViewController? {
            if data[index].folded {
                let i = data.firstIndex(where: {$0.id == filtered[index].id})!
                data[i].folded = false
                (vc as! MainVC).tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        
    }
    
}

struct Message: DATA {
    
    class Manager: DataManager<Message> {
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(message: index < self.count ? data[index] : Message(Thread()))
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
    
    init(_ t: Thread) {
        self.thread = t
    }
    
    init(json: Any) {
        let msg = json as! [String: Any]
        print(msg)
        thread = Thread(json: json)
        ty = msg["Type"] as! Int
        judge = msg["Judge"] as! Int
    }
    
    
}
