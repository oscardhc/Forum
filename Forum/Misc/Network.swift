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
    static var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyaWQiOiIyM2EzMDhiNjgxYTIwYjQ5YjlmYzFiNzA0MjdlNWNmNjQyMTAyMDdmMDQwZWZiZTEyZGViZDYxM2VmZDJlMGI5IiwiZGV2aWNlaWQiOiJDRDAwNTMwMS02RDlDLTQ2MEMtOUZBNS03RjZGRTRBQzkwMzUiLCJpYXQiOjE2MDMxNzU3NDIsImV4cCI6MTYwNTc2Nzc0Mn0.BqAbK7QDOOhR-IYl-PJI3lYDY8Lyd1fXbx4ERrA9jmQ"
    
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
            "op_code": op_code, "pa_1": pa_1, "pa_2": pa_2, "pa_3": pa_3, "pa_4": pa_4, "pa_5": pa_5, "Token": token
        ]) {
            return done(result)
        } else {
            print("FAIL!")
            return nil
        }
    }
    
    static func getAllThreads() -> [Post] {
        getData(op_code: "d", pa_1: "NULL") {
            ($0["thread_list"]! as! [Any]).map() {
                Post(json: $0)
            }
        } ?? []
    }
    
    static func getAllFloors(for threadID: String) -> [Floor] {
        getData(op_code: "2", pa_1: threadID) {
            ($0["floor_list"]! as! [Any]).map() {
                Floor(json: $0)
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
    
    static func likeFloor(for threadID: String, floor: String) -> Bool {
        getData(op_code: "8", pa_1: threadID, pa_2: "0", pa_3: "1", pa_4: floor, done: {_ in true}) ?? false
    }
    
    static func newPost(title: String, block: String, content: String) -> Bool {
        getData(op_code: "3", pa_1: title, pa_2: block, pa_3: content, done: {_ in true}) ?? false
    }
    
}
