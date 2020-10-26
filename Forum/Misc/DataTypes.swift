//
//  Thread.swift
//  Forum
//
//  Created by Oscar on 2020/9/20.
//

import Foundation

enum PostType {
    case uncategorized
    case sport
    case study
}

struct Post {
    
    var id = "", title = "", summary = ""
    var type: PostType = .uncategorized
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
    
    static func samplePost() -> Post {
        var p = Post()
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
