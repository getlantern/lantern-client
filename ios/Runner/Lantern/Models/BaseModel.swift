//
//  BaseDatabaseModel.swift
//  Runner
//
//  Created by jigar fumakiya on 31/07/23.
//

import DBModule
import Flutter
import Foundation
import Internalsdk
import SQLite

internal var swiftDB: MinisqlDBProtocol?

open class BaseModel<M: InternalsdkModelProtocol>: NSObject, FlutterStreamHandler {
  var model: M
  var eventChannel: FlutterEventChannel!
  var methodChannel: FlutterMethodChannel!
  var binaryMessenger: FlutterBinaryMessenger!
  let activeSinks = AtomicReference<FlutterEventSink?>(nil)
  var activeSubscribers: Set<String> = []
  private let mainHandler = DispatchQueue.main
  private let asyncHandler = DispatchQueue(label: "BaseModel-AsyncHandler")
  private let invokeBackgroundQueue = DispatchQueue.global(qos: .background)

  init(_ flutterBinary: FlutterBinaryMessenger, _ model: M) throws {
    self.model = model
    self.binaryMessenger = flutterBinary
    super.init()
    DispatchQueue.main.async {
      self.setupFlutterChannels()
    }

  }

  internal static func getDB() throws -> MinisqlDBProtocol {
    if let db = swiftDB {
      return db
    } else {
      swiftDB = try DatabaseManager(getDatabasePath())
      return swiftDB!
    }
  }

