//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation
import Internalsdk
import Flutter

class SessionModel:NSObject, FlutterStreamHandler,InternalsdkReceiveStreamProtocol {
    
    let SESSION_METHOD_CHANNEL="session_method_channel"
    let SESSION_EVENT_CHANNEL="session_event_channel"
    
    var sessionEventChannel:FlutterEventChannel!
    var sessionMethodChannel:FlutterMethodChannel!
    var flutterbinaryMessenger:FlutterBinaryMessenger
    let internalSessioModelChannel=InternalsdkSessionModelChannel()!
    let internalSessioEventChannel = InternalsdkEventChannel("session_event_channel")!
    var activeSinks: FlutterEventSink?

    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init()
        sessionEventChannel = FlutterEventChannel(name: SESSION_EVENT_CHANNEL, binaryMessenger: flutterBinary)
        sessionEventChannel.setStreamHandler(self)
        
        sessionMethodChannel = FlutterMethodChannel(name: SESSION_METHOD_CHANNEL, binaryMessenger: flutterBinary)
        sessionMethodChannel.setMethodCallHandler(handleMethodCall)
        internalSessioEventChannel.setReceiveStream(self)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.activeSinks = events
//        internalSessioEventChannel.invoke(onListen: arguments.)
        logger.log("Session Event listen called with \(arguments)")
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
        
        switch call.method {
        case "SayHiMethodCall":
            do {
                let goResult = try invokeMethodOnGo(name: call.method, argument: "Hi")
                result(goResult)
            } catch {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    //Mark :- GO method channel callback
    func invokeMethodOnGo(name: String, argument: String) throws -> String {
        var error: NSError?
        let result = internalSessioModelChannel.invokeMethod(name, argument: argument, error: &error)
        if let error = error {
            logger.log("Error invoking method \(name) on channel SessionModel with argument \(argument): \(error)")
            throw error
        }
        return result
    }
    
    //GO Event channel callback
    func onDataReceived(_ data: String?) {
        logger.log("Session  onDataReceived called with \(data)")
        activeSinks?(data)
        
        
    }
}
