//
//  SubscriberRequest.swift
//  Runner
//
//  Created by jigar fumakiya on 25/08/23.
//

import Foundation
import Internalsdk
import Flutter

class DetailsSubscriber: InternalsdkSubscriptionRequest {
    
    var subscriberID: String
    var path: String
    var updaterDelegate: DetailsSubscriberUpdater
    
    init(subscriberID: String, path: String, onChanges: @escaping ([String:Any], [String]) -> Void) {
        self.subscriberID = subscriberID
        self.path = path
        self.updaterDelegate = DetailsSubscriberUpdater()
        super.init()
        self.id_ = subscriberID
        self.pathPrefixes = path
        self.receiveInitial = true
        self.updater = updaterDelegate
        updaterDelegate.onChangesCallback = onChanges
    }
    
}


class DetailsSubscriberUpdater: NSObject, InternalsdkUpdaterModelProtocol {
    var onChangesCallback: (([String: Any], [String]) -> Void)?
    typealias DynamicKeysData = [String: ItemDetail]
    
    func onChanges(_ cs: InternalsdkChangeSetInterface?) throws {
        guard let cs = cs else {
            throw NSError(domain: "onChangesError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ChangeSet is nil"])
        }
        let decoder = JSONDecoder()
        var updatesDictionary: [String: Any] = [:]
        var deletesList: [String] = []
        
        // Deserialize updates
           if let updatesData = cs.updatesSerialized.data(using: .utf8), !updatesData.isEmpty {
               do {
                   let updates = try decoder.decode(DynamicKeysData.self, from: updatesData)
                   
                   updatesDictionary = Dictionary(uniqueKeysWithValues: updates.map { (path, detail) -> (String, Any) in
                       return (path, detail.value.value)
                   })
                   
               } catch let jsonError {
                   logger.log("Error deserializing updates: \(jsonError.localizedDescription)")
                   throw jsonError
               }
           } else {
               logger.log("No updatesSerialized data to parse or it's empty.")
           }
        
       
        // Deserialize deletes
          if cs.deletesSerialized.lowercased() != "null" {
              if let deletesData = cs.deletesSerialized.data(using: .utf8), !deletesData.isEmpty {
                  do {
                      
                      deletesList = try decoder.decode([String].self, from: deletesData)
                    } catch let jsonError {
                      logger.log("Error deserializing deletes: \(jsonError.localizedDescription)")
                      throw jsonError
                  }
              } else {
                  logger.log("No deletesSerialized data to parse or it's empty.")
              }
          }
       
        onChangesCallback?(updatesDictionary, deletesList)
        
    }
}



// Json Decode

struct ItemDetail: Codable {
    let path: String
    let detailPath: String
    let value: ValueStruct
    
    enum CodingKeys: String, CodingKey {
        case path = "Path"
        case detailPath = "DetailPath"
        case value = "Value"
    }
}


struct ValueStruct: Codable {
    let type: Int
    var value: Any?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Int.self, forKey: .type)
        
        switch type {
        case ValueUtil.TYPE_BYTES: // Assuming this corresponds to bytes
            // Handle bytes
            let stringValue = try container.decode(String.self, forKey: .value)
            value = Data(base64Encoded: stringValue)
        case ValueUtil.TYPE_STRING:
            value = try container.decode(String.self, forKey: .value)
        case ValueUtil.TYPE_INT:
            value = try container.decode(Int.self, forKey: .value)
        case ValueUtil.TYPE_BOOL:
            value = try container.decode(Bool.self, forKey: .value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .value,
                in: container,
                debugDescription: "Invalid type"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch type {
        case ValueUtil.TYPE_BYTES:
            // Handle bytes
            if let dataValue = value as? Data {
                try container.encode(dataValue.base64EncodedString(), forKey: .value)
            }
        case ValueUtil.TYPE_STRING:
            try container.encode(value as? String, forKey: .value)
        case ValueUtil.TYPE_INT:
            try container.encode(value as? Int, forKey: .value)
        case ValueUtil.TYPE_BOOL:
            try container.encode(value as? Bool, forKey: .value)
        default:
            throw EncodingError.invalidValue(value as Any, EncodingError.Context(codingPath: [CodingKeys.value], debugDescription: "Invalid type"))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case value = "Value"
    }
}




