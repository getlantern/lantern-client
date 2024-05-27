//  VpnModel.swift
//  Runner
//  Created by jigar fumakiya on 01/09/23.

import DBModule
import Flutter
import Foundation
import Internalsdk
import Sentry

class VpnModel: BaseModel<InternalsdkVPNModel>, InternalsdkVPNManagerProtocol {
  let vpnManager: VPNBase
  let vpnHelper = VpnHelper.shared
  var sessionModel: SessionModel!

  init(flutterBinary: FlutterBinaryMessenger, vpnBase: VPNBase, sessionModel: SessionModel) throws {
    logger.log("Initializing VPNModel")
    self.vpnManager = vpnBase
    var error: NSError?
    guard
      let model = InternalsdkNewVPNModel(try BaseModel<InternalsdkModelProtocol>.getDB(), &error)
    else {
      throw error!
    }
    self.sessionModel = sessionModel
    try super.init(flutterBinary, model)
    model.setManager(self)

  }

  private func saveVPNStatus(status: String) {
    do {
      try model.saveVPNStatus(status)
      logger.log("Sucessfully set VPN status with  \(status)")
    } catch {
      SentryUtils.caputure(error: error as NSError)
      logger.log("Error while setting VPN status \(error.localizedDescription)")
    }
  }

  func startVPN() {
    self.saveVPNStatus(status: "connected")
    vpnHelper.startVPN(
      onError: { error in
        // in case of error, reset switch position
        self.saveVPNStatus(status: "disconnected")
      },
      onSuccess: {
        logger.debug("VPN started")
        self.sessionModel.hasAllPermssion()
        self.saveVPNStatus(status: "connected")
      })
  }

  func stopVPN() {
    vpnHelper.stopVPN()
    logger.debug("VPN Successfully stoped")
    self.saveVPNStatus(status: "disconnected")
  }

}
