//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation
import Internalsdk
import Flutter
import UIKit


class SessionModel:BaseModel<InternalsdkSessionModel> {
    var flutterbinaryMessenger:FlutterBinaryMessenger
    lazy var notificationsManager: UserNotificationsManager = {
        return UserNotificationsManager()
    }()
    
    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init(type: .sessionModel , flutterBinary: self.flutterbinaryMessenger)
        initializeAppSettings()
    }
    
    func initializeAppSettings(){
        initializeSessionModel()
        setTimeZone()
        setDNS()
        getBandwidth()
        startService()
}
    
    func startService(){
        do{
            let configDir = configDirFor( suffix: "service")
            var error: NSError?
            
            (model as InternalsdkSessionModel).startService(configDir, locale: "en", settings: Settings())
            if error != nil {
                logger.error("Getting error setting up server")
                return
            }
        } catch{
            logger.error("Getting error setting up server")
        }
        logger.error("Service Started successfully")
        
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
        // Setup the initly data
        let initData = createInitData()

        guard let jsonString = JsonUtil.convertToJSONString(initData) else {
            logger.log("Failed to convert initializationData to JSON")
            return
        }
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(jsonString)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.initModel.methodName, argument: miniSqlValue!)
                logger.log("Sucessfully set initData \(jsonString) result")
            }catch{
                logger.log("Error while setting initData")
            }
        }
    }
    
    // Set initly data that needed by flashlight
    // later on values change be chaneg by mehtod or by flashlight
    private func createInitData() -> [String: [String: Any]] {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        return [
            Constants.developmentMode: ["type": ValueUtil.TYPE_BOOL, "value": true],
            Constants.prouser: ["type": ValueUtil.TYPE_BOOL, "value": false],
            Constants.deviceid: ["type": ValueUtil.TYPE_STRING, "value": deviceId],
            Constants.playVersion: ["type": ValueUtil.TYPE_BOOL, "value": isRunningFromAppStore()],
        ]
        
    }
    
    
    func createUser(local:String) -> Bool{
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(local)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.createUser.methodName, argument: miniSqlValue!)
                var converedResult = ValueUtil.convertFromMinisqlValue(from: result)
                if(converedResult as! Bool){
                    logger.log("User Created \(converedResult)")
                    return true
                }
                return false
            }catch{
                logger.log("Error while create user")
            }
        }
        return false
    }
    
    
    private func setTimeZone(){
        let timeZoneId = TimeZone.current.identifier
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(timeZoneId)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.setTimezone.methodName, argument: miniSqlValue!)
                logger.log("Sucessfully set timezone with id \(timeZoneId) result \(result)")
            }catch{
                logger.log("Error while setting timezone")
            }
        }
    }
    
    
    func setDeviceId(){
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(deviceId)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.setDeviceId.methodName, argument: miniSqlValue!)
                logger.log("Sucessfully set device ID \(deviceId) ")
            }catch{
                logger.log("Error while setting deevice ID")
            }
        }
    }
    
    
    func getBandwidth(){
        let miniSqlValue =  ValueUtil.convertToMinisqlValue("")
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.getBandwidth.methodName, argument: miniSqlValue!)
                let newValue = ValueUtil.convertFromMinisqlValue(from: result)
                //If value is not null mean user has alerady start using bandwith
                // We will get that value from Go
                if((newValue as! String) != ""){
                    let limit = newValue as! Int
                    if(limit==100){
                        // if user has reached limit show the notificaiton
                        notificationsManager.scheduleDataCapLocalNotification(withDataLimit: limit)
                    }
                }else{
                    
                }
                logger.log("Sucessfully getbandwidth  \(newValue)")
            }catch{
                logger.log("Error while getting bandwidth")
            }
        }
    }
        
    
    func storeVersion(){
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(isRunningFromAppStore())
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.setStoreVersion.methodName, argument: miniSqlValue!)
                logger.log("This is app store version \(result)")
            }catch{
                logger.log("Error while setting storeVersion")
            }
        }
    }
    
    
    
    func setForceCountry(countryCode:String){
        let countryMiniSql =  ValueUtil.convertToMinisqlValue(countryCode)
        if(countryMiniSql != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.setForceCountry.methodName, argument: countryMiniSql!)
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
                let result = try  invokeMethodOnGo(name: Methods.setLocal.methodName, argument: langSqlValue!)
                logger.log("Sucessfully set Local result \(result)")
            }catch{
                logger.log("Error while setting Local")
            }
        }
    }
    
    private func setDNS(){
        let timeZoneId = TimeZone.current.identifier
        let miniSqlValue =  ValueUtil.convertToMinisqlValue(DnsDetector.DEFAULT_DNS_SERVER)
        if(miniSqlValue != nil){
            do {
                let result = try  invokeMethodOnGo(name: Methods.setTimezone.methodName, argument: miniSqlValue!)
                logger.log("Sucessfully set timezone with id \(timeZoneId) result \(result)")
            }catch{
                logger.log("Error while setting timezone")
            }
        }
    }
    
    
    
    
    // Todo:- Move this method base model
    func invokeMethodOnGo(name: String, argument: MinisqlValue) throws -> MinisqlValue {
        // Convert any argument to Minisql values
        let goResult = try model.invokeMethod(name, arguments: ValueArrayHandler(values: [argument]))
        return goResult
    }
    
    
    public func configDirFor(suffix: String) -> String {
        let filesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = filesDirectory.appendingPathComponent(".lantern" + suffix)

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        return fileURL.path
    }
}


 



class Settings :NSObject, InternalsdkSettingsProtocol{
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

