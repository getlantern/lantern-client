//
//  NavigationModel.swift
//  Runner
//
//  Created by jigar fumakiya on 12/09/23.
//

import Flutter
import Foundation

class NavigationModel {
  let navigationMethodChannel = "lantern_method_channel"

  var flutterbinaryMessenger: FlutterBinaryMessenger

  init(flutterBinary: FlutterBinaryMessenger) {
    self.flutterbinaryMessenger = flutterBinary
    prepareNavigationChannel()
  }

  private func prepareNavigationChannel() {

    // Navigation Channel
    let navigationChannel = FlutterMethodChannel(
      name: navigationMethodChannel, binaryMessenger: flutterbinaryMessenger)
    navigationChannel.setMethodCallHandler(handleNavigationethodCall)
  }

  func handleNavigationethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
