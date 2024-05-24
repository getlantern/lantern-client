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
    //var model:InternalsdkSessionModel?
    guard
      let model = InternalsdkNewSessionModel(
        try BaseModel<InternalsdkModelProtocol>.getDB(), opts, &error)
    else {
      throw error!
    }
    try super.init(flutterBinary, model)
    Constants.appGroupDefaults.addObserver(
      self, forKeyPath: Constants.statsData, options: [.new], context: nil)

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

  func handleStatsChanges() {
    // Retrieve the JSON data from UserDefaults
    logger.debug("Stats status update")

    //    Constants.appGroupDefaults.addObserver(
    //      self, forKeyPath: Constants.statsData, options: [.new], context: nil)

    //    if let jsonData = Constants.appGroupDefaults.data(forKey: Constants.statsData) {
    //      do {
    //        // Convert the JSON data back to a dictionary
    //        if let dataDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
    //          as? [String: Any]
    //        {
    //          // Handle the new data
    //            Constants.appGroupDefaults.addObserver(<#T##observer: NSObject##NSObject#>, forKeyPath: <#T##String#>, context: <#T##UnsafeMutableRawPointer?#>)
    //          try invoke("updateStats", dataDict)
    //          logger.debug("New data received: \(dataDict)")
    //        }
    //      } catch {
    //        logger.debug("Failed to deserialize JSON data: \(error)")
    //      }
    //    }
  }

  override func observeValue(
    forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
    context: UnsafeMutableRawPointer?
  ) {
    logger.debug("observeValue call with key \(keyPath)")
    if keyPath == Constants.statsData {
      logger.debug("Message comming from tunnel")
      if let newValue = change?[.newKey] as? Data {
        logger.debug("Received message from VPN extension: \(newValue)")
        do {
          if let dataDict = try JSONSerialization.jsonObject(with: newValue, options: [])as? [String: Any]
          {
            try invoke("updateStats", dataDict)
            logger.debug("New data received: \(dataDict)")
          }
        } catch {
          logger.debug("Failed to deserialize JSON data: \(error)")
        }

      }
    }
  }

  //    func updateStats(){
  //        do {
  //          // Convert the JSON data back to a dictionary
  //          if let dataDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
  //            as? [String: Any]
  //          {
  //            try invoke("updateStats", dataDict)
  //            logger.debug("New data received: \(dataDict)")
  //          }
  //        } catch {
  //          logger.debug("Failed to deserialize JSON data: \(error)")
  //        }
  //    }

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
