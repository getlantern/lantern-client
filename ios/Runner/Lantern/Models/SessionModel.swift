//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation
import Internalsdk
import Flutter

class SessionModel:BaseModel<InternalsdkSessionModel>, FlutterStreamHandler {
    
    let SESSION_METHOD_CHANNEL="session_method_channel"
    let SESSION_EVENT_CHANNEL="session_event_channel"
    
    var sessionEventChannel:FlutterEventChannel!
    var sessionMethodChannel:FlutterMethodChannel!
    var flutterbinaryMessenger:FlutterBinaryMessenger
    var activeSinks: FlutterEventSink?
    var activeSubscribers: Set<String> = []
    var asyncHandler: DispatchQueue = DispatchQueue(label: "SessionModelasyncHandlerQueue")
    
    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init(type: .sessionModel )
        sessionEventChannel = FlutterEventChannel(name: SESSION_EVENT_CHANNEL, binaryMessenger: flutterBinary)
        sessionEventChannel.setStreamHandler(self)
        
        sessionMethodChannel = FlutterMethodChannel(name: SESSION_METHOD_CHANNEL, binaryMessenger: flutterBinary)
        sessionMethodChannel.setMethodCallHandler(handleMethodCall)
        
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        logger.log("onListen initiated with arguments: \(arguments)")
        guard let args = arguments as? [String: Any] else {
            let errorMessage = "Failed to cast arguments to dictionary. Exiting..."
            logger.log(errorMessage)
            return FlutterError(code: "INVALID_ARGUMENTS", message: errorMessage, details: nil)
        }
        activeSinks = events
        
        guard let subscriberID = args["subscriberID"] as? String,
              let path = args["path"] as? String else {
            let errorMessage = "Required parameters subscriberID or path missing in arguments. Exiting..."
            logger.log(errorMessage)
            return FlutterError(code: "MISSING_PARAMETERS", message: errorMessage, details: nil)
        }
        
        
        let details = args["details"] as? Bool ?? false
        activeSubscribers.insert(subscriberID)
        let sub = DetailsSubscriber(subscriberID: subscriberID, path: path) { changes in
            // Handle the changes here.
            logger.log("Received changes: \(String(describing: changes))")
        }
        
        do {
            try model.subscribe(sub)
        } catch let error {
            let errorMessage = "An error occurred while subscribing: \(error.localizedDescription)"
            logger.log(errorMessage)
            return FlutterError(code: "SUBSCRIBE_ERROR", message: errorMessage, details: nil)
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        logger.log("Session Event onCancel called with \(arguments)")
        return nil
    }
    
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        asyncHandler.async {
            self.doMethodCall(call: call, result: result)
        }
        
    }
    
    
    func doMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        do {
            let goResult = try invokeMethodOnGo(name: call.method, argument: call.arguments)
            
            result(goResult)
        } catch let error as NSError {
            switch (error.domain, error.localizedDescription) {
            case ("GoError", "unknown method"):
                result(FlutterMethodNotImplemented)
            default:
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    func invokeMethodOnGo(name: String, argument: Any) throws -> Any {
        //Convert any argument to Minisql values
        let result = try model.invokeMethod(name, arguments: argument as? MinisqlValuesProtocol)
        return result
    }
    
}

class DetailsSubscriber: InternalsdkSubscriptionRequest {
    
    var subscriberID: String
    var path: String
    var updaterDelegate: DetailsSubscriberUpdater
    
    init(subscriberID: String, path: String, onChanges: @escaping (InternalsdkChangeSetInterface?) -> Void) {
        self.subscriberID = subscriberID
        self.path = path
        self.updaterDelegate = DetailsSubscriberUpdater()
        super.init()
        
        self.id_ = subscriberID
        self.pathPrefixes = path
        self.receiveInitial = true
        self.updater = updaterDelegate
        updaterDelegate.onChangesCallback = onChanges
    }
    
}

class DetailsSubscriberUpdater: NSObject, InternalsdkUpdaterModelProtocol {
    var onChangesCallback: ((InternalsdkChangeSetInterface?) -> Void)?
    
    func onChanges(_ cs: InternalsdkChangeSetInterface?) throws {
        onChangesCallback?(cs)
    }
}

