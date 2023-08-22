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

class BaseModel<T>: NSObject {
    
    var model: T!
    private var modelName: String  = "LANTERN_DB"
    private var modelType: ModelType

    // Add model type to the initializer
    init(type: ModelType) {
        self.modelType = type
        super.init()
        setupDB()
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
                guard let createdModel = InternalsdkNewSessionModel(self.modelName, swiftDB, &error) else {
                    throw error!
                }
                self.model = createdModel as! T
            case .messagingModel:
                guard let createdModel = InternalsdkNewMessagingModel(self.modelName, swiftDB, &error) else {
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
    
}
