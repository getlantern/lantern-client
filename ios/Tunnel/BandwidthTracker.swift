//
//  BandwidthTracker.swift
//  Tunnel
//
//  Created by atavism on 24/09/10.
//

import Foundation
import Internalsdk

// BandwidthTracker serves as an abstraction for updating bandwidth/data usage statistics 
// relevant to the VPN connection.
class BandwidthTracker: NSObject, IosBandwidthTrackerProtocol {
  func bandwidthUpdate(_ p0: String?, p1: Int, p2: Int, p3: Int, p4: Int) {
    logger.debug(
      "UpdateBandwidth percent \(p1) remaining \(p2) allowed \(p3)")
    //Save data coming from server
    let dataDict: [String: Any] = [
      "percent": p1,
      "remaining": p2,
      "allowed": p3,
      "ttlSeconds": p4,
    ]
    do {
      // Convert the dictionary to JSON data
      let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: [])
      Constants.appGroupDefaults.set(jsonData, forKey: Constants.bandwidthData)
      logger.debug("Bandwidth data has been saved")
    } catch {
      logger.error("Failed to serialize bandwidth data to JSON: \(error)")
    }
  }
}
