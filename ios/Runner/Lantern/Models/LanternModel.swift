//
//  LanternModel.swift
//  Runner
//
//  Created by jigar fumakiya on 26/07/23.
//

import Foundation
import Internalsdk
import Flutter

class LanternModel:NSObject,InternalsdkReceiveStreamProtocol {
    
    let LANTERN_EVENT_CHANNEL="lantern_event_channel"
    let LANTERN_METHOED_CHANNEL="lantern_method_channel"
    
    var lanternEventManager: EventManager!
    var lanternMethodChannel:FlutterMethodChannel!
    var flutterbinaryMessenger:FlutterBinaryMessenger
    let internalLanternModelChannel=InternalsdkSessionModelChannel()!
    let internalLanternEventChannel = InternalsdkEventChannel("lantern_event_channel")!
    
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init()
       
    lanternEventManager = EventManager(name: LANTERN_EVENT_CHANNEL, binaryMessenger: flutterbinaryMessenger ,onListenClosure:onEventListen)
        lanternMethodChannel = FlutterMethodChannel(name: LANTERN_METHOED_CHANNEL, binaryMessenger: flutterBinary)
        lanternMethodChannel.setMethodCallHandler(handleMethodCall)
        internalLanternEventChannel.setReceiveStream(self)
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
    
    func onEventListen(event:Event){
        
    }
    
    
    //Mark :- GO method channel callback
    func invokeMethodOnGo(name: String, argument: String) -> String? {
        var error: NSError?
        let result = internalLanternModelChannel.invokeMethod(name, argument: argument, error: &error)
        if let error = error {
            logger.log("Error invoking method \(name) on channel SessionModel with argument \(argument): \(error)")
            return nil
        }
        return result
    }
    
    //GO Event channel callback
    func onDataReceived(_ data: String?) {
    }
}

