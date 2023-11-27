//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 27/11/23.
//


import DBModule
import FlutterMacOS
import Foundation
import Internalsdk
import UserNotifications


class SessionModel: BaseModel<InternalsdkSessionModel> {
//    lazy var notificationsManager: UserNotificationsManager = {
//            return UserNotificationsManager()
//        }()

  init(flutterBinary: FlutterBinaryMessenger) throws {
    let opts = InternalsdkSessionModelOpts()
    let device = "Test Device"
      let deviceId = "Test Device ID"
    let model = "Test Device Model"
    let systemName = "Test Device Name"
    let systemVersion = "Test Device Version"
    opts.deviceID = deviceId
    opts.lang = Locale.current.identifier
    opts.developmentMode = false
    opts.proUser = false
    opts.playVersion = (isRunningFromAppStore() || isRunningInTestFlightEnvironment())
    opts.timeZone = TimeZone.current.identifier
    opts.device = systemName  // IOS does not provide Device name directly
    opts.model = systemName
    opts.osVersion = systemVersion
    opts.paymentTestMode = AppEnvironment.current == AppEnvironment.appiumTest

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
    //    getBandwidth()
  }

  func startService() {
    let configDir = configDirFor(suffix: "service")
    (model as! InternalsdkSessionModel).startService(configDir, locale: "en", settings: Settings())
    logger.error("Service Started successfully")
  }

  func getBandwidth() {
    // TODO: we should do this reactively by subscribing
    do {
      let result = try invoke("getBandwidth")
      let newValue = ValueUtil.convertFromMinisqlValue(from: result!)
      let limit = newValue as! Int
      if limit == 100 {
        // if user has reached limit show the notificaiton
//        notificationsManager.scheduleDataCapLocalNotification(withDataLimit: limit)
      }
      logger.log("Sucessfully getbandwidth \(newValue)")
    } catch {
      logger.log("Error while getting bandwidth")
//      SentryUtils.caputure(error: error as NSError)
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

  public func configDirFor(suffix: String) -> String {
    let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      .first!
    let fileURL = filesDirectory.appendingPathComponent(".lantern" + suffix)

    if !FileManager.default.fileExists(atPath: fileURL.path) {
      do {
        try FileManager.default.createDirectory(
          at: fileURL, withIntermediateDirectories: true, attributes: nil)
      } catch {

        print(error.localizedDescription)
//        SentryUtils.caputure(error: error as NSError)
      }
    }
    return fileURL.path
  }
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
