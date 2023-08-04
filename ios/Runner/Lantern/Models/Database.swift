//
//  DB.swift
//  Runner
//
//  Created by jigar fumakiya on 28/07/23.
//

import Foundation
import Internalsdk
import FMDB
import SQLite


class DatabaseManager: NSObject, MinisqlDBProtocol {
   private let db: Connection
   private var currentTransaction: TransactionManager?
    
    init(database: Connection) {
        self.db = database
    }
    
    func begin() throws -> InternalsdkTxProtocol {
        logger.log("begin() method called.")
        if currentTransaction != nil {
            logger.log("begin() method error: A transaction is already in progress.")
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "A transaction is already in progress"])
        }
        let transaction = TransactionManager(database: db)
        currentTransaction = transaction
        return transaction
    }
    
    func close() throws {
        logger.log("close() method called.")
        //
    }
    
    func exec(_ query: String?, args: InternalsdkValueArrayProtocol?) throws -> InternalsdkResultProtocol {
        logger.log("exec() method called with query: \(query ?? "nil")")
        guard let query = query, let args = args else {
            logger.log("exec() method error: query or args was nil.")
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let bindings = ValueUtil.toBindingsArray(args)
        let statement = try db.prepare(query)
        
        if let transaction = currentTransaction {
            transaction.addStatement(statement)
        }
        
        try statement.run(bindings)
        logger.log("Statement run successfully.")
        return QueryResult(changes: db.totalChanges)
    }
    
    func query(_ query: String?, args: InternalsdkValueArrayProtocol?) throws -> InternalsdkRowsProtocol {
        logger.log("query() method called with query: \(query ?? "nil")")
        let statement = try db.prepare(query!)
        if let transaction = currentTransaction {
            transaction.addStatement(statement)
        }
        return RowData(rows: Array(_immutableCocoaArray: statement))
    }
    
}

class TransactionManager: NSObject, InternalsdkTxProtocol {
    let database: Connection
    var statements: [Statement] = []
    
    init(database: Connection) {
        self.database = database
    }
    
    func addStatement(_ statement: Statement) {
        statements.append(statement)
    }
    
    func commit() throws {
        try database.transaction {
            for statement in statements {
                try statement.run()
            }
        }
        statements = []
    }
    
    func rollback() throws {
        //try database.rollback()
        statements = []
    }
    
    func exec(_ query: String?, args: InternalsdkValueArrayProtocol?) throws -> InternalsdkResultProtocol {
        guard let query = query, let args = args else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let bindings = ValueUtil.toBindingsArray(args)
        let statement = try database.prepare(query)
        statements.append(statement)
        
        try statement.run(bindings)
        return QueryResult(changes: database.totalChanges)
    }
    
    func query(_ query: String?, args: InternalsdkValueArrayProtocol?) throws -> InternalsdkRowsProtocol {
        guard let query = query, let args = args else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        
        let bindings = ValueUtil.toBindingsArray(args)
        let statement = try database.prepare(query)
        statements.append(statement)
        
        try statement.run(bindings)
        return RowData(rows: Array(_immutableCocoaArray: statement))
    }
}

class QueryResult: NSObject, InternalsdkResultProtocol {
    
    let changes: Int
    
    init(changes: Int) {
        self.changes = changes
    }
    
    func lastInsertId(_ ret0_: UnsafeMutablePointer<Int64>?) throws -> Void {
        ret0_?.pointee = Int64(changes)
    }
    
    func rowsAffected(_ ret0_: UnsafeMutablePointer<Int64>?) throws -> Void {
        ret0_?.pointee = Int64(changes)
    }
}

class RowData: NSObject, InternalsdkRowsProtocol {
    let rows: [Row]
    
    init(rows: [Row]) {
        self.rows = rows
    }
    
    func close() throws {
        // Not sure what to put here
    }
    
    func next() -> Bool {
        return !rows.isEmpty
    }
    
    func scan(_ dest: InternalsdkValueArrayProtocol?) throws {
        // SQLite.swift does not provide a way to "scan" rows. You need to directly access row values
        
    }
}

class ValueArrayHandler: NSObject, InternalsdkValueArrayProtocol {
    
    var values: [InternalsdkValue]
    
    init(values: [InternalsdkValue]) {
        logger.log("SwiftValueArray called init \(values)")
        self.values = values
    }
    
    
    func get(_ index: Int) -> InternalsdkValue? {
        logger.log("SwiftValueArray get called \(values[index])")
        return values[index]
    }
    
    func set(_ index: Int, value: InternalsdkValue?) {
        logger.log("SwiftValueArray set called \(index)")
        values[index]=value!
    }
    
    
    func len() -> Int {
        logger.log("SwiftValueArray len called")
        return values.count
    }
}
