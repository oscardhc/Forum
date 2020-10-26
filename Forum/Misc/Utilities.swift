//
//  Utilities.swift
//  Forum
//
//  Created by Oscar on 2020/10/20.
//

import Foundation

class Util {
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static func dateToString(_ date: Date) -> String {
        formatter.string(from: date)
    }
    
    static func stringToDate(_ string: String) -> Date {
        formatter.date(from: string)!
    }
    
}
