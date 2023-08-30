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
        initializeAppSettings()
    }
    
   func initializeAppSettings(){
       setTimeZone()
       setReferalCode()
       initializeSessionModel()
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
    
    
    private func initializeSessionModel(){
        let initData: [String: [String: Any]]  = [
            "developmentMode": ["type": ValueUtil.TYPE_BOOL, "value": true],
            "playVersion": ["type": ValueUtil.TYPE_BOOL, "value": true]
        ]
        guard let jsonString = JsonUtil.convertToJSONString(initData) else {
            logger.log("Failed to convert initializationData to JSON")
            return
        }
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(jsonString)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: "initSesssionModel", argument: miniSqlValue!)
                logger.log("Sucessfully set initData \(jsonString) result")
            }catch{
                logger.log("Error while setting initData")
            }
        }
    }
    
    
    private func setTimeZone(){
        let timeZoneId = TimeZone.current.identifier
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(timeZoneId)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: "setTimeZone", argument: miniSqlValue!)
                 logger.log("Sucessfully set timezone with id \(timeZoneId) result \(result)")
            }catch{
                logger.log("Error while setting timezone")
            }
        }
    }
    
    func setReferalCode(){
        let miniSqlValue =  ValueUtil.convertToMinisqlValue("Test007")
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: "setReferalCode", argument: miniSqlValue!)
                 logger.log("Sucessfully set ReferalCode result \(result)")
            }catch{
                logger.log("Error while setting ReferalCode")
            }
        }
    }
    

    func setForceCountry(countryCode:String){
        let countryMiniSql =  ValueUtil.convertToMinisqlValue(countryCode)
        if(countryMiniSql != nil){
            do {
                let result = try  invokeMethodOnGo(name: "setForceCountry", argument: countryMiniSql!)
                 logger.log("Sucessfully set force country")
            }catch{
                logger.log("Error while setting  up forceCountry")
            }
        }
    }
    
    
    func setLocal(lang:String){
        let langSqlValue =  ValueUtil.convertToMinisqlValue(lang)
        if(langSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: "setLocal", argument: langSqlValue!)
                 logger.log("Sucessfully set Local result \(result)")
            }catch{
                logger.log("Error while setting Local")
            }
        }
    }
    
   
    
    
    
    func invokeMethodOnGo(name: String, argument: MinisqlValue) throws -> Any {
        // Convert any argument to Minisql values
        let goResult = try model.invokeMethod(name, arguments: ValueArrayHandler(values: [argument]))
        return goResult
    }
    
}


