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
    var content: String {get}
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

// RandomSeed


struct Thread: DATA {
    
    enum Category: String, CaseIterable {
        case all = "主干道", sport = "体育", music = "音乐", science = "科学", it = "数码", entertainment = "娱乐", emotion = "情感", social = "社会", others = "其他"
    }
    
    var id = "", title = "", content = ""
    var type: Category = .all
    var nLiked = 0, nRead = 0, nCommented = 0
    var hasLiked = false, hasFavoured = false
    var postTime = Date(), lastUpdateTime = Date()
    var name: NameGenerator
    
    static var cnt = 1
    
//    init() {}
    init(json: Any) {
        let thread  = json as! [String: Any]
//        print("trying to init thread from json", thread)
        nCommented = thread["Comment"] as! Int
        id = thread["ThreadID"] as! String
        nRead = thread["Read"] as! Int
        content = thread["Summary"] as! String
        nLiked = thread["Like"] as! Int
        title = thread["Title"] as! String
        
        name = NameGenerator(
            theme: NameGenerator.Theme.init(rawValue: thread["AnonymousType"] as! String) ?? .aliceAndBob,
            seed: thread["RandomSeed"] as! UInt)
        
        lastUpdateTime = Util.stringToDate(thread["LastUpdateTime"] as! String)
        postTime = Util.stringToDate(thread["PostTime"] as! String)
    }
    
//    static func samplePost() -> Thread {
//        var p = Thread()
//        p.id = "00001"
//        p.title = "This is a title"
//        p.content = "From the first floor."
//        for _ in 0..<cnt * 3 + 2 {
//            p.content += "\nFrom the first floor."
//        }
//        p.nLiked = cnt * 333
//        p.nCommented = cnt * 2
//        p.nRead = cnt * 114514
//        cnt += 1
//        return p
//    }
    
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
        
        init(type: Network.NetworkGetThreadType) {
            sortType = type
        }
        
        override func networking(lastSeenID: String) -> [Thread] {
            Network.getThreads(type: sortType, inBlock: block, lastSeenID: lastSeenID)
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(thread: data[index])
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int) {
            vc >> MainVC.new(.floors, data[index])
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
        
        init(for t: Thread) {
            thread = t
            super.init()
        }
        
        override var count: Int {data.count + 1}
        
        override func networking(lastSeenID: String = "NULL") -> [Floor] {
            (data, thread.hasLiked, thread.hasFavoured) = Network.getFloors(for: thread.id, lastSeenID: lastSeenID)
            return data
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
        
    }
    
    var id = "", title = "", content = ""
    var ty = 0, judge = 0, time = Date()
    
    init(json: Any) {
        let msg = json as! [String: Any]
        id = msg["ThreadID"] as! String
        title = msg["Title"] as! String
        content = msg["Summary"] as! String
        ty = msg["Type"] as! Int
        judge = msg["Judge"] as! Int
        time = Util.stringToDate(msg["PostTime"] as! String)
    }
    
    
}
