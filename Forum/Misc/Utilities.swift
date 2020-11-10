//
//  Utilities.swift
//  Forum
//
//  Created by Oscar on 2020/10/20.
//

import Foundation

class Util {
    
    static let formatter =  Init(DateFormatter()) {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    static func dateToString(_ date: Date) -> String {
        formatter.string(from: date)
    }
    
    static let trans: [((DateComponents) -> Int?, String)] = [
        ({$0.year}, "year"), ({$0.month}, "month"), ({$0.day}, "day"), ({$0.hour}, "hour"), ({$0.minute}, "minute")
    ]
    
    static func dateToDeltaString(_ date: Date) -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: Date())
        for (f, s) in trans {
            if let n = f(interval), n > 0 {
                return "\(n) \(s)\(n > 1 ? "s" : "") ago"
            }
        }
        return "just now"
    }
    
    static func stringToDate(_ string: String) -> Date {
        formatter.date(from: string)!
    }
    
}

class NameGenerator {
    
    var data = [String]()
    
    subscript(str: String) -> String {
        if let i = Int(str) {
            if i > data.count {
                return data[i % data.count] + "-\(i / data.count)"
            } else {
                return data[i]
            }
        }
        return "ERROR"
    }
    
}
