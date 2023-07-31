//
//  BaseDatabaseModel.swift
//  Runner
//
//  Created by jigar fumakiya on 31/07/23.
//

import Foundation
import Internalsdk

//Work In progress
class BaseDatabaseModel: NSObject {
    // Access the shared instance of SessionManager and get the DatabaseManager
    let dbManager: DatabaseManager = SessionManager.shared.db

  

    // For example, a method to execute a database query
    func execQuery(_ query: String?, args: InternalsdkValueArrayProtocol?) throws -> InternalsdkResultProtocol {
        return try dbManager.exec(query, args: args)
    }
}
