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
  //  static var shared: SessionModel?

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
    guard
      let model = InternalsdkNewSessionModel(
        try BaseModel<InternalsdkModelProtocol>.getDB(), opts, &error)
    else {
      throw error!
    }
    try super.init(flutterBinary, model)
    observeStatsUpdates()
    getUserId()
    getProToken()
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

  private func getUserId() {
    do {
      var userID: Int64 = 0
      let error = try model.getUserID(&userID)
      if userID != nil {
        Constants.appGroupDefaults.set(userID, forKey: Constants.userID)
        logger.log("Sucessfully got user id \(userID)")
      } else {
        logger.log("failed to get userid")
      }
    } catch {
      SentryUtils.caputure(error: error as NSError)
    }
  }

  private func getProToken() {
    do {
      var error: NSError?
      let proToken = model.getToken(&error)
      if proToken != nil {
        logger.log("Sucessfully got protoken \(proToken)")
        Constants.appGroupDefaults.set(proToken, forKey: Constants.proToken)
      } else if let error = error {
        logger.log("failed to get protoken")
      }
    } catch {
      SentryUtils.caputure(error: error as NSError)
    }
  }

  func observeStatsUpdates() {
    logger.debug("observesing stats udpates")
    Constants.appGroupDefaults.addObserver(
      self, forKeyPath: Constants.statsData, options: [.new], context: nil)
  }

  // System method that observe value user default path
  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    logger.debug("observeValue call with key \(keyPath)")
    if keyPath == Constants.statsData {
      logger.debug("Message comming from tunnel")
      if let statsData = change![.newKey] as? Data {
        updateStats(stats: statsData)
      }
    }
  }

  func updateStats(stats: Data) {
    do {
      // Convert the JSON data back to a dictionary
      if let dataDict = try JSONSerialization.jsonObject(with: stats, options: [])
        as? [String: Any]
      {
        try invoke("updateStats", dataDict)
        logger.debug("New data received: \(dataDict)")
      }
    } catch {
      logger.debug("Failed to deserialize JSON data: \(error)")
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

  deinit {
    // Remove observer when the observer is deallocated
    Constants.appGroupDefaults.removeObserver(self, forKeyPath: Constants.statsData)
  }

}
