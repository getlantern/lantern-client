//
//  Process.swift
//  Lantern
//

import Foundation
import os.log

var currentProcess: Process = {
    // lazy instead of computed cause this gets called _a lot_
    switch Bundle.main.bundleIdentifier! {
    case Constants.appBundleId: return .app
    case Constants.netExBundleId: return .netEx
    default:
        // TODO: see if you can use this to your advantage in the Test target
        fatalError() // this shouldn't even be possible
    }
}()

enum Process {
    case app
    case netEx
}
