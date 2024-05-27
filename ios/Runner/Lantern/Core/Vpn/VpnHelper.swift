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

  // Apple
  let fileManager: FileManager
  let userDefaults: UserDefaults
  let notificationCenter: NotificationCenter
  // Custom
  let constants: Constants
  let flashlightManager: FlashlightManager
  let vpnManager: VPNBase
  //  var configFetchTimer: Timer!
  var hasConfiguredThisSession = false
  var configFetchInProcess: Bool = false

  private var configFetchTimer: DispatchSourceTimer?
  private let fetchQueue = DispatchQueue(label: "org.getlantern.configfetch", qos: .background)

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
    if self.hasConfiguredThisSession {
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
    // 5 Fetch config
    fetchConfigIfNecessary()
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
    guard state.isIdle else { return }
    if !hasConfiguredThisSession {
      initiateConfigFetching(onError: onError, onSuccess: onSuccess)
    } else {
      initiateVPNStart(onError: onError, onSuccess: onSuccess)
    }
  }

  private func initiateConfigFetching(
    onError: ((Error) -> Void)? = nil, onSuccess: (() -> Void)? = nil
  ) {
    configuring = true
    fetchConfig { [weak self] result in
      DispatchQueue.main.async {
        self?.configuring = false
        guard let state = self?.state, state.isIdle else { return }
        if result.isSuccess {
          self?.startVPN(onError: onError, onSuccess: onSuccess)
        } else {
          self?.state = .idle(.unableToFetchConfig)
          onError?(.unableToFetchConfig)
        }
      }
    }
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

  func fetchConfigIfNecessary() {
    guard configFetchInProcess == false else {
      logger.debug("Config fetch is already in progress.")
      return
    }
    logger.debug("Checking if config fetch is needed for state: \(state)")
    if !self.hasConfiguredThisSession {
      logger.debug("Config fetch is needed for first time")
      self.fetchAndSetUpTimer()
      return
    }

    guard state == .connected else {
      logger.debug("Config fetch not needed: state is not connected.")
      return
    }

    logger.debug("State is connected, will fetch config")
    self.fetchAndSetUpTimer()
  }

  private func fetchAndSetUpTimer() {
    configFetchInProcess = true
    logger.debug("Starting config fetch...")
    fetchConfig { [weak self] result in
      DispatchQueue.main.async {
        guard let strongSelf = self else { return }
        switch result {
        case .success:
          logger.debug("Config fetch succeeded.")
          strongSelf.configuring = false
          strongSelf.hasConfiguredThisSession = true
          strongSelf.configFetchInProcess = false
        case .failure(let error):
          logger.error("Config fetch failed: \(error.localizedDescription)")
          if !strongSelf.hasConfiguredThisSession {
            strongSelf.state = .configuring
            // if the config not fetched we need to try again
            strongSelf.fetchAndSetUpTimer()
            return
          }
        }
        //  Start the timer to fetch config periodically if connected
        strongSelf.setUpConfigFetchTimer()
      }
    }
  }

  // this use DispatchSource more efficient method
  func setUpConfigFetchTimer() {
    // Cancel any existing timer
    configFetchTimer?.cancel()
    configFetchTimer = nil

    // Create a new DispatchSourceTimer
    configFetchTimer = DispatchSource.makeTimerSource(queue: fetchQueue)

    let time: Double = 60
    configFetchTimer?.schedule(deadline: .now() + time, repeating: time)

    configFetchTimer?.setEventHandler { [weak self] in
      // Only auto-fetch new config when VPN is on
      guard self?.state == .connected else {
        logger.debug("Skipping config fetch because state is not connected.")
        return
      }
      logger.debug("Config Fetch timer fired after \(time) seconds, fetching...")
      self?.fetchConfig { result in
        switch result {
        case .success:
          logger.debug("Auto-config fetch success")
        case .failure(let error):
          logger.error("Auto-config fetch failed: \(error.localizedDescription)")
        }
      }
    }

    // Start the timer
    configFetchTimer?.resume()
  }

  //  private func startConfigFetchTimer() {
  //    DispatchQueue.main.async { [weak self] in
  //      guard let strongSelf = self else { return }
  //      let time: TimeInterval = 60
  //      strongSelf.configFetchTimer?.invalidate()  // Invalidate any existing timer
  //      logger.debug("Setting up config fetch timer with interval: \(time) seconds")
  //      strongSelf.configFetchTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: true) {
  //        [weak self] _ in
  //        guard let strongSelf = self else { return }
  //        guard strongSelf.state == .connected else {
  //          logger.debug("Skipping config fetch because state is not connected.")
  //          return
  //        }
  //        logger.debug("Config fetch timer fired, fetching config...")
  //        strongSelf.fetchConfig { result in
  //          switch result {
  //          case .success:
  //            logger.debug("Auto-config fetch succeeded.")
  //          case .failure(let error):
  //            logger.error("Auto-config fetch failed: \(error.localizedDescription)")
  //          }
  //        }
  //      }
  //    }
  //  }

  func fetchConfig(
    refreshProxies: Bool = true, _ completion: @escaping (Result<Void, Swift.Error>) -> Void
  ) {
    flashlightManager.fetchConfig(
      userID: self.userID, proToken: self.proToken, excludedIPsURL: constants.excludedIPsURL,
      refreshProxies: refreshProxies
    ) { [weak self] result in
      switch result {
      case .success(let vpnNeedsReconfiguring):
        if vpnNeedsReconfiguring {
          self?.messageNetExToUpdateExcludedIPs()
        }
        logger.debug("Successfully fetched new config with \(result)")
        completion(.success(()))
      case .failure(let error):
        // TODO: convert this error to a Lantern.Error
        logger.error("Fetch config failed:" + error.localizedDescription)
        completion(.failure(error))
      }
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
    case unableToFetchConfig
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
