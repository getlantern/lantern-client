//
//  StatsTracker.swift
//  Tunnel
//
//  Created by jigar fumakiya on 23/05/24.
//

import Foundation
import Internalsdk

// StatsTracker serves as an abstraction for tracking statistics relevant to the VPN connection.
// It is responsible for updating statistics data received from the server when the user connects to the VPN.
// The updated statistics data is stored in a shared container accessible across the application,
// facilitating data exchange between different components depending on the VPN status.
class StatsTracker: NSObject, IosStatsTrackerProtocol {
  func updateStats(_ p0: String?, p1: String?, p2: String?, p3: Int, p4: Int, p5: Bool) {
    logger.debug(
      "UpdateStats city \(p0) country \(p1) servercountrycode \(p3) hasSucceedingProxy \(p5)")
    //Save data comming from server
    let dataDict: [String: Any] = [
      "city": p0 ?? "",
      "country": p1 ?? "",
      "serverCountryCode": p2 ?? "",
      "httpsUpgrades": p3,
      "adsBlocked": p4,
      "hasSucceedingProxy": p5,
    ]
    do {
      // Convert the dictionary to JSON data
      let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: [])
      Constants.appGroupDefaults.set(jsonData, forKey: Constants.statsData)
      logger.debug("Stats data has been saved")
    } catch {
      logger.error("Failed to serialize stats data to JSON: \(error)")
    }
  }
}
