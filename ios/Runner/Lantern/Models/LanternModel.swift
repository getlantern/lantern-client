//
//  LanternModel.swift
//  Runner
//
//  Created by jigar fumakiya on 26/07/23.
//

import Foundation
import Internalsdk
import Flutter

class LanternModel:NSObject ,FlutterStreamHandler{
    
    
    
    let LANTERN_EVENT_CHANNEL="lantern_event_channel"
    let LANTERN_METHOED_CHANNEL="lantern_method_channel"
    
    var lanternMethodChannel:FlutterMethodChannel!
    var lanternEventChannel:FlutterEventChannel!

    var flutterbinaryMessenger:FlutterBinaryMessenger
    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init()
        lanternMethodChannel = FlutterMethodChannel(name: LANTERN_METHOED_CHANNEL, binaryMessenger: flutterBinary)
        lanternMethodChannel.setMethodCallHandler(handleMethodCall)
        lanternEventChannel = FlutterEventChannel(name: LANTERN_EVENT_CHANNEL, binaryMessenger: flutterBinary)
        lanternEventChannel.setStreamHandler(self)

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
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
}

