//
//  VPNManager.swift
//  Lantern
//

import Internalsdk
import Network
import NetworkExtension

enum VPNManagerError: Swift.Error {
  case userDisallowedVPNConfigurations
  case loadingProviderFailed
  case savingProviderFailed
  case unknown
}

class VPNManager: VPNBase {

  static let appDefault = VPNManager(userDefaults: .standard)

  // This is used to determine if we have successfully set up a VPN configuration
  // If user deletes VPN config in device Settings, status becomes "Invalid" and we clear this flag.
  private static let expectsSavedProviderDefaultsKey = "VPNManager.savedProvider"

  private let queue: DispatchQueue = .global(qos: .userInitiated)
  private var providerManager: NETunnelProviderManager?

  var connectionStatus: NEVPNStatus = .disconnected {
    didSet {
      guard oldValue != connectionStatus else { return }
      didUpdateConnectionStatusCallback?(connectionStatus)
    }
  }
  var didUpdateConnectionStatusCallback: ((NEVPNStatus) -> Void)?

  private let userDefaults: UserDefaults
  private var expectsSavedProvider: Bool {
    get { return userDefaults.bool(forKey: VPNManager.expectsSavedProviderDefaultsKey) }
    set { userDefaults.set(newValue, forKey: VPNManager.expectsSavedProviderDefaultsKey) }
  }

  // MARK: Init
  private init(userDefaults: UserDefaults) {
    self.userDefaults = userDefaults
    subscribeToVPNStatusNotifications()
    if expectsSavedProvider {
      // setUpProvider() will prompt VPN Configuration permission if not granted,
      // so only allow this when user has already set up, and we want VPN Status ASAP.
      setUpProvider(completion: { _ in })
    }
  }

  // MARK: NETunnelProviderManager Set Up
  private func setUpProvider(completion: @escaping (Result<Void, VPNManagerError>) -> Void) {
    queue.async {
      VPNManager.loadSavedProvider { [weak self] result in
        switch result {
        case .success(let savedProvider):
          guard let saved = savedProvider else {
            self?.createAndSaveNewProvider(completion)
            return
          }
          self?.providerManager = saved
          self?.expectsSavedProvider = true
          completion(.success(()))
        case .failure(let error):
          self?.expectsSavedProvider = false
          completion(.failure(error))
        }
      }
    }
  }

  private func createAndSaveNewProvider(
    _ completion: @escaping (Result<Void, VPNManagerError>) -> Void
  ) {
    let newManager = VPNManager.newProvider()
    VPNManager.saveThenLoadProvider(newManager) { [weak self] result in
      if result.isSuccess {
        self?.providerManager = newManager
        self?.expectsSavedProvider = true
      }
      completion(result)
    }
  }

  // MARK: Start VPN / Tunnel
  func startTunnel(completion: @escaping (Result<Void, VPNManagerError>) -> Void) {
    guard let provider = self.providerManager else {
      setUpProvider { [weak self] result in
        switch result {
        case .success:  // re-call
          self?.startTunnel(completion: completion)
        case .failure(let error):  // complete
          completion(.failure(error as! VPNManagerError))
        }
      }
      return
    }

    do {
      provider.isEnabled = true  // calling start when !isEnabled will crash
      let options = [Constants.netExStartReasonKey: NSString("User Initiated")]
      try provider.connection.startVPNTunnel(options: options)

      // set onDemand enabled AFTER starting to avoid potential race-condition
      provider.isOnDemandEnabled = true

      VPNManager.saveThenLoadProvider(provider, { _ in })  // necessary to persist isOnDemandEnabled
      completion(.success(()))
    } catch {
      // re-mark needs set up
      self.providerManager = nil
      self.expectsSavedProvider = false
      completion(.failure(.userDisallowedVPNConfigurations))
    }
  }

  // MARK: Stop VPN / Tunnel
  func stopTunnel() {
    guard let provider = self.providerManager else {
      // this should never happen but _just in case_
      self.expectsSavedProvider = false
      return
    }
    provider.isOnDemandEnabled = false
    VPNManager.saveThenLoadProvider(provider) { _ in
      provider.connection.stopVPNTunnel()  // no need to pass reason, system passes UserInitiated on its own
    }
  }

