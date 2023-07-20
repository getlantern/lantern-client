//
//  Logger.swift
//  Runner
//
//  Created by jigar fumakiya on 19/07/23.
//
import Ios
import os

let logger = Logger()

class Logger {
    // MARK: Logging via Go code (unifies log messages in single file)
    func error(_ msg: String) {
        IosLogError(msg)
    }

    func debug(_ msg: String) {
        IosLogDebug(msg)
    }
}
