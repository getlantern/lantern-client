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
    logger.log("Initializing SessionModel")
    let opts = InternalsdkSessionModelOpts()
    let device = UIDevice.current
    let deviceId = DeviceIdentifier.getUDID()
    let modelName = UIDevice.modelName
    let systemVersion = device.systemVersion
    let systemName = device.systemName
    opts.deviceID = deviceId
    opts.lang = Locale.current.identifier
    opts.developmentMode = false
    opts.playVersion = true
    opts.configPath = Constants(process: .app).configDirectoryURL.path
    opts.timeZone = TimeZone.current.identifier
    opts.device = modelName
    opts.model = modelName
    opts.osVersion = systemVersion
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
    observeBandwidthUpdates()
    observeConfigUpdates()
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
            logger.log("Failed to get protoken")
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
    logger.debug("observing stats udpates")
    Constants.appGroupDefaults.addObserver(
      self, forKeyPath: Constants.statsData, options: [.new], context: nil)
  }

  func observeBandwidthUpdates() {
    logger.debug("observing bandwidth udpates")
    Constants.appGroupDefaults.addObserver(
      self, forKeyPath: Constants.bandwidthData, options: [.new], context: nil)
  }

  func observeConfigUpdates() {
    logger.debug("observing config udpates")
    Constants.appGroupDefaults.addObserver(
        self, forKeyPath: Constants.configupdate, options: [.new], context: nil)
  }

  // System method that observe value user default path
  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    logger.debug("observeValue call with key \(keyPath)")
    switch keyPath {
    case Constants.statsData:
      if let statsData = change![.newKey] as? Data {
        logger.debug("Stats message coming from tunnel")
        updateStats(stats: statsData)
      }
    case Constants.bandwidthData:
      if let bandwidthData = change![.newKey] as? Data {
        logger.debug("Bandwidth message coming from tunnel")
        updateBandwidth(bandwidth: bandwidthData)
      }
   case Constants.configupdate:
        checkForAvaliabelFeature()
    default:
      logger.debug("Unknown message \(keyPath)")
    }
  }

  func checkForAvaliabelFeature() {
    do {
      try invoke("checkAvailableFeatures", completion: emptyCompletion)
      logger.debug("checking for features:")
    } catch {
      logger.debug("error while checking features: \(error)")
    }

  }

  func updateBandwidth(bandwidth: Data) {
    do {
      // Convert the JSON data back to a dictionary
      if let dataDict = try JSONSerialization.jsonObject(with: bandwidth, options: [])
        as? [String: Any]
      {
        try invoke(
          "updateBandwidth", arguments: dataDict, completion: emptyCompletion)
        logger.debug("updateBandwidth data received: \(dataDict)")
      }
    } catch {
      logger.debug("Failed to deserialize JSON data: \(error)")
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
    Constants.appGroupDefaults.removeObserver(self, forKeyPath: Constants.bandwidthData)
  }

}
