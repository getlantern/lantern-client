//
//  Constants.swift
//  Runner
//
//  Created by jigar fumakiya on 06/09/23.
//

import Foundation


struct Constants {
    // MARK: Project Constants
    static let appBundleId = "org.getlantern.lantern"
    static let netExBundleId = "org.getlantern.lantern.Tunnel"
    static let appGroupName = "group.getlantern.lantern"
    
    // Key used for passing reason from app->netEx when startTunnel is called
    static let netExStartReasonKey: String = "netEx.StartReason"
    
}