  // MARK: VPN Status Update
  private func subscribeToVPNStatusNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(VPNManager.handleVPNStatusDidChangeNotification(_:)),
      name: NSNotification.Name.NEVPNStatusDidChange,
      object: nil
    )
  }

  @objc private func handleVPNStatusDidChangeNotification(_ notification: Notification) {
    // We can assume this session is the same as ours because:
    // 1. Apps only have access to providers/VPNStatus that they have installed
    // 2. This app specifically only installs/uses _one_ provider
    guard let session = notification.object as? NETunnelProviderSession else {
      assertionFailure("VPNStatus notification fired but unable to grab session")
      return
    }

    connectionStatus = session.status  // potentially triggers update callback

    if session.status == .invalid {
      // this indicates the user has deleted the VPN config in device Settings
      // reset flag and nil provider so we can perform a clean config install
      expectsSavedProvider = false
      providerManager = nil
    }
  }

  // MARK: Messaging Net Ex

  func messageNetEx(messageData: Data, responseHandler: ((Data?) -> Void)?) throws {
    guard let session = self.providerManager?.connection as? NETunnelProviderSession,
      session.status == .connected
    else {
      return
    }
    try session.sendProviderMessage(messageData, responseHandler: responseHandler)
  }

  // MARK: Provider Management

  static private func loadSavedProvider(
    _ completion: @escaping (Result<NETunnelProviderManager?, VPNManagerError>) -> Void
  ) {
    // loadAllFromPreferences triggers VPNConfiguration permission prompt if not yet granted
    NETunnelProviderManager.loadAllFromPreferences { (savedManagers, error) in
      if error == nil {
        completion(.success(savedManagers?.first))  // may be nil, but thats ok
      } else {
        completion(.failure(.loadingProviderFailed))
      }
    }
  }

  // This function exists because of this thread: https://forums.developer.apple.com/thread/25928
  static private func saveThenLoadProvider(
    _ provider: NETunnelProviderManager,
    _ completion: @escaping (Result<Void, VPNManagerError>) -> Void
  ) {
    provider.saveToPreferences { saveError in
      if let _ = saveError {
        completion(.failure(.savingProviderFailed))
      } else {
        provider.loadFromPreferences { loadError in
          if let _ = loadError {
            completion(.failure(.loadingProviderFailed))
          } else {
            completion(.success(()))
          }
        }
      }
    }
  }

  static private func newProvider() -> NETunnelProviderManager {
    let provider = NETunnelProviderManager()
    let config = NETunnelProviderProtocol()
    config.providerBundleIdentifier = Constants.netExBundleId
    config.serverAddress = "0.0.0.0"  // needs to be set but purely 8.8.8.8

    //    var conf = [String: AnyObject]()
    //
    //    let httpPort = IosHTTPProxyPort()
    //
    //    logger.log("HTTP proxy port is \(httpPort)")
    //
    //    conf["proxyHost"] = "127.0.0.1" as AnyObject
    //    conf["proxyPort"] = String(httpPort) as AnyObject

    //    config.providerConfiguration = conf

    provider.protocolConfiguration = config
    provider.isEnabled = true  // calling start when disabled crashes
    // Set rules for onDemand...
    let alwaysConnectRule = NEOnDemandRuleConnect()
    provider.onDemandRules = [alwaysConnectRule]
    // BUT set to false for now— set to true RIGHT BEFORE calling start
    // otherwise it will continually try to turn itself on BEFORE the user even hits the switch
    provider.isOnDemandEnabled = false

    return provider
  }

  // For debug use only— allows you to wipe all created providerManagers
  static private func clearOldProviderManagers(_ completion: @escaping () -> Void) {
    NETunnelProviderManager.loadAllFromPreferences { (savedManagers, _: Swift.Error?) in
      guard let saved = savedManagers, !saved.isEmpty else {
        completion()
        return
      }
      let group = DispatchGroup()
      saved.forEach({ old in
        group.enter()
        old.removeFromPreferences(completionHandler: { _ in group.leave() })
      })
      group.notify(queue: .main, execute: completion)
    }
  }
}
