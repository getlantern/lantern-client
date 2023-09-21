//
//  BaseDatabaseModel.swift
//  Runner
//
//  Created by jigar fumakiya on 31/07/23.
//

import Foundation
import Internalsdk
import SQLite
import Flutter

enum ModelType {
    case sessionModel
    case messagingModel
    case vpnModel
}


open class BaseModel<T>: NSObject ,FlutterStreamHandler{
    var model: T!
    private var schema: String  = "LANTERN_DB"
    private var modelType: ModelType
    var eventChannel: FlutterEventChannel!
    var methodChannel: FlutterMethodChannel!
    var binaryMessenger: FlutterBinaryMessenger!
    let activeSinks = AtomicReference<FlutterEventSink?>(nil)
    var activeSubscribers: Set<String> = []
    private let mainHandler = DispatchQueue.main
    private let asyncHandler = DispatchQueue(label: "BaseModel-AsyncHandler")
    
    
    init(type: ModelType,flutterBinary:FlutterBinaryMessenger) {
        self.modelType = type
        self.binaryMessenger = flutterBinary
        super.init()
        setupDB()
        setupFlutterChannels()
    }
    
    private func setupDB() {
        do {
            let dbPath = getDatabasePath()
            let db = try Connection(dbPath)
            let swiftDB = DatabaseManager(database: db)
            var error: NSError?
            
            // Depending on the model type, initialize the correct model
            switch modelType {
            case .sessionModel:
                guard let createdModel = InternalsdkNewSessionModel(self.schema, swiftDB, &error) else {
                    throw error!
                }
                self.model = createdModel as! T
            case .messagingModel:
                guard let createdModel = InternalsdkNewMessagingModel(self.schema, swiftDB, &error) else {
                    throw error!
                }
                self.model = createdModel as! T
            case .vpnModel:
                guard let createdModel = InternalsdkNewVpnModel(self.schema, swiftDB, &error) else {
                    throw error!
                }
                self.model = createdModel as! T
            }
            
        } catch {
            logger.log("Failed to create new model: \(error)")
        }
    }
    
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let dbDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("masterDBv2")
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
        var modelName = ""
        switch modelType {
        case .sessionModel:
            modelName = "session"
        case .messagingModel:
            modelName = "messaging"
        case .vpnModel:
            modelName = "vpn"
        }
    
        eventChannel = FlutterEventChannel(name: "\(modelName)_event_channel", binaryMessenger: binaryMessenger)
        eventChannel.setStreamHandler(self)
        
        methodChannel = FlutterMethodChannel(name: "\(modelName)_method_channel", binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler(handleMethodCall)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        logger.log("onListen initiated with arguments: \(arguments)")
        guard let args = arguments as? [String: Any] else {
            let errorMessage = "Failed to cast arguments \(arguments) to dictionary. Exiting..."
            return createFlutterError(code:"INVALID_ARGUMENTS", message: errorMessage)
        }
        activeSinks.set(events)
        guard let subscriberID = args["subscriberID"] as? String,
              let path = args["path"] as? String else {
            let errorMessage = "Required parameters subscriberID or path missing in arguments. Exiting..."
            return createFlutterError(code:"MISSING_PARAMETERS", message: errorMessage)
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
                    "d": deletes
                ]
                notifyActiveSink(data)
            }
        }
        
        do {
            try handleSubscribe(for: model, subscriber: subscriber)
        } catch let error {
            let errorMessage = "An error occurred while subscribing: \(error.localizedDescription)"
            return createFlutterError(code:"SUBSCRIBE_ERROR", message: errorMessage)
         }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if(arguments==nil){
            return nil
        }
        guard let args = arguments as? [String: Any] else {
            let errorMessage = "onCancel Failed to cast arguments \(arguments) to dictionary. Exiting..."
            return createFlutterError(code:"INVALID_ARGUMENTS", message: errorMessage)
        }
        
        guard let subscriberID = args["subscriberID"] as? String else {
            let errorMessage = "Required parameters subscriberID missing in arguments. Exiting..."
            return createFlutterError(code:"MISSING_PARAMETERS", message: errorMessage)
        }
        
        do {
            try handleUnsubscribe(for: model, subscriberID: subscriberID)
            activeSubscribers.remove(subscriberID)
        } catch let error {
            let errorMessage = "An error occurred while unsubscribing: \(error.localizedDescription)"
            return createFlutterError(code:"UNSUBSCRIBE_ERROR", message: errorMessage)
        }
        return nil
    }
    
    
    //Method channels
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        asyncHandler.async {
            self.doOnMethodCall(call: call, result: result)
        }
    }
    
    open func doOnMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Default implementation. This will force subclasses to provide their own implementation.
        fatalError("Subclasses must implement this method.")
    }
    
    func handleSubscribe(for model: Any, subscriber: DetailsSubscriber) throws {
        switch model {
        case let sessionModelSub as InternalsdkSessionModel:
            try sessionModelSub.subscribe(subscriber)
        case let messagingModel as InternalsdkMessagingModel:
            try messagingModel.subscribe(subscriber)
        case let vpnModel as InternalsdkVpnModel:
            try vpnModel.subscribe(subscriber)
        default:
            throw NSError(domain: "UnsupportedModel", code: 999, userInfo: ["Description": "Unsupported model type."])
        }
    }
    
    func handleUnsubscribe(for model: Any, subscriberID: String) throws {
        switch model {
        case let sessionSub as InternalsdkSessionModel:
            try sessionSub.unsubscribe(subscriberID)
        case let messagingModel as InternalsdkMessagingModel:
            try messagingModel.unsubscribe(subscriberID)
        case let vpnModel as InternalsdkVpnModel:
            try vpnModel.unsubscribe(subscriberID)
        default:
            throw NSError(domain: "UnsupportedModel", code: 999, userInfo: ["Description": "Unsupported model type."])
        }
    }
    
    private func createFlutterError(code: String, message: String, details: Any? = nil) -> FlutterError {
        logger.log(message)
        return FlutterError(code: code, message: message, details: details)
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
