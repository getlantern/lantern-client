//
//  FlashlightManager+FetchConfig.swift
//  Lantern
//

import Foundation
import Internalsdk
import UIKit

extension FlashlightManager {
  // MARK: Config
  func fetchConfig(
    userID: Int, proToken: String?, excludedIPsURL: URL? = nil, refreshProxies: Bool,
    _ completion: ((Result<Bool, Error>) -> Void)? = nil
  ) {
    var configError: NSError?
    let configDirectory = constants.configDirectoryURL.path
    let deviceID = DeviceIdentifier.getUDID()

    let workItem = DispatchWorkItem {
      logger.debug("Calling IosConfigure")
      let configResult = IosConfigure(
        configDirectory, userID, proToken, deviceID, refreshProxies,
        FlashlightManager.hardcodedProxies, &configError)
      logger.debug("Called IosConfigure")

      guard configError == nil else {
        assertionFailure("fetch config failed:" + configError!.localizedDescription)
        completion?(.failure(configError!))
        return
      }

      guard let result = configResult else {
        completion?(.failure(VpnHelper.Error.unknown))
        return
      }

      if let url = excludedIPsURL {
        if result.vpnNeedsReconfiguring {
          try! result.ipsToExcludeFromVPN.write(to: url, atomically: false, encoding: .utf8)
        }
      }

      completion?(.success(result.vpnNeedsReconfiguring))
    }

    // TODO: investigate: does this have to happen on goQueue?
    queue.async(execute: workItem)
  }
}
