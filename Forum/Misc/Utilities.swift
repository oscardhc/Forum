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
    
    enum Theme {
        case aliceAndBob, usPresident
    }
    static let data: [Theme: [String]] = [
        .aliceAndBob: ["Alice", "Bob", "Carol", "Dave", "Eve", "Forest", "George", "Harry", "Issac", "Justin", "Kevin", "Laura", "Mallory", "Neal", "Oscar", "Pat", "Quentin", "Rose", "Steve", "Trent", "Utopia", "Victor", "Walter", "Xavier", "Young", "Zoe"],
        .usPresident: ["Washington", "J.Adams", "Jefferson", "Madison", "Monroe", "J.Q.Adams", "Jackson", "Buren", "W.H.Harrison", "J.Tyler", "Polk", "Z.Tylor", "Fillmore", "Pierce", "Buchanan", "Lincoln", "A.Johnson", "Grant", "Hayes", "Garfield", "Arthur", "Cleveland", "B.Harrison", "McKinley", "T.T.Roosevelt","Taft", "Wilson", "Harding", "Coolidge", "Hoover", "F.D.Roosevelt", "Truman", "Eisenhower", "Kennedy", "L.B.Johnson", "Nixon", "Ford", "Carter", "Reagan", "G.H.W.Bush", "Clinton","G.W.Bush", "Obama", "Trump"]
    ]
    
    static func getName(_ theme: Theme, _ str: String) -> String {
        if var i = Int(str) {
            if i >= data[theme]!.count {
                return data[theme]![i % data.count] + "<\(i / data.count)>"
            } else {
                return data[theme]![i]
            }
        }
        return "ERROR"
    }
    
}

extension String {
    
    func getName(theme: NameGenerator.Theme) -> String {
        NameGenerator.getName(theme, self)
    }
    
}
