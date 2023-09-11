//
//  FlashlightManager+AppEvents.swift
//  Lantern
//

import Foundation
import UIKit
import UserNotifications
import NetworkExtension
import Internalsdk

class VpnHelper: NSObject {
    static let shared = VpnHelper(constants: Constants(process: .app),
                                fileManager: .default,
                                userDefaults: Constants.appGroupDefaults,
                                notificationCenter: .default,
                                flashlightManager: FlashlightManager.appDefault,
                                vpnManager: ( VPNManager.appDefault))

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

   private var _state: VPNState
    var state: VPNState {
        get {
            if configuring {
                return .configuring
            }
            return _state
        }

        set(newState) {
            guard _state != newState else { return }
            _state = newState
            notificationCenter.post(name: VpnHelper.didUpdateStateNotification, object: nil)
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
    let dataUsageMonitor: DataUsageMonitor
    var configFetchTimer: Timer!
    var hasConfiguredThisSession = false

    var hasFetchedConfigOnce: Bool {
        return (userDefaults.value(forKey: VpnHelper.hasFetchedConfigDefaultsKey) as? Bool) ?? false
    }
    // MARK: Init

    init(constants: Constants,
         fileManager: FileManager,
         userDefaults: UserDefaults,
         notificationCenter: NotificationCenter,
         flashlightManager: FlashlightManager,
         vpnManager: VPNBase,
         userNotificationsManager: UserNotificationsManager? = nil,
         dataUsageMonitor: DataUsageMonitor? = nil) {

        self.constants = constants
        self.fileManager = fileManager
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.flashlightManager = flashlightManager
        self.vpnManager = vpnManager

        // Optionally injected, but otherwise generated dependencies
        self.dataUsageMonitor = dataUsageMonitor ?? DataUsageMonitor(quotaURL: constants.quotaURL)
        
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
    
        // 2. set up files for flashlight
        createFilesForAppGoPackage()

        // 3. set up data usage monitor
        dataUsageMonitor.startObservingDataUsageChanges(callback: handleDataUsageUpdated)

        // 4. set up VPN manager
        vpnManager.didUpdateConnectionStatusCallback = handleVPNStatusUpdated

        logger.debug("Setting Go Log path to:\(constants.goLogBaseURL.path)")
        if let error = flashlightManager.configureGoLoggerReturningError() {
            logger.error("IosConfigureLogger FAILED: " + error.localizedDescription)
        }
        //5 Fetch config
        fetchConfigIfNecessary()
    }
    
    
    private func createFilesForAppGoPackage() {
        // where "~" is the shared app group container...

        // create process-specific directory @ ~/app
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
        var logURLs = fileManager.generateLogRotationURLs(count: Constants.defaultLogRotationFileCount, from: constants.goLogBaseURL)
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
          onError: ((Error) -> ())? = nil,
          onSuccess: (() -> ())? = nil
      ) {
          guard state.isIdle else { return }
        if !hasFetchedConfigOnce {
              initiateConfigFetching(onError: onError, onSuccess: onSuccess)
          } else {
              initiateVPNStart(onError: onError, onSuccess: onSuccess)
          }
      }
    
    
    private func initiateConfigFetching(onError: ((Error) -> ())? = nil, onSuccess: (() -> ())? = nil) {
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
    
    
    private func initiateVPNStart(onError: ((Error) -> ())? = nil, onSuccess: (() -> ())? = nil) {
         vpnManager.startTunnel() { result in
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

    func handleVPNStatusUpdated(_ status: NEVPNStatus) {
        let newState = translateVPNStatusToLanternState(status)
        logger.debug("VPN status updated while \(state): \(newState)")
        guard status != .reasserting && status != .invalid else {
            state = .idle(.invalidVPNState)
            stopVPN()
            return
        } state = newState
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
        logger.debug("Checking if config fetch is needed")
        guard !self.hasConfiguredThisSession else { return }
        logger.debug("Will fetch config")
        self.hasConfiguredThisSession = true
        let hasFetchedConfigOnce = self.hasFetchedConfigOnce
            fetchConfig { [weak self] result in
            self?.setUpConfigFetchTimer()
            DispatchQueue.main.async {
                self?.configuring = false
                if let state = self?.state {
                    guard state.isIdle else { return }
                }
                if !result.isSuccess && !hasFetchedConfigOnce {
                    self?.state = .idle(.unableToFetchConfig)
                }
            }
        }
    }

    func fetchConfig(refreshProxies: Bool = true, _ completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        flashlightManager.fetchConfig(userID: self.userID, proToken: self.proToken, excludedIPsURL: constants.excludedIPsURL, refreshProxies: refreshProxies) { [weak self] result in
            switch result {
            case .success(let vpnNeedsReconfiguring):
                if vpnNeedsReconfiguring {
                    self?.messageNetExToUpdateExcludedIPs()
                }
                self?.userDefaults.set(refreshProxies, forKey: VpnHelper.hasFetchedConfigDefaultsKey)
                logger.debug("Successfully fetched new config")
                completion(.success(()))
            case .failure(let error):
                // TODO: convert this error to a Lantern.Error
                logger.error("Fetch config failed:" + error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    func setUpConfigFetchTimer() {
        // set up timer on Main queue's runloop
        // FlashlightManager will automatically use its designated goQueue when fetching
        DispatchQueue.main.async { [weak self] in
            let time: Double = 60
            self?.configFetchTimer = Timer.scheduledTimer(withTimeInterval: time, repeats: true, block: {  [weak self] _ in
                // Only auto-fetch new config when VPN is on
                guard self?.state == .connected else { return }
                logger.debug("Config Fetch timer fired after \(time), fetching...")
                self?.fetchConfig() { result in
                    switch result {
                    case .success:
                        logger.debug("Auto-config fetch success")
                    case .failure(let error):
                        logger.error("Auto-config fetch failed: \(error.localizedDescription)")
                    }
                }
            })
        }
    }

    private func messageNetExToUpdateExcludedIPs() {
        logger.debug("Notifying network extension of updated config")
        do {
            let msg = Constants.configUpdatedMessageData
            try vpnManager.messageNetEx(messageData: msg) { data in
                let success = (data == Constants.configUpdatedACKData)
                let logMsg = (success ? "Successfully ACKd config update message"
                    : "Did not return expected ACK for config update message.")
                logger.error("NetEx \(logMsg)")
            }
        } catch {
            logger.error("Failed to message Provider from App— \(error.localizedDescription)")
        }
    }
}



extension VpnHelper {
    // MARK: Data Usage

    static let dataUsageUpdatedNotification = Notification.Name("Lantern.dataUsageUpdated")

    func handleDataUsageUpdated() {
        // ONLY inform system that it has changed
        // tunnel is responsible for posting user-facing notification
        notificationCenter.post(name: VpnHelper.dataUsageUpdatedNotification, object: nil)
    }

    var dataCapIsPresent: Bool {
        return dataUsageMonitor.dataCapIsPresent
    }

    var dataCapReached: Bool {
        return !self.isPro && dataUsageMonitor.dataCapReached
    }

    func currentDataUsage() -> DataUsageMonitor.DataUsage? {
        return dataUsageMonitor.dataUsage
    }

    func currentDataUsageAsString() -> String? {
        return dataUsageMonitor.dataUsageStringValue
    }
}
//
//extension Lantern {
//    // MARK: Submit Logs
//
//    enum UserIssue: String, CaseIterable {
//        case slow
//        case crashes
//        case noAccess
//        case other
//
//        var label: String {
//            switch self {
//                case .slow: return Text.Settings.Logs.issueSlow.localized
//                case .crashes: return Text.Settings.Logs.issueCrashes.localized
//                case .noAccess: return Text.Settings.Logs.issueNoAccess.localized
//                case .other: return Text.Settings.Logs.issueOther.localized
//            }
//        }
//
//        fileprivate var mandrilDescription: String {
//            return rawValue
//        }
//    }
//
//    func submitLogs(emailAddress: String, issue: UserIssue, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
//        flashlightManager.submitLogs(isPro: isPro, userID: userID, proToken: proToken, emailAddress: emailAddress, issueString: issue.mandrilDescription) { result in
//            switch result {
//            case .success:
//                logger.debug("submitLogs succeeded: (\(emailAddress)) | app: \(Bundle.main.appVersion)")
//            case .failure(let error):
//                logger.error("submitLogs failed: \(error.localizedDescription)")
//            }
//            completion(result)
//        }
//    }
//}

extension VpnHelper: UNUserNotificationCenterDelegate {

    // MARK: Local Notifications

//    var notificationsEnabled: Bool {
//        return userNotificationsManager.notificationsEnabled
//    }
//
//    func getSystemNotificationAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void) {
//        userNotificationsManager.getSystemNotificationAuthorization(completion: completion)
//    }
//
//    func toggleNotificationsEnabled() {
//        userNotificationsManager.notificationsEnabled = !userNotificationsManager.notificationsEnabled
//    }

    // MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // allows app to present 'provisional' data cap alert while active
        completionHandler(.alert)
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
    // MARK: PrivacyPolicy

    var hasAcceptedPrivacyPolicy: Bool {
        return self.userDefaults.integer(forKey: Constants.acceptedPrivacyPolicyVersion) >= Constants.currentPrivacyPolicyVersion
    }

    func markPrivacyPolicyAccepted() {
        self.userDefaults.set(Constants.currentPrivacyPolicyVersion, forKey: Constants.acceptedPrivacyPolicyVersion)
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

   
    func saveProCredentials(_ proCredentials: IosProCredentials) {
        self.userDefaults.set(proCredentials.userID, forKey: Constants.userID)
        self.userDefaults.set(proCredentials.proToken, forKey: Constants.proToken)
    }

    func setProStatus(v: Bool) {
        self.userDefaults.set(v, forKey: Constants.isPro)
    }

    private func clearProCredentials() {
        self.userDefaults.removeObject(forKey: Constants.proToken)
        self.userDefaults.removeObject(forKey: Constants.userID)
    }

//    func isActiveProDevice(completion: @escaping (Result<Bool, Swift.Error>) -> ()) {
//        flashlightManager.isActiveProDevice(userID: self.userID, proToken: self.proToken) { [weak self] result in
//            switch result {
//            case .success(let ok):
//                logger.debug("isActiveProDevice succeeded: | app: \(Bundle.main.appVersion)")
//                guard let self = self else { return }
//
//                if ok {
//                    logger.debug("This user is an active pro user with userID \(self.userID) and token \(self.proToken ?? "")")
//                    return
//                }
//
//                logger.debug("This user is a NOT an active pro user with userID \(self.userID) and token \(self.proToken ?? "")")
//                if self.state == .connected {
//                    self.stopVPN()
//                }
//                self.clearProCredentials()
//                self.setProStatus(v: false)
//                // force a fresh config fetch next time we get here
//                self.userDefaults.set(false, forKey: Lantern.hasFetchedConfigDefaultsKey)
//                // immediately set up device linking
//                self.requestDeviceLinkingCodeUntilAvailable()
//            case .failure(let error):
//                logger.error("isActiveProDevice failed: \(error.localizedDescription)")
//            }
//            completion(result)
//        }
//    }
//
//    func requestDeviceLinkingCode(completion: @escaping (Result<String, Swift.Error>) -> ()) {
//        logger.debug("requestDeviceLinkingCode called")
//
//        flashlightManager.requestDeviceLinkingCode() { result in
//            switch result {
//            case .success:
//                logger.debug("requestDeviceLinkingCode succeeded: | app: \(Bundle.main.appVersion)")
//            case .failure(let error):
//                logger.error("requestDeviceLinkingCode failed: \(error.localizedDescription)")
//            }
//            completion(result)
//        }
//    }
//
//    func requestDeviceLinkingCodeUntilAvailable(delaySeconds: Double = 5) {
//        if isPro {
//            // already pro, no need to mess with device codes
//            return
//        }
//
//        requestDeviceLinkingCode { result in
//            switch result {
//            case .success(let code):
//                self.supportCode = code
//            case .failure:
//                // backoff
//                var nextDelay = delaySeconds * 2
//                if nextDelay > 300 {
//                    nextDelay = 300
//                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
//                    self.requestDeviceLinkingCodeUntilAvailable(delaySeconds: nextDelay)
//                }
//            }
//        }
//    }
//
//    func validateDeviceLinkingCode(_ code: String, canceler: IosCanceler?, completion: @escaping (Result<IosProCredentials?, Swift.Error>) -> ()) {
//        flashlightManager.validateDeviceLinkingCode(code, canceler: canceler) { [weak self] result in
//            switch result {
//            case .success(let proCredentials):
//                switch proCredentials {
//                case .some:
//                    logger.debug("validateDeviceLinkingCode succeeded: (\(code)) | app: \(Bundle.main.appVersion)")
//                    self?.saveProCredentials(proCredentials!)
//                    self?.supportCode = ""
//                    completion(result)
//                case .none:
//                    logger.debug("validateDeviceLinkingCode canceled: (\(code)) | app: \(Bundle.main.appVersion)")
//                    completion(Result<IosProCredentials?, Swift.Error>.success(.none))
//                }
//            case .failure(let error):
//                logger.error("validateDeviceLinkingCode failed: \(error.localizedDescription)")
//                completion(result)
//            }
//        }
//    }
//
//    func redeemResellerCode(userID: Int, proToken: String, emailAddress: String, resellerCode: String, currency: String, completion: @escaping (Result<Void, Swift.Error>) -> ()) {
//        flashlightManager.redeemResellerCode(userID: userID, proToken: proToken, emailAddress: emailAddress, resellerCode: resellerCode, currency: currency, completion: completion)
//    }
//
//    func userCreate(_ completion: @escaping (Result<IosProCredentials?, Swift.Error>) -> ()) {
//        // If we already have it, just return that instead of making a new one
//        if self.userID != 0 && self.proToken != nil && self.proToken?.isEmpty == false {
//            let a = IosProCredentials.init()
//            a.proToken = self.proToken!
//            a.userID = self.userID
//            completion(.success(a))
//            return
//        }
//        flashlightManager.userCreate(completion: completion)
//    }
}
