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

class BaseDatabase: NSObject {
    
    var model: InternalsdkModelProtocol!
    private var modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
        super.init()
        setupDB()
    }
    
    private func setupDB() {
        do {
            let dbPath = getDatabasePath()
            
            let db = try Connection(dbPath)
            let swiftDB = DatabaseManager(database: db)
            var error: NSError?
            guard let createdModel = InternalsdkNewModel(self.modelName, swiftDB, &error) else {
                throw error!
            }
            self.model = createdModel
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
    
    
    func put(path:String, values:ValueArrayHandler, fullText:String?){
        do {
            var putSuccess: ObjCBool = false
            let result = try model.put(path, value: values , fullText: fullText, ret0_: &putSuccess)
            if !putSuccess.boolValue {
                logger.log("Failed to Put with Value : \(values) and path \(path). Error:  Unknown error")
            }
        } catch {
            
        }
    }
    
    func get(path:String) -> Data?{
        do{
            let data = try  model.get(path)
            logger.log("GET path data \(data)")
            return data
        }catch{
//            logger.log("Failed to GET path \(path)")
        }
        return nil
    }
    
    
    func delete(path:String, values:ValueArrayHandler, fullText:String?){
        do {
            var deleteSuccess:ObjCBool = false
            let result = try model.delete(path, ret0_: &deleteSuccess)
            if !deleteSuccess.boolValue {
                logger.log("Failed to Delete path \(path)")
            }
        } catch {
            
        }
    }
    
}
