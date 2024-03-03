//
//  FlashlightManager+AppEvents.swift
//  Lantern
//

import Foundation
import Internalsdk
import NetworkExtension
import UIKit
import UserNotifications

class VpnHelper: NSObject {
  static let shared = VpnHelper(
    constants: Constants(process: .app),
    fileManager: .default,
    userDefaults: Constants.appGroupDefaults,
    notificationCenter: .default,
    flashlightManager: FlashlightManager.appDefault,
    vpnManager: (isSimulator() ? MockVPNManager() : VPNManager.appDefault))
  // MARK: State
  static let didUpdateStateNotification = Notification.Name("Lantern.didUpdateState")
  enum VPNState: Equatable {
    case configuring
    case idle(Error?)
    case connecting
    case connected
    case disconnecting
    var isIdle: Bool {
      if case .idle = self { return true }
      return false
    }
  }
  var configuring: Bool {
    didSet {
      guard oldValue != configuring else { return }
      notificationCenter.post(name: VpnHelper.didUpdateStateNotification, object: nil)
    }
  }

  private let stateLock = NSLock()
  private var _state: VPNState
  var state: VPNState {
    get {
      stateLock.lock()
      defer { stateLock.unlock() }
      if configuring {
        return .configuring
      }
      return _state
    }

    set(newState) {
      stateLock.lock()
      guard _state != newState else {
        stateLock.unlock()
        return
      }
      _state = newState
      notificationCenter.post(name: VpnHelper.didUpdateStateNotification, object: nil)
      stateLock.unlock()
    }
  }

  static let hasFetchedConfigDefaultsKey = "Lantern.hasConfig"
  // Apple
  let fileManager: FileManager
  let userDefaults: UserDefaults
  let notificationCenter: NotificationCenter
  // Custom
  let constants: Constants
  let flashlightManager: FlashlightManager
  let vpnManager: VPNBase
  var configFetchTimer: Timer!
  var hasConfiguredThisSession = false
  var hasFetchedConfigOnce: Bool {
    return (userDefaults.value(forKey: VpnHelper.hasFetchedConfigDefaultsKey) as? Bool) ?? false
  }

  init(
    constants: Constants,
    fileManager: FileManager,
    userDefaults: UserDefaults,
    notificationCenter: NotificationCenter,
    flashlightManager: FlashlightManager,
    vpnManager: VPNBase,
    userNotificationsManager: UserNotificationsManager? = nil
  ) {
    self.constants = constants
    self.fileManager = fileManager
    self.userDefaults = userDefaults
    self.notificationCenter = notificationCenter
    self.flashlightManager = flashlightManager
    self.vpnManager = vpnManager
    configuring = true
    _state = .idle(nil)
    super.init()
    if self.hasFetchedConfigOnce {
      self.configuring = false
    }
    performAppSetUp()
  }

  // MARK: Set Up
  func performAppSetUp() {
    // STARTUP OVERVIEW

    // 1. set up files for flashlight
    createFilesForAppGoPackage()
    // Todo Use new method we are using in Android
    // 2. set up data usage monitor
    //    dataUsageMonitor.startObservingDataUsageChanges(callback: handleDataUsageUpdated)

    // 3. set up VPN manager
    vpnManager.didUpdateConnectionStatusCallback = handleVPNStatusUpdated

    logger.debug("Setting Go Log path to:\(constants.goLogBaseURL.path)")
    if let error = flashlightManager.configureGoLoggerReturningError() {
      logger.error("IosConfigureLogger FAILED: " + error.localizedDescription)
    }
  }

