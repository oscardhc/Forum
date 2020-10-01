//
//  Network.swift
//  Forum
//
//  Created by Oscar on 2020/9/29.
//

import Foundation
import Socket

class NetworkManager {
    
    static let e = JSONEncoder(), ip = "172.81.215.104", port: Int32 = 8080
    static var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyaWQiOiI5MGRhMTM3MmQ0NjA1NTY4YTQ3OGQ5OTUxM2Y2MDMyYjRhOTY2OTI2ODc0N2UzZTM0MDI4NGI1YjAxYjE0YzM1IiwiZGV2aWNlaWQiOiJmZWIzM2U2NC02ZjhmLTQzNzMtOTY4MC04ZWE3YmJiM2I2MWMiLCJpYXQiOjE2MDEwMTEzMzIsImV4cCI6MTYwMzYwMzMzMn0.E_mDpNewwbYiv5M-JtyIZaxziDVfYC8-YM6EYT8map0"
    
    static func connect<T: Encodable>(_ data: T) -> [String: Any]? {
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
    
    static func getData(op_code: String, pa_1: String, pa_2: String, pa_3: String, pa_4: String, pa_5: String) -> [String: Any]? {
        connect(["op_code": op_code,
                 "pa_1": pa_1,
                 "pa_2": pa_2,
                 "pa_3": pa_3,
                 "pa_4": pa_4,
                 "pa_5": pa_5,
                 "Token": token
        ])
    }

    
    static func getAllThreads() -> [Post] {
        if let rec = getData(op_code: "d", pa_1: "NULL", pa_2: "0", pa_3: "0", pa_4: "0", pa_5: "0") {
            return (rec["thread_list"]! as! [Any]).map() {
                Post(json: $0)
            }
        } else {
            print("FFFAILED!")
            return []
        }
    }
    
}
