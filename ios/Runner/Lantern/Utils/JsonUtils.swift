//
//  JsonUtils.swift
//  Runner
//
//  Created by jigar fumakiya on 29/08/23.
//

import Foundation

class JsonUtil {
    static func convertToJSONString(_ initData: [String: [String: Any]]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: initData)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error converting initData to JSON: \(error)")
            return nil
        }
    }
}
