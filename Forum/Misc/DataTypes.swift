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
    func height(width: CGFloat, for index: Int) -> CGFloat { 0 }
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
    override func height(width: CGFloat, for index: Int) -> CGFloat {
//        NSString("123").size(withAttributes: [.font: UIFont(descriptor: UIFontDescriptor(name: "Helvetica", size: 20))])
        let fontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let sz = data[index].content.size(withAttributes: fontAttributes)
        print(width, sz, data[index].content)
        return CGFloat(Int(sz.width) / Int(width) + 1) * sz.height + 170
    }
    
}


struct Thread: DATA {
    
    enum Category {
        case uncategorized
        case sport
        case study
    }
    
    var id = "", title = "", content = ""
    var type: Category = .uncategorized
    var nLiked = 0, nRead = 0, nCommented = 0
    var visible = true, hasLiked = false, hasFavoured = false
    var postTime = Date(), lastUpdateTime = Date()
    var theme = NameGenerator.Theme.usPresident, seed = 0
    
    
    static var cnt = 1
    
    init() {}
    init(json: Any) {
        let thread  = json as! [String: Any]
        nCommented   = thread["Comment"] as! Int
        id          = thread["ThreadID"] as! String
        nRead        = thread["Read"] as! Int
        content     = thread["Summary"] as! String
        nLiked       = thread["Praise"] as! Int
        title       = thread["Title"] as! String
        hasFavoured = (thread["Praise"] as! Int) == 1
        hasLiked = (thread["WhetherLike"] as! Int) == 1
        postTime    = Util.stringToDate(thread["LastUpdateTime"] as! String)
    }
    
    static func samplePost() -> Thread {
        var p = Thread()
        p.id = "00001"
        p.title = "This is a title"
        p.content = "From the first floor."
        for _ in 0..<cnt * 3 + 2 {
            p.content += "\nFrom the first floor."
        }
        p.nLiked = cnt * 333
        p.nCommented = cnt * 2
        p.nRead = cnt * 114514
        cnt += 1
        return p
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
        
        init(type: Network.NetworkGetThreadType) {
            sortType = type
        }
        
//        override func getInitialContent() -> Int {
//            data = [Thread.samplePost()] + [Thread.samplePost()]
//            return 1
//        }
        
        override func networking(lastSeenID: String) -> [Thread] {
            Network.getThreads(type: sortType, lastSeenID: lastSeenID)
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
//        print(json)
        let floor = json as! [String: Any]
//        print(floor)
        id = floor["FloorID"] as! String
        content = floor["Context"] as! String
        name = floor["Speakername"] as! String
        replyToName = floor["Replytoname"] as? String
        replyToFloor = floor["Replytofloor"] as? Int
        time = Util.stringToDate(floor["RTime"] as! String)
        hasLiked = 1 == (floor["WhetherPraise"] as! Int)
        nLiked = floor["Praise"] as! Int
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
            cell.setAs(floor: data[index], forThread: thread, firstFloor: index == 0)
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
