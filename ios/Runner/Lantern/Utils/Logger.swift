//
//  Logger.swift
//  Runner
//
//  Created by jigar fumakiya on 20/07/23.
//

import os
import Internalsdk

let logger = LanternLogger()

class LanternLogger {
    private let logger  = OSLog(subsystem: "", category: "")
    private let prefix: String = "[LANTERN-IOS]"

    func log(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let date = dateFormatter.string(from: Date())
        os_log("%{public}@", log: logger, type: .default, "\(prefix) - \(date): \(message)")
    }

    func error(_ msg: String) {
        IosLogError(msg)
    }

    func debug(_ msg: String) {
        IosLogDebug(msg)
    }
}
