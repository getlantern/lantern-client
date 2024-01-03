//
//  LanternModel.swift
//  Runner
//
//  Created by jigar fumakiya on 26/07/23.
//

import Flutter
import Foundation
import Internalsdk

class LanternModel: NSObject, FlutterStreamHandler {

  let LANTERN_EVENT_CHANNEL = "lantern_event_channel"
  let LANTERN_METHOED_CHANNEL = "lantern_method_channel"

  var lanternMethodChannel: FlutterMethodChannel!
  var lanternEventChannel: FlutterEventChannel!

  var flutterbinaryMessenger: FlutterBinaryMessenger

  init(flutterBinary: FlutterBinaryMessenger) {
    logger.log("Initializing LanternModel")

    self.flutterbinaryMessenger = flutterBinary
    super.init()

    DispatchQueue.main.async {
      self.lanternMethodChannel = FlutterMethodChannel(
        name: self.LANTERN_METHOED_CHANNEL, binaryMessenger: flutterBinary)
      self.lanternMethodChannel.setMethodCallHandler(self.handleMethodCall)
      self.lanternEventChannel = FlutterEventChannel(
        name: self.LANTERN_EVENT_CHANNEL, binaryMessenger: flutterBinary)
      self.lanternEventChannel.setStreamHandler(self)
    }

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

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    return nil
  }

}
