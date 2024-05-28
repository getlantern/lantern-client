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
  let emptyCompletion: (MinisqlValue?, Error?) -> Void = { _, _ in }
  private let sessionAsyncHandler = DispatchQueue.global(qos: .background)

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
      let result = try invoke("hasAllNetworkPermssion", completion: emptyCompletion)
      logger.log("Sucessfully given all permssion")
    } catch {
      logger.log("Error while setting hasAllPermssion")
      SentryUtils.caputure(error: error as NSError)
    }
  }
  private func getUserId() {
    sessionAsyncHandler.async {
      do {
        var userID: Int64 = 0
        try self.model.getUserID(&userID)
        DispatchQueue.main.async {
          if userID != 0 {
            Constants.appGroupDefaults.set(userID, forKey: Constants.userID)
            logger.log("Successfully got user id \(userID)")
          } else {
            logger.log("Failed to get user id")
          }
        }
      } catch {
        DispatchQueue.main.async {
          SentryUtils.caputure(error: error as NSError)
        }
      }
    }
  }

  private func getProToken() {
    sessionAsyncHandler.async {
      do {
        var error: NSError?
        let proToken = try self.model.getToken(&error)
        DispatchQueue.main.async {
          if proToken != nil && proToken != "" {
            Constants.appGroupDefaults.set(proToken, forKey: Constants.proToken)
            logger.log("Sucessfully got protoken \(proToken)")
          } else {
            logger.log("Failed to get user id")
          }
        }
      } catch {
        DispatchQueue.main.async {
          SentryUtils.caputure(error: error as NSError)
        }
      }
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
        try invoke(
          "updateStats", arguments: dataDict, completion: emptyCompletion)
        logger.debug("updateStats data received: \(dataDict)")
      }
    } catch {
      logger.debug("Failed to deserialize JSON data: \(error)")
    }
  }

  deinit {
    // Remove observer when the observer is deallocated
    Constants.appGroupDefaults.removeObserver(self, forKeyPath: Constants.statsData)
  }

}
