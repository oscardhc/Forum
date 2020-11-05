//
//  Thread.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import Foundation
import UIKit

enum ThreadType {
    case uncategorized
    case sport
    case study
}

struct Thread {
    
    var id = "", title = "", summary = ""
    var type: ThreadType = .uncategorized
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
    
}

struct Floor {
    
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
        print(floor)
        id = floor["FloorID"] as! String
        content = floor["Context"] as! String
        name = floor["Speakername"] as! String
        replyToName = floor["Replytoname"] as? String
        replyToFloor = floor["Replytofloor"] as? Int
        time = Util.stringToDate(floor["RTime"] as! String)
        liked = floor["Praise"] as! Int
    }
    
}

protocol DataManager {
    
    var count: Int { get }
    func initializeCell(_ cell: MainCell, index: Int) -> MainCell
    
    func getInitialContent()
    /// return whether there is no more data
    func getMoreContent() -> Bool
    
    func didSelectedRow(_ vc: UIViewController, index: Int)
    
}

class ThreadData: DataManager {
    
    var sortType: Network.NetworkGetThreadType
    var threads = [Thread]()
    
    init(type: Network.NetworkGetThreadType) {
        sortType = type
        getInitialContent()
    }
    
    var count: Int {
        threads.count
    }
    
    func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
        cell.setAsThread(thread: threads[index])
    }
    
    func getInitialContent() {
        print("getting initial")
        threads = [Thread.samplePost()] + Network.getThreads(type: sortType)
//            + [Thread.samplePost()]
    }
    
    func getMoreContent() -> Bool {
        if let last = threads.last?.id {
            let data = Network.getThreads(type: sortType, lastSeenID: last)
            threads += data
            print("getting more treads", threads.count, data.count)
            return data.isEmpty
        }
        return false
    }
    
    func didSelectedRow(_ vc: UIViewController, index: Int) {
        vc.navigationController?.pushViewController(
            (*"MainVC" as! MainVC).fl(threads[index]),
            animated: true
        )
    }
    
}

class FloorData: DataManager {
    
    var thread: Thread
    var floors = [Floor]()
    
    init(for t: Thread) {
        thread = t
        getInitialContent()
    }
    
    var count: Int {
        floors.count
    }
    
    func initializeCell(_ cell: MainCell, index: Int) -> MainCell {
        cell.setAsFloorHead(floor: floors[index])
    }
    
    func getInitialContent() {
        floors = [thread.generateFirstFloor()] + Network.getFloors(for: thread.id)
    }
    
    func getMoreContent() -> Bool {
        if let last = floors.last?.id {
            let data = Network.getFloors(for: thread.id, lastSeenID: last)
            floors += data
            return data.isEmpty
        }
        return false
    }
    
    func didSelectedRow(_ vc: UIViewController, index: Int) {
        
    }
    
    
}
