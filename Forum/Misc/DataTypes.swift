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
    
    enum Category {
        case uncategorized
        case sport
        case study
    }
    
    var id = "", title = "", summary = ""
    var type: Category = .uncategorized
    var liked = 0, read = 0, commented = 0
    var visible = true, hasLiked = false, hasDisliked = false, hasFavoured = false
    var postTime = Date(), lastUpdateTime = Date()
    
    static var cnt = 1
    
    init() {}
    init(json: Any) {
        let thread  = json as! [String: Any]
        commented   = thread["Comment"] as! Int
        id          = thread["ThreadID"] as! String
        read        = thread["Read"] as! Int
        summary     = thread["Summary"] as! String
        liked       = thread["Praise"] as! Int
        title       = thread["Title"] as! String
        postTime    = Util.stringToDate(thread["LastUpdateTime"] as! String)
    }
    
    static func samplePost() -> Thread {
        var p = Thread()
        p.id = "00001"
        p.title = "This is a title"
        p.summary = "From the first floor"
        p.liked = cnt * 333
        p.commented = cnt * 2
        p.read = cnt * 114514
        cnt += 1
        return p
    }
    
    func generateFirstFloor() -> Floor {
        var f = Floor()
        f.content = summary
        f.name = "1"
        f.liked = liked
        return f
    }
    
    class Manager: DataManager<Thread> {
        
        var sortType: Network.NetworkGetThreadType
        
        init(type: Network.NetworkGetThreadType) {
            sortType = type
        }
        
        override func networking(lastSeenID: String) -> [Thread] {
            Network.getThreads(type: sortType, lastSeenID: lastSeenID)
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(thread: data[index])
        }
        
        override func didSelectedRow(_ vc: UIViewController, index: Int) {
            vc.navigationController?.pushViewController(
                (*"MainVC" as! MainVC).fl(data[index]),
                animated: true
            )
        }
        
    }
    
}

struct Floor: DATA {
    
    var id = ""
    var name = "", content = ""
    var liked = 233
    var hasLiked = false
    var time = Date()
    
    var replyToName: String?
    var replyToFloor: Int?
    
    init() {}
    init(json: Any) {
//        print(json)
        let floor = json as! [String: Any]
//        print(floor)
        id = floor["FloorID"] as! String
        content = floor["Context"] as! String
        name = floor["Speakername"] as! String
        replyToName = floor["Replytoname"] as? String
        replyToFloor = floor["Replytofloor"] as? Int
        time = Util.stringToDate(floor["RTime"] as! String)
        liked = floor["Praise"] as! Int
    }
    
    class Manager: DataManager<Floor> {
        
        var thread: Thread
        
        init(for t: Thread) {
            thread = t
            super.init()
        }
        
        override func getInitialContent() -> Int {
            let res = super.getInitialContent()
            data.insert(thread.generateFirstFloor(), at: 0)
            print("floor getInitialContent")
            return res
        }
        
        override func networking(lastSeenID: String = "NULL") -> [Floor] {
            Network.getFloors(for: thread.id, lastSeenID: lastSeenID)
        }
        
        override func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
            cell.setAs(floor: data[index])
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
    
    var id = "", title = "", summary = ""
    var ty = "", judge = "", time = Date()
    
    init(json: Any) {
        let msg = json as! [String: Any]
        id = msg["ThreadID"] as! String
        title = msg["Title"] as! String
        summary = msg["Summary"] as! String
        ty = msg["Type"] as! String
        judge = msg["Jusge"] as! String
        time = Util.stringToDate(msg["PostTime"] as! String)
    }
    
    
}
