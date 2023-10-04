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

class SessionModel: BaseModel {
  lazy var notificationsManager: UserNotificationsManager = {
    return UserNotificationsManager()
  }()

  init(flutterBinary: FlutterBinaryMessenger) throws {
    var error: NSError?
    guard let model = InternalsdkNewSessionModel(try BaseModel.getDB(), &error) else {
      throw error!
    }
    try super.init(flutterBinary, model)
    initializeAppSettings()
  }

  func initializeAppSettings() {
    initializeSessionModel()
    setTimeZone()
    setDNS()
    getBandwidth()
  }

  func startService() {
    let configDir = configDirFor(suffix: "service")
    (model as! InternalsdkSessionModel).startService(configDir, locale: "en", settings: Settings())
    logger.error("Service Started successfully")
  }

  private func initializeSessionModel() {
    // Setup the initly data
    let initData = createInitData()

    guard let jsonString = JsonUtil.convertToJSONString(initData) else {
      logger.log("Failed to convert initializationData to JSON")
      return
    }
    do {
      let result = try invoke("initSessionModel", jsonString)
      logger.log("Sucessfully set initData \(jsonString) result")
      // Start servce once we add all data
      startService()
    } catch {
      logger.log("Error while setting initData: \(error)")
    }
  }

  // Set initly data that needed by flashlight
  // later on values change be chaneg by mehtod or by flashlight
  private func createInitData() -> [String: [String: Any]] {
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    let langStr = Locale.current.identifier
    return [
      Constants.developmentMode: ["type": ValueUtil.TYPE_BOOL, "value": true],
      Constants.prouser: ["type": ValueUtil.TYPE_BOOL, "value": false],
      Constants.deviceid: ["type": ValueUtil.TYPE_STRING, "value": deviceId],
      Constants.playVersion: ["type": ValueUtil.TYPE_BOOL, "value": isRunningFromAppStore()],
      Constants.lang: ["type": ValueUtil.TYPE_STRING, "value": langStr],
    ]
  }

  private func setTimeZone() {
    let timeZoneId = TimeZone.current.identifier
    do {
      let result = try invoke("setTimeZone", timeZoneId)
      logger.log("Sucessfully set timezone with id \(timeZoneId) result \(result)")
    } catch {
      logger.log("Error while setting timezone")
    }
  }

  func setDeviceId() {
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    do {
      let result = try invoke("setDeviceId", deviceId)
      logger.log("Sucessfully set device ID \(deviceId) ")
    } catch {
      logger.log("Error while setting deevice ID")
    }
  }

  func getBandwidth() {
    do {
      let result = try invoke("getBandwidth")
      let newValue = ValueUtil.convertFromMinisqlValue(from: result!)
      // If value is not null mean user has alerady start using bandwith
      // We will get that value from Go
      if (newValue as! String) != "" {
        let limit = newValue as! Int
        if limit == 100 {
          // if user has reached limit show the notificaiton
          notificationsManager.scheduleDataCapLocalNotification(withDataLimit: limit)
        }
      }
      logger.log("Sucessfully getbandwidth  \(newValue)")
    } catch {
      logger.log("Error while getting bandwidth")
    }
  }

  func storeVersion() {
    do {
      let result = try invoke("setStoreVersion", isRunningFromAppStore())
      logger.log("This is app store version \(result)")
    } catch {
      logger.log("Error while setting storeVersion")
    }
  }

  func setForceCountry(countryCode: String) {
    do {
      try invoke("setForceCountry", countryCode)
      logger.log("Sucessfully set force country")
    } catch {
      logger.log("Error while setting  up forceCountry")
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
