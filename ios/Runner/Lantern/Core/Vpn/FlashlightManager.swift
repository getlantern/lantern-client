//
//  FlashlightManager.swift
//  Lantern
//

import Foundation
import Internalsdk
import UIKit
import os.log

class FlashlightManager {
  static let `appDefault` = FlashlightManager(constants: .appDefault)
  static let `netExDefault` = FlashlightManager(constants: .netExDefault)

  // Designated queue for backgrounding go-specific calls.
  // Keep it as clear as possible to prevent blocking network activity.
  // .userInitiated: "..for tasks that prevent the user from actively using your app."
  let queue = DispatchQueue(label: "FlashlightManager", qos: .userInitiated)
  let backgroundQueue = DispatchQueue(label: "FlashlightManager-background", qos: .background)
  let constants: Constants

  // MARK: Init

  init(constants: Constants) {
    self.constants = constants
  }

  var hasCheckedForUpdate = false

  // MARK: Go Logging
  func configureGoLoggerReturningError() -> Error? {
    var error: NSError?
    //IosConfigureFileLogging(constants.goLogBaseURL.path, constants.targetDirectoryURL.path, &error)
    return error
  }

  // set the below to a proxies.yaml with whatever proxies you want to test, will override
  static let hardcodedProxies = ""
}
