//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import DBModule
import Flutter
import Foundation
import Internalsdk
import UIKit

class SessionModel: BaseModel<InternalsdkSessionModel> {
  lazy var notificationsManager: UserNotificationsManager = {
    return UserNotificationsManager()
  }()

  init(flutterBinary: FlutterBinaryMessenger) throws {
    logger.log("Initializing SessionModel")
    let opts = InternalsdkSessionModelOpts()
    let device = UIDevice.current
    let deviceId = DeviceIdentifier.getUDID()
    let modelName = UIDevice.modelName
    let systemName = device.systemName
    let systemVersion = device.systemVersion
    opts.deviceID = deviceId
    opts.lang = Locale.current.identifier
    opts.developmentMode = (!isRunningFromAppStore() && !isRunningInTestFlightEnvironment())
    opts.proUser = false
    opts.playVersion = (isRunningFromAppStore() || isRunningInTestFlightEnvironment())
    opts.timeZone = TimeZone.current.identifier
    opts.device = systemName  // IOS does not provide Device name directly
    opts.model = modelName
    opts.osVersion = systemVersion
    opts.paymentTestMode = AppEnvironment.current == AppEnvironment.appiumTest
    opts.platform = "ios"

    logger.debug("IOS Device ID \(deviceId)")
    var error: NSError?
    guard
      let model = InternalsdkNewSessionModel(
        try BaseModel<InternalsdkModelProtocol>.getDB(), opts, &error)
    else {
      throw error!
    }
    try super.init(flutterBinary, model)
//    DispatchQueue.global(qos: .userInitiated).async {
//      self.startService()
//    }
  }

//  func startService() {
//    let configDir = configDirFor(suffix: "service")
//    (model as! InternalsdkSessionModel).startService(configDir, locale: "en", settings: Settings())
//    logger.debug("Service Started successfully")
//  }

  func hasAllPermssion() {
    do {
      let result = try invoke("hasAllNetworkPermssion")
      logger.log("Sucessfully given all permssion")
    } catch {
      logger.log("Error while setting hasAllPermssion")
      SentryUtils.caputure(error: error as NSError)
    }
  }

  func getBandwidth() {
    // TODO: we should do this reactively by subscribing
    do {
      let result = try invoke("getBandwidth")
      let newValue = ValueUtil.convertFromMinisqlValue(from: result!)
      let limit = newValue as! Int
      if limit == 100 {
        // if user has reached limit show the notificaiton
        notificationsManager.scheduleDataCapLocalNotification(withDataLimit: limit)
      }
      logger.log("Sucessfully getbandwidth \(newValue)")
    } catch {
      logger.log("Error while getting bandwidth")
      SentryUtils.caputure(error: error as NSError)
    }
  }

  private func setDNS() {
    // TODO: why are we setting timezone in setDNS()?
    //    let timeZoneId = TimeZone.current.identifier
    //    let miniSqlValue = ValueUtil.convertToMinisqlValue(DnsDetector.DEFAULT_DNS_SERVER)
    //    if miniSqlValue != nil {
    //      do {
    //        let result = try invokeMethodOnGo("setTimeZone", miniSqlValue!)
    //        logger.log("Sucessfully set timezone with id \(timeZoneId) result \(result)")
    //      } catch {
    //        logger.log("Error while setting timezone")
    //      }
    //    }
  }

//  public func configDirFor(suffix: String) -> String {
//    let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//      .first!
//
//    let fileURL = filesDirectory.appendingPathComponent(".lantern" + suffix)
//
//    if !FileManager.default.fileExists(atPath: fileURL.path) {
//      do {
//        try FileManager.default.createDirectory(
//          at: fileURL, withIntermediateDirectories: true, attributes: nil)
//      } catch {
//
//        print(error.localizedDescription)
//        SentryUtils.caputure(error: error as NSError)
//      }
//    }
//    return fileURL.path
//  }
}

class Settings: NSObject, InternalsdkSettingsProtocol {
  func getHttpProxyHost() -> String {
    return "127.0.0.1"
  }

  func getHttpProxyPort() -> Int {
    return 49125
  }

  func stickyConfig() -> Bool {
    return false
  }

  func timeoutMillis() -> Int {
    return 60000
  }

}
