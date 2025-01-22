//
//  RunningEnv.swift
//  Runner
//
//  Created by jigar fumakiya on 01/09/23.

import Foundation

func isRunningFromAppStore() -> Bool {
  let file = "\(NSHomeDirectory())/iTunesMetadata.plist"
  if FileManager.default.fileExists(atPath: file) {
    // The app is running from the App Store
    return true
  } else {
    // The app is not running from the App Store
    return false
  }
}

func isRunningInTestFlightEnvironment() -> Bool {
  if isSimulator() {
    return false
  } else {
    if isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision() {
      return true
    } else {
      return false
    }
  }
}

private func hasEmbeddedMobileProvision() -> Bool {
  if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
    return true
  }
  return false
}

func isAppStoreReceiptSandbox() -> Bool {
  if isSimulator() {
    return false
  } else {
    if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
      if appStoreReceiptURL.lastPathComponent == "sandboxReceipt" {
        return true
      }
    }
    return false
  }
}

func isSimulator() -> Bool {
  #if arch(i386) || arch(x86_64)
    return true
  #else
    return false
  #endif
}

enum AppEnvironment: String {

  case appiumTest
  case prod

  static var current: AppEnvironment {
    let schemeName = Bundle.main.infoDictionary!["CURRENT_SCHEME_NAME"] as! String
    logger.log("Current scheme is \(schemeName)")
    if schemeName == "appiumTest" {
      return .appiumTest
    } else {
      return .prod
    }

  }
}
