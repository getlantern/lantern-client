//
//  Bundle+AppVersion.swift
//  Lantern
//

import Foundation

extension Bundle {
    var appVersion: String {
        let dictionary = infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(build))"
    }
}
