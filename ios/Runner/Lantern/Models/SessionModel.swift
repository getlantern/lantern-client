//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation
import Internalsdk
import Flutter

class SessionModel:BaseModel<InternalsdkSessionModel> {
    var flutterbinaryMessenger:FlutterBinaryMessenger
 
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init(type: .sessionModel , flutterBinary: self.flutterbinaryMessenger)
     }
   
    override func doOnMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
            // Convert the entire arguments to a single MinisqlValue
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
    
    func invokeMethodOnGo(name: String, argument: MinisqlValue) throws -> Any {
        // Convert any argument to Minisql values
        let goResult = try model.invokeMethod(name, arguments: ValueArrayHandler(values: [argument]))
        return goResult
    }
    
}


