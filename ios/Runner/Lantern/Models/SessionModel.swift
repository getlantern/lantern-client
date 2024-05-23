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
    let opts = InternalsdkSessionModelOpts()
    let device = UIDevice.current
    let deviceId = device.identifierForVendor!.uuidString
    let deviceModel = device.model
    let systemName = device.systemName
    let systemVersion = device.systemVersion
    opts.deviceID = deviceId
    opts.lang = Locale.current.identifier
    opts.developmentMode = false
    opts.proUser = false
    opts.playVersion = (isRunningFromAppStore() || isRunningInTestFlightEnvironment())
    opts.timeZone = TimeZone.current.identifier
    opts.device = systemName  // IOS does not provide Device name directly
    opts.model = deviceModel
    opts.osVersion = systemVersion
    opts.paymentTestMode = AppEnvironment.current == AppEnvironment.appiumTest
    opts.platform = "ios"
    var error: NSError?
    //var model:InternalsdkSessionModel?
    guard
      let model = InternalsdkNewSessionModel(
        try BaseModel<InternalsdkModelProtocol>.getDB(), opts, &error)
    else {
      throw error!
    }
    try super.init(flutterBinary, model)
  }

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