  private func createFilesForAppGoPackage() {
    // where "~" is the shared app group container...
    // create process-specific directory @ ~/app

    do {
        try fileManager.ensureDirectoryExists(at: Constants.lanternDirectory)
    } catch {
      logger.error("Failed to create directory @ \(Constants.lanternDirectory.path)")
    }

    do {
      try fileManager.ensureDirectoryExists(at: constants.targetDirectoryURL)
    } catch {
      logger.error("Failed to create directory @ \(constants.targetDirectoryURL.path)")
    }
    // create process-shared directory @ ~/config
    do {
      try fileManager.ensureDirectoryExists(at: constants.configDirectoryURL)
    } catch {
      logger.error("Failed to create directory @ \(constants.configDirectoryURL.path)")
    }

    // create shared config files (eg- config.yaml, masquerade_cache, etc) @ ~/config/<_>
    let configSuccess = fileManager.ensureFilesExist(at: constants.allConfigURLs)
    if !configSuccess {
      logger.error("Failed to create config files")
    }
    // create process-specific log files @ ~/app/lantern.log.#
    var logURLs = fileManager.generateLogRotationURLs(
      count: Constants.defaultLogRotationFileCount, from: constants.goLogBaseURL)
    logURLs.append(constants.heapProfileURL)
    logURLs.append(constants.heapProfileTempURL)
    logURLs.append(constants.goroutineProfileURL)
    logURLs.append(constants.goroutineProfileTempURL)
    let success = fileManager.ensureFilesExist(at: logURLs)
    if !success {
      logger.error("Failed to create log URLs")
    }
  }

  func startVPN(
    onError: ((Error) -> Void)? = nil,
    onSuccess: (() -> Void)? = nil
  ) {
    //guard state.isIdle else { return }
    logger.debug("VpnHelper startVPN called")
    guard state.isIdle else { return }
    self.configuring = false
    initiateVPNStart(onError: onError, onSuccess: onSuccess)
  }

  private func initiateVPNStart(onError: ((Error) -> Void)? = nil, onSuccess: (() -> Void)? = nil) {
    vpnManager.startTunnel { result in
      switch result {
      case .success:
        logger.debug("VPN successfully started")
        onSuccess?()
      case .failure(let error):
        logger.error("VPN start failed: \(error.localizedDescription)")
        onError?(.userDisallowedVPNConfig)
      }
    }
  }

  func stopVPN() {
    vpnManager.stopTunnel()
  }

  // Internal method for VPN status
  func handleVPNStatusUpdated(_ status: NEVPNStatus) {
    let newState = translateVPNStatusToLanternState(status)
    logger.debug("VPN status updated while \(state): \(newState)")
    guard status != .reasserting && status != .invalid else {
      state = .idle(.invalidVPNState)
      stopVPN()
      return
    }
    state = newState
  }

  func translateVPNStatusToLanternState(_ status: NEVPNStatus) -> VpnHelper.VPNState {
    switch status {
    case .disconnected, .invalid, .reasserting:
      return .idle(nil)
    case .connecting:
      return .connecting
    case .connected:
      return .connected
    case .disconnecting:
      return .disconnecting
    @unknown default:
      assertionFailure("Unhandled VPN state")
      return .idle(.unknown)
    }
  }

  private func messageNetExToUpdateExcludedIPs() {
    logger.debug("Notifying network extension of updated config")
    do {
      let msg = Constants.configUpdatedMessageData
      try vpnManager.messageNetEx(messageData: msg) { data in
        let success = (data == Constants.configUpdatedACKData)
        let logMsg =
          (success
            ? "Successfully ACKd config update message"
            : "Did not return expected ACK for config update message.")
        logger.error("NetEx \(logMsg)")
      }
    } catch {
      logger.error("Failed to message Provider from App— \(error.localizedDescription)")
    }
  }
}

extension VpnHelper {
  enum Error: Swift.Error {
    case unknown
    case userDisallowedVPNConfig
    case invalidVPNState
  }
}

extension VpnHelper {
  // MARK: Pro
  var userID: Int {
    return self.userDefaults.integer(forKey: Constants.userID)
  }

  var proToken: String? {
    return self.userDefaults.string(forKey: Constants.proToken)
  }

  var isPro: Bool {
    if !self.userDefaults.bool(forKey: Constants.isPro) {
      return false
    }

    if self.userID == 0 {
      return false
    }

    let pt = self.proToken
    if pt == nil || pt?.isEmpty == true {
      return false
    }

    return true
  }
}