  internal static func getDatabasePath() -> String {
    let fileManager = FileManager.default
    let dbDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
      .appendingPathComponent("masterDBv2")
    do {
      try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true, attributes: nil)
      let dbLocation = dbDir.appendingPathComponent("db").path
      logger.log("DB location \(dbLocation)")
      return dbLocation
    } catch {
      print("Error creating directory: \(error)")
      return ""  // Return an empty string or handle the error accordingly.
    }
  }

  private func setupFlutterChannels() {
    eventChannel = FlutterEventChannel(
      name: "\(model.name())_event_channel", binaryMessenger: binaryMessenger)
    eventChannel.setStreamHandler(self)

    methodChannel = FlutterMethodChannel(
      name: "\(model.name())_method_channel", binaryMessenger: binaryMessenger)
    methodChannel.setMethodCallHandler(handleMethodCall)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    logger.log("onListen initiated with arguments: \(String(describing: arguments))")
    guard let args = arguments as? [String: Any] else {
      let errorMessage =
        "Failed to cast arguments \(String(describing: arguments)) to dictionary. Exiting..."
      return createFlutterError(code: "INVALID_ARGUMENTS", message: errorMessage)
    }
    activeSinks.set(events)
    guard let subscriberID = args["subscriberID"] as? String,
      let path = args["path"] as? String
    else {
      let errorMessage = "Required parameters subscriberID or path missing in arguments. Exiting..."
      return createFlutterError(code: "MISSING_PARAMETERS", message: errorMessage)
    }

    let details = args["details"] as? Bool ?? false
    // Mark the subscriber as active
    activeSubscribers.insert(subscriberID)

    // Closure to send events back to the Flutter side asynchronously
    let notifyActiveSink = { (data: [String: Any]) in
      self.mainHandler.async {
        self.activeSinks.get()?(data)
      }
    }
    // Initializing the subscriber with callback for updates
    let subscriber = DetailsSubscriber(subscriberID: subscriberID, path: path) { updates, deletes in
      self.mainHandler.async {
        let data: [String: Any] = [
          "s": subscriberID,
          "u": updates,
          "d": deletes,
        ]
        notifyActiveSink(data)
      }
    }

    do {
      try model.subscribe(subscriber)
    } catch let error {
      let errorMessage = "An error occurred while subscribing: \(error.localizedDescription)"
      return createFlutterError(code: "SUBSCRIBE_ERROR", message: errorMessage)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if arguments == nil {
      return nil
    }
    guard let args = arguments as? [String: Any] else {
      let errorMessage =
        "onCancel Failed to cast arguments \(String(describing: arguments)) to dictionary. Exiting..."
      return createFlutterError(code: "INVALID_ARGUMENTS", message: errorMessage)
    }

    guard let subscriberID = args["subscriberID"] as? String else {
      let errorMessage = "Required parameters subscriberID missing in arguments. Exiting..."
      return createFlutterError(code: "MISSING_PARAMETERS", message: errorMessage)
    }

    model.unsubscribe(subscriberID)
    activeSubscribers.remove(subscriberID)
    return nil
  }

  // Method channels
  func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Handle your method calls here
    // The 'call' contains the method name and arguments
    // The 'result' can be used to send back the data to Flutter
    asyncHandler.async {
      self.doOnMethodCall(call: call, result: result)
    }
  }

  internal func doOnMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    do {
      let invocationResult = try model.invokeMethod(
        call.method, arguments: Arguments(call.arguments))

      if let originalValue = ValueUtil.convertFromMinisqlValue(
        from: invocationResult as! MinisqlValue)
      {
        result(originalValue)
      } else {
        result(
          FlutterError(
            code: "CONVERSION_ERROR",
            message: "Failed to convert MinisqlValue back to original value", details: nil))
      }
    } catch let error as NSError {

      // Check for the specific "method not implemented" error
      if error.localizedDescription.contains("method not implemented") {
        result(FlutterMethodNotImplemented)
      }
      // Check for another specific error (e.g., "database error")
      else if error.localizedDescription.contains("database error") {
        result(
          FlutterError(code: "DATABASE_ERROR", message: "A database error occurred.", details: nil))
      }
      // Handle all other errors
      else {
        result(
          FlutterError(code: "UNKNOWN_ERROR", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func createFlutterError(code: String, message: String, details: Any? = nil)
    -> FlutterError
  {
    logger.log(message)
    return FlutterError(code: code, message: message, details: details)
  }

  internal func invoke(
    _ name: String, arguments: Any = "",
    completion: @escaping (MinisqlValue?, Error?) -> Void
  ) {
    // Dispatch the invoke call asynchronously on the custom queue
    invokeBackgroundQueue.async {
      do {
        let result = try self.model.invokeMethod(name, arguments: try Arguments(arguments))
        DispatchQueue.main.async {
          completion(result, nil)
        }
      } catch {
        DispatchQueue.main.async {
          completion(nil, error)
        }
      }
    }
  }
}

private class Arguments: NSObject, InternalsdkArgumentsProtocol {
  private var s: MinisqlValue?
  private var dict: [String: MinisqlValue] = [:]

  init(_ v: Any) throws {
    switch v {
    case is [String: Any]:
      logger.debug("Setting arguments from map \(v)")
      let vmap = v as! [String: Any]
      for (key, val) in vmap {
        logger.debug("Setting argument \(key) of type \(type(of:val)) to \(val)")
        dict[key] = try Arguments.anyToValue(val)
      }
    default:
      logger.debug("Setting arguments from scalar \(v)")
      s = try Arguments.anyToValue(v)
    }
  }

  public func scalar() -> MinisqlValue? {
    return s
  }

  public func get(_ name: String?) -> MinisqlValue? {
    return dict[name!]
  }

  private static func anyToValue(_ v: Any?) throws -> MinisqlValue? {
    // Note - the order of these cases matters, for example Bool has to preceed Int
    // to correctly recognize __NSCFBoolean.
    switch v {
    case is String:
      return MinisqlNewValueString(v as? String)
    case is Bool:
      return MinisqlNewValueBool(v as! Bool)
    case is Int:
      return MinisqlNewValueInt(v as! Int)
    default:
      throw NSError(domain: "unrecognized value type", code: 999)
    }
  }
}

/// A simple thread-safe wrapper for atomic property access.
class AtomicReference<Value> {
  private var value: Value
  private let queue = DispatchQueue(label: "com.atomic.reference", attributes: .concurrent)

  init(_ value: Value) {
    self.value = value
  }

  func set(_ newValue: Value) {
    queue.async(flags: .barrier) {
      self.value = newValue
    }
  }

  func get() -> Value {
    return queue.sync {
      value
    }
  }
}
