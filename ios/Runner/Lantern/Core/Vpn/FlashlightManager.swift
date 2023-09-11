//
//  FlashlightManager.swift
//  Lantern
//

import Foundation
import os.log
import Internalsdk
import UIKit


// Any and all interaction with Go will run through FlashlightManager.
// See FlashlightManager+AppSide.swift for app-specific functionality.
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
        IosConfigureFileLogging(constants.goLogBaseURL.path, constants.targetDirectoryURL.path, &error)
        return error
    }
    

    // MARK: Testing specific proxies

    // set the below to a proxies.yaml with whatever proxies you want to test, will override
    static let hardcodedProxies = ""
        
//    func fetchConfig(userID: Int, proToken: String?, excludedIPsURL: URL? = nil, refreshProxies: Bool, _ completion: ((Result<Bool, Error>) -> Void)? = nil) {
//        var configError: NSError?
//        let configDirectory = constants.configDirectoryURL.path
//        let deviceID = UIDevice.current.identifierForVendor!.uuidString
//
//        let workItem = DispatchWorkItem {
//            logger.debug("Calling IosConfigure")
//            let configResult = IosConfigure(configDirectory, userID, proToken, deviceID, refreshProxies, FlashlightManager.hardcodedProxies, &configError)
//            logger.debug("Called IosConfigure")
//
//            guard configError == nil else {
//                assertionFailure("fetch config failed:" + configError!.localizedDescription)
//                completion?(.failure(configError! as! Error))
//                return
//            }
//
//            guard let result = configResult else {
//                completion?(.failure(Lantern.Error.unknown))
//                return
//            }
//
//            if let url = excludedIPsURL {
//                if result.vpnNeedsReconfiguring {
//                    try! result.ipsToExcludeFromVPN.write(to: url, atomically: false, encoding: .utf8)
//                }
//            }
//
//            completion?(.success(result.vpnNeedsReconfiguring))
//        }
//
//        // TODO: investigate: does this have to happen on goQueue?
//        queue.async(execute: workItem)
//
////        queue.async { [weak self] in
////            if workItem.wait(timeout: .now() + 10) == .timedOut { // 10 seconds
////                Events.configFetchTakingLongTime.raise(())
////            } else if self?.hasCheckedForUpdate == false {
////                // Check if there's an update available
////                try? self?.isUpdateAvailable { (update, error) in
////                    guard error == nil else {
////                        return
////                    }
////                    // Don't check again until app is restarted
////                    self?.hasCheckedForUpdate = true
////                    if update == true {
////                        Events.updateAvailable.raise(())
////                    }
////                }
////            }
////        }
//    }
}
