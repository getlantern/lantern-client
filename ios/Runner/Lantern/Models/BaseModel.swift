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
}


open class BaseModel<T>: NSObject ,FlutterStreamHandler{
    var model: T!
    private var schema: String  = "LANTERN_DB"
    private var modelType: ModelType
    var eventChannel: FlutterEventChannel!
    var methodChannel: FlutterMethodChannel!
    var binaryMessenger: FlutterBinaryMessenger!
    var activeSinks: FlutterEventSink?
    var activeSubscribers: Set<String> = []
    var asyncHandler: DispatchQueue = DispatchQueue(label: "asyncHandlerQueue")
    
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
        }
        eventChannel = FlutterEventChannel(name: "\(modelName)_event_channel", binaryMessenger: binaryMessenger)
        eventChannel.setStreamHandler(self)
        
        methodChannel = FlutterMethodChannel(name: "\(modelName)_method_channel", binaryMessenger: binaryMessenger)
        methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            // Handle method calls
        }
    }
    
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        logger.log("onListen initiated with arguments: \(arguments)")
        guard let args = arguments as? [String: Any] else {
            let errorMessage = "Failed to cast arguments \(arguments) to dictionary. Exiting..."
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
        
        let subscriber = DetailsSubscriber(subscriberID: subscriberID, path: path) { updates, deletes in
         
            logger.log("Received")
        }
        
        do {
            try handleSubscribe(for: model, subscriber: subscriber)
        } catch let error {
            let errorMessage = "An error occurred while subscribing: \(error.localizedDescription)"
            logger.log(errorMessage)
            return FlutterError(code: "SUBSCRIBE_ERROR", message: errorMessage, details: nil)
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if(arguments==nil){
            let errorMessage = "Arguments found nill"
            return FlutterError(code: "MISSING_PARAMETERS", message: errorMessage, details: nil)
        }
        guard let args = arguments as? [String: Any] else {
            let errorMessage = "onCancel Failed to cast arguments \(arguments) to dictionary. Exiting..."
            logger.log(errorMessage)
            return FlutterError(code: "INVALID_ARGUMENTS", message: errorMessage, details: nil)
        }
        
        guard let subscriberID = args["subscriberID"] as? String else {
            let errorMessage = "Required parameters subscriberID missing in arguments. Exiting..."
            logger.log(errorMessage)
            return FlutterError(code: "MISSING_PARAMETERS", message: errorMessage, details: nil)
        }
        
        do {
            try handleUnsubscribe(for: model, subscriberID: subscriberID)
            activeSubscribers.remove(subscriberID)
        } catch let error {
            let errorMessage = "An error occurred while unsubscribing: \(error.localizedDescription)"
            logger.log(errorMessage)
            return FlutterError(code: "UNSUBSCRIBE_ERROR", message: errorMessage, details: nil)
        }
        return nil
    }
    
    
    //Method channels
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        asyncHandler.async {
            self.doMethodCall(call: call, result: result)
        }
        
    }
    
    open func doMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
          // Default implementation. This will force subclasses to provide their own implementation.
          fatalError("Subclasses must implement this method.")
      }
      
    
    
    func handleSubscribe(for model: Any, subscriber: DetailsSubscriber) throws {
        switch model {
        case let sessionModelSub as InternalsdkSessionModel:
            try sessionModelSub.subscribe(subscriber)
        case let messagingModel as InternalsdkMessagingModel:
            try messagingModel.subscribe(subscriber)
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
        default:
            throw NSError(domain: "UnsupportedModel", code: 999, userInfo: ["Description": "Unsupported model type."])
        }
    }
    }


