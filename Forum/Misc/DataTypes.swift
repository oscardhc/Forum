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
//    var content: String {get}
}

class BaseManager {
    var count: Int { 0 }
    func initializeCell(_ cell: MainCell, index: Int) -> MainCell { cell }
    func getInitialContent() -> Int { -1 }
    func getMoreContent() -> Int { -1 }
    func didSelectedRow(_ vc: UIViewController, index: Int) {}
}

class DataManager<T: DATA>: BaseManager {
    
    var data = [T]()
    override var count: Int { data.count }
    
    func networking(lastSeenID: String = "NULL") -> [T] { fatalError() }
    
    // return the number of data fetched
    override func getInitialContent() -> Int {
        let fetched = networking()
        data = fetched
        return fetched.count
    }
    override func getMoreContent() -> Int {
        if let last = data.last?.id {
            let fetched = networking(lastSeenID: last)
            data += fetched
            return fetched.count
        }
        return 0
    }
    
}

struct Thread: DATA {
    
    enum Category: String, CaseIterable {
        case all = "主干道", sport = "体育", music = "音乐", science = "科学", it = "数码", entertainment = "娱乐", emotion = "情感", social = "社会", others = "其他"
    }
    
    var id = "", title = "", content = ""
    var type: Category = .all
    var nLiked = 0, nRead = 0, nCommented = 0
    var hasLiked = false, hasFavoured = false
    var postTime = Date(), lastUpdateTime = Date()
    var name: NameG, color: ColorG
    
    static var cnt = 1
    
    init(json: Any) {
        let thread  = json as! [String: Any]
        nCommented = thread["Comment"] as! Int
        id = thread["ThreadID"] as! String
        nRead = thread["Read"] as! Int
        content = thread["Summary"] as! String
        nLiked = thread["Like"] as! Int
        title = thread["Title"] as! String
        hasLiked = (thread["WhetherLike"] as! Int) == 1
        hasFavoured = (thread["WhetherFavour"] as? Int ?? 0) == 1
        
        name = NameG(
            theme: NameTheme.init(rawValue: thread["AnonymousType"] as! String) ?? .aliceAndBob,
            seed: thread["RandomSeed"] as! Int)
        color = ColorG(theme: .cold, seed: Int(id)!)
        
        lastUpdateTime = Util.stringToDate(thread["LastUpdateTime"] as! String)
        postTime = Util.stringToDate(thread["PostTime"] as! String)
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
        
        init(type: Network.NetworkGetThreadType) {
            sortType = type
        }
        
        func search(text: String?) {
            searchFor = text
            data = []
        }
        
        override func networking(lastSeenID: String) -> [Thread] {
            searchFor == nil
                ? Network.getThreads(type: sortType, inBlock: block, lastSeenID: lastSeenID)
                : Network.searchThreads(keyword: searchFor!, lastSeenID: lastSeenID)
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            print("..........init cell", cell.frame, cell.mainTextView.frame, cell.mainTextView.contentSize)
            return cell.setAs(thread: data[index])
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int) {
            let subVC = MainVC.new(.floors, data[index])
            subVC.fatherThreadListView = (vc as! MainVC)
            vc >> subVC
        }
        
    }
    
}

struct Floor: DATA {
    
    var id = ""
    var name = "", content = ""
    var nLiked = 233
    var hasLiked = false
    var time = Date()
    
    var replyToName: String?
    var replyToFloor: Int?
    
    init() {}
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
        
        init(_ t: Thread) {
            thread = t
            super.init()
        }
        
        override var count: Int {data.count + 1}
        
        override func networking(lastSeenID: String = "NULL") -> [Floor] {
            var newData = [Floor]()
            (newData, thread) = Network.getFloors(for: thread.id, lastSeenID: lastSeenID)
            return newData
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            index == 0
                ? cell.setAs(floor: thread.generateFirstFloor(), forThread: thread, firstFloor: true)
                : cell.setAs(floor: data[index - 1], forThread: thread, firstFloor: false)
        }
        
    }
    
}

struct Message: DATA {
    
    class Manager: DataManager<Message> {
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(message: data[index])
        }
        
        override func networking(lastSeenID: String = "NULL") -> [Message] {
            Network.getMessages(lastSeenID: lastSeenID)
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int) {
            let subVC = MainVC.new(.floors, data[index].thread)
            subVC.fatherThreadListView = (vc as! MainVC)
            vc >> subVC
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
