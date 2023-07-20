//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation

class SessionModel:NSObject, FlutterStreamHandler {
    
    let SESSION_METHOD_CHANNEL="session_method_channel"
    let SESSION_EVENT_CHANNEL="session_event_channel"
    
    var sessionEventChannel:FlutterEventChannel!
    var sessionMethodChannel:FlutterMethodChannel!
    var flutterbinaryMessenger:FlutterBinaryMessenger
    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init()
        sessionEventChannel = FlutterEventChannel(name: SESSION_EVENT_CHANNEL, binaryMessenger: flutterBinary)
        sessionEventChannel.setStreamHandler(self)
        
        sessionMethodChannel = FlutterMethodChannel(name: SESSION_METHOD_CHANNEL, binaryMessenger: flutterBinary)
        sessionMethodChannel.setMethodCallHandler(handleMethodCall)
    }
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("Session model onListen Called")

        logger.debug("Session model onListen Called with \(String(describing: arguments))")
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        logger.debug("Session model onCancel Called with \(String(describing: arguments))")
        print("Session model onListen Called")
        return nil
    }
    
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        
        switch call.method {
        case "yourMethod":
            // handle yourMethod
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
