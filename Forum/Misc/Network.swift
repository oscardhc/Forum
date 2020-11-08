//
//  Network.swift
//  Forum
//
//  Created by Oscar on 2020/9/29.
//

import Foundation
import Socket
import UIKit

class Network {
    
    static let e = JSONEncoder(), ip = "172.81.215.104", port: Int32 = 8080
    
    static private func connect<T: Encodable>(_ data: T) -> [String: Any]? {
        do {
            let data = try e.encode(data)
            
            let s = try Socket.create()
            try s.connect(to: ip, port: port)
            try s.write(from: data)
            
            let rec = try JSONSerialization.jsonObject(
                with: try s.readString()!.data(using: .utf8)!,
                options: .allowFragments
            )
            
            s.close()
            return rec as? [String: Any]
        } catch {
            return nil
        }
    }
    
    static private func getData<T>(
        op_code: String,
        pa_1: String = "0", pa_2: String = "0", pa_3: String = "0", pa_4: String = "0", pa_5: String = "0",
        done: (([String: Any]) -> T)
    ) -> T? {
        if let result = connect([
            "op_code": op_code, "pa_1": pa_1, "pa_2": pa_2, "pa_3": pa_3, "pa_4": pa_4, "pa_5": pa_5, "Token": G.token
        ]) {
            return done(result)
        } else {
            print("FAIL!")
            return nil
        }
    }
    
    enum NetworkGetThreadType: String {
        case time = "1", favoured = "6", my = "7", trending = "d"
    }
//
//    static let parseResultThreads: ([String: Any]) -> [Thread] = {
//        ($0["thread_list"]! as! [Any]).map() {
//            Thread(json: $0)
//        }
//    }
    
    static func getThreads(type: NetworkGetThreadType, lastSeenID: String = "NULL") -> [Thread] {
        getData(op_code: type.rawValue, pa_1: lastSeenID) {
            ($0["thread_list"]! as! [Any]).map {
                Thread(json: $0)
            }
        } ?? []
    }
    
    static func getFloors(for threadID: String, lastSeenID: String = "NULL") -> [Floor] {
        getData(op_code: "2", pa_1: threadID, pa_2: lastSeenID) {
            ($0["floor_list"]! as! [Any]).map {
                Floor(json: $0)
            }
        } ?? []
    }
    
    static func getMessages(lastSeenID: String = "NULL") -> [Message] {
        getData(op_code: "a", pa_1: lastSeenID) {
            ($0["message_list"]! as! [Any]).map {
                Message(json: $0)
            }
        } ?? []
    }
    
    static func requestLogin(with email: String) -> Bool {
        getData(op_code: "0", pa_1: email) {
            $0["VarifiedEmailAddress"] as! Int == 1
        } ?? false
    }
    
    static func performLogin(with email: String, verificationCode: String) -> (Bool, String) {
        getData(op_code: "f", pa_1: email, pa_2: verificationCode, pa_3: UIDevice.current.identifierForVendor!.uuidString) {
            ($0["login_flag"] as! Int == 0, $0["Token"] as! String)
        } ?? (false, "")
    }
    
    static func favourThread(for threadID: String) -> Bool {
        getData(op_code: "5", pa_1: threadID, pa_3: "1", done: {_ in true}) ?? false
    }
    
    static func cancelFavourThread(for threadID: String) -> Bool {
        getData(op_code: "5", pa_1: threadID, pa_3: "2", done: {_ in true}) ?? false
    }
    
    static func likeFloor(for threadID: String, floor: String) -> Bool {
        getData(op_code: "8", pa_1: threadID, pa_3: "1", pa_4: floor, done: {_ in true}) ?? false
    }
    
    static func cancelLikeFloor(for threadID: String, floor: String) -> Bool {
        getData(op_code: "8_2", pa_1: threadID, pa_3: "2", pa_4: floor, done: {_ in true}) ?? false
    }
    
    static func likeThread(for threadID: String) -> Bool {
        getData(op_code: "8_3", pa_1: threadID, pa_3: "1", pa_4: "1", done: {_ in true}) ?? false
    }
    
    static func cancelLikeThread(for threadID: String) -> Bool {
        getData(op_code: "8_3", pa_1: threadID, pa_3: "2", pa_4: "1", done: {_ in true}) ?? false
    }
    
    static func dislikeThread(for threadID: String) -> Bool {
        getData(op_code: "9", pa_1: threadID, pa_3: "1", pa_4: "1", done: {_ in true}) ?? false
    }
    
    static func cancelDislikeThread(for threadID: String) -> Bool {
        getData(op_code: "9_2", pa_1: threadID, pa_3: "1", pa_4: "1", done: {_ in true}) ?? false
    }
    
    static func newThread(title: String, block: String, content: String) -> Bool {
        getData(op_code: "3", pa_1: title, pa_2: block, pa_3: content, done: {_ in true}) ?? false
    }
    
    static func newReply(for threadID: String, floor: String?, content: String) -> Bool {
        getData(op_code: floor == nil ? "4" : "4_2", pa_1: threadID, pa_3: content, pa_4: floor ?? "0", done: {_ in true}) ?? false
    }
    
}
