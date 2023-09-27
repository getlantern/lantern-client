//  VpnModel.swift
//  Runner
//  Created by jigar fumakiya on 01/09/23.

import Foundation
import Internalsdk
import Flutter
import DBModule

class VpnModel : BaseModel<InternalsdkVpnModel> {
    var flutterbinaryMessenger:FlutterBinaryMessenger
    let vpnManager: VPNBase
    let vpnHelper = VpnHelper.shared

    init(flutterBinary:FlutterBinaryMessenger,vpnBase: VPNBase) {
        self.flutterbinaryMessenger=flutterBinary
        self.vpnManager = vpnBase
        super.init(type: .vpnModel , flutterBinary: self.flutterbinaryMessenger)
        initializeVpnModel()
    }
    
    func initializeVpnModel()  {
        
    }
    
    
    override func doOnMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method=="switchVPN"){
            // Here for we need to opetaion on swif and go both sides
            if let args = call.arguments as? [String: Any] {
                let status = args["on"] as! Bool
                switchVPN(status: status)
            }else{
                result(FlutterError(code: "BAD_ARGS",
                                    message: "Expected arguments to be of type Dictionary.",
                                    details: nil))
            }
         }else{
            guard let minisqlValue = ValueUtil.convertToMinisqlValue(call.arguments) else {
                result(FlutterError(code: "ARGUMENTS_ERROR", message: "Failed to convert arguments to MinisqlValue", details: nil))
                return
            }
            do {
                let invocationResult = try invokeMethodOnGo(name: call.method, argument: minisqlValue)
                 if let originalValue = ValueUtil.convertFromMinisqlValue(from: invocationResult as! MinisqlValue) {
                    result(originalValue)
                } else {
                    result(FlutterError(code: "CONVERSION_ERROR", message: "Failed to convert MinisqlValue back to original value", details: nil))
                }
            } catch let error as NSError {
                 // Check for the specific "method not implemented" error
                if error.localizedDescription.contains("method not implemented") {
                    result(FlutterMethodNotImplemented)
                }
                // Check for another specific error (e.g., "database error")
                else if error.localizedDescription.contains("database error") {
                    result(FlutterError(code: "DATABASE_ERROR", message: "A database error occurred.", details: nil))
                }
                // Handle all other errors
                else {
                    result(FlutterError(code: "UNKNOWN_ERROR", message: error.localizedDescription, details: nil))
                }
            }
        }
    }
    
    
    private func saveVPNStatus(status:String){
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(status)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: "saveVpnStatus", argument: miniSqlValue!)
                 logger.log("Sucessfully set VPN status with  \(status)")
            }catch{
                logger.log("Error while setting VPN status")
            }
        }
    }
        
    func switchVPN(status:Bool){
        if status{
            startVPN()
        }else{
            stopVPN()
        }
    }
    
    func startVPN(){
        self.saveVPNStatus(status: "connected")
        vpnHelper.startVPN( onError: { error in
            // in case of error, reset switch position
            self.saveVPNStatus(status: "disconnected")
            logger.debug("VPN not started \(error)")
        },onSuccess: {
            logger.debug("VPN started")
            self.saveVPNStatus(status: "connected")
        })
     }
    
    func stopVPN(){
        vpnHelper.stopVPN()
        logger.debug("VPN Successfully stoped")
        self.saveVPNStatus(status: "disconnected")
     }
    
  
    func invokeMethodOnGo(name: String, argument: MinisqlValue) throws -> MinisqlValue {
        // Convert any argument to Minisql values
        let goResult = try model.invokeMethod(name, arguments: ValueArrayFactory.createValueArrayHandler(values: [argument]))
        return goResult
    }
    
    
}
