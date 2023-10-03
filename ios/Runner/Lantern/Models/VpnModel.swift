//  VpnModel.swift
//  Runner
//  Created by jigar fumakiya on 01/09/23.

import DBModule
import Flutter
import Foundation
import Internalsdk

class VpnModel: BaseModel {
  let vpnManager: VPNBase
  let vpnHelper = VpnHelper.shared

  init(flutterBinary: FlutterBinaryMessenger, vpnBase: VPNBase) throws {
    self.vpnManager = vpnBase
    var error: NSError?
    guard let model = InternalsdkNewVpnModel(try BaseModel.getDB(), &error) else {
      throw error!
    }
    try super.init(flutterBinary, model)
  }

  private func saveVPNStatus(status: String) {
    let miniSqlValue = ValueUtil.convertToMinisqlValue(status)
    if miniSqlValue != nil {
      do {
        let result = try invokeMethodOnGo("saveVpnStatus", miniSqlValue!)
        logger.log("Sucessfully set VPN status with  \(status)")
      } catch {
        logger.log("Error while setting VPN status")
      }
    }
  }

  func switchVPN(status: Bool) {
    if status {
      startVPN()
    } else {
      stopVPN()
    }
  }

  func startVPN() {
    self.saveVPNStatus(status: "connected")
    vpnHelper.startVPN(
      onError: { error in
        // in case of error, reset switch position
        self.saveVPNStatus(status: "disconnected")
        logger.debug("VPN not started \(error)")
      },
      onSuccess: {
        logger.debug("VPN started")
        self.saveVPNStatus(status: "connected")
      })
  }

  func stopVPN() {
    vpnHelper.stopVPN()
    logger.debug("VPN Successfully stoped")
    self.saveVPNStatus(status: "disconnected")
  }

}
