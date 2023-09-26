//
//  DB.swift
//  Runner
//
//  Created by jigar fumakiya on 28/07/23.
//

import Foundation
import Internalsdk
import SQLite

public struct DatabaseFactory {
  public static func getDbManager(databasePath: String) throws -> MinisqlDBProtocol {
    guard !databasePath.isEmpty else {
      throw NSError(
        domain: "DatabasePathError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Database path cannot be blank"])
    }
    let connection = try! Connection(databasePath)
    return DatabaseManager(database: connection)
  }
}

class DatabaseManager: NSObject, MinisqlDBProtocol {
  private let db: Connection
  private var currentTransaction: TransactionManager?

  init(database: Connection) {
    self.db = database
  }

  // Static function to get an instance of DatabaseManager
  // Expose to Client
  static func getDbManager(databasePath: String) throws -> MinisqlDBProtocol {
    guard !databasePath.isEmpty else {
      throw NSError(
        domain: "DatabasePathError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Database path cannot be blank"])
    }
    let connection = try! Connection(databasePath)
    return DatabaseManager(database: connection)
  }

  public func begin() throws -> MinisqlTxProtocol {
    currentTransaction = TransactionManager(database: db)
    return currentTransaction!
  }

  public func close() throws {
    //Automatically manages the database connections
  }

  public func exec(_ query: String?, args: MinisqlValuesProtocol?) throws -> MinisqlResultProtocol {
    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }
    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try db.prepare(query)

    try statement.run(bindings)
    return QueryResult(changes: db.changes)
  }

  public func query(_ query: String?, args: MinisqlValuesProtocol?) throws -> MinisqlRowsProtocol {

    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }

    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try db.prepare(query)

    var rows: [Statement.Element] = []

    try statement.run(bindings).forEach { row in
      rows.append(row)
    }
    return RowData(rows: rows)
  }
}

class TransactionManager: NSObject, MinisqlTxProtocol {
  let database: Connection
  private var savepointName: String?

  init(database: Connection) {
    self.database = database
  }

  private func begin() throws {
    print("BEGIN TX")
    savepointName = "Savepoint\(UUID().uuidString)"
    if let savepointName = savepointName {
      try database.run("SAVEPOINT '\(savepointName)'")
    }
  }

  func commit() throws {
    print("COMMIT TX")
    if let savepointName = savepointName {
      print("RELEASING SAVEPOINT")
      try database.run("RELEASE '\(savepointName)'")
    }
    savepointName = nil
    print("CHANGES '\(database.changes)'")
  }

  func rollback() throws {
    if let savepointName = savepointName {
      try database.run("ROLLBACK TO SAVEPOINT '\(savepointName)'")
      try database.run("RELEASE '\(savepointName)'")
    }
    savepointName = nil
  }

  func exec(_ query: String?, args: MinisqlValuesProtocol?) throws -> MinisqlResultProtocol {
    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }

    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try database.prepare(query)
    // Start a transaction if none has been started yet
    if savepointName == nil {
      try begin()
    }

    try statement.run(bindings)
    return QueryResult(changes: database.changes)
  }

  func query(_ query: String?, args: MinisqlValuesProtocol?) throws -> MinisqlRowsProtocol {
    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }

    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try database.prepare(query)
    // Start a transaction if none has been started yet
    if savepointName == nil {
      try begin()
    }

    var rows: [Statement.Element] = []

    for row in try statement.run(bindings) {
      rows.append(row)
    }

    return RowData(rows: rows)
  }
}

class QueryResult: NSObject, MinisqlResultProtocol {

  let changes: Int

  init(changes: Int) {
    self.changes = changes
  }

  func lastInsertId(_ ret0_: UnsafeMutablePointer<Int64>?) throws {
    ret0_?.pointee = Int64(changes)
  }

  func rowsAffected(_ ret0_: UnsafeMutablePointer<Int64>?) throws {
    ret0_?.pointee = Int64(changes)
  }
}

class RowData: NSObject, MinisqlRowsProtocol {
  let rows: [Statement.Element]
  var currentIndex: Int = -1
  private let syncQueue = DispatchQueue(label: "com.lantern.RowData.syncQueue")

  init(rows: [Statement.Element]) {
    self.rows = rows
  }

  func close() throws {
    // Not sure what to put here
  }

  func next() -> Bool {
    currentIndex += 1
    return currentIndex < rows.count
  }

  /**
     This method scans the current row and converts its values to `MinisqlValue` objects.
     This method assumes that `values` is an object that supports setting values by index, and `rows` is an array of arrays where each inner array represents a row from a database and contains values of type `Binding`.
     - Parameter values: An object that conforms to `MinisqlValuesProtocol`. This object will be populated with the values from the current row, converted to `MinisqlValue` objects.
     - Throws: An `NSError` if `values` is `nil` or if `currentIndex` is outside the bounds of the `rows` array.
     - Note: This method updates `currentIndex` to point to the next row. If there are no more rows, `next()` will return `false`.
     */
  func scan(_ values: MinisqlValuesProtocol?) throws {
    try syncQueue.sync {
      if values == nil {
        throw NSError(
          domain: "Scan method failed", code: 0,
          userInfo: [NSLocalizedDescriptionKey: "Values object is nil"])
      }
      if currentIndex >= rows.count {
        throw NSError(
          domain: "Scan method failed", code: 0,
          userInfo: [NSLocalizedDescriptionKey: "Current index is out of bounds"])
      }
      let currentRow = rows[currentIndex]
      for (index, value) in currentRow.enumerated() {
        let miniSqlValue = values!.get(index)!
        ValueUtil.setValueFromBinding(binding: value!, value: miniSqlValue)
      }
    }
  }
}

public struct ValueArrayFactory {
  public static func createValueArrayHandler(values: [MinisqlValue]) -> MinisqlValuesProtocol {
    return ValueArrayHandler(values: values)
  }
}

class ValueArrayHandler: NSObject, MinisqlValuesProtocol {

  var values: [MinisqlValue]

  init(values: [MinisqlValue]) {
    self.values = values
  }

  public func get(_ index: Int) -> MinisqlValue? {
    guard index < values.count else {
      print("Error: Index out of bounds while trying to get value.")
      return nil
    }
    return values[index]
  }

  func len() -> Int {
    return values.count
  }

  func set(_ index: Int, value: MinisqlValue?) {
    guard index < values.count else {
      print("Error: Index out of bounds while trying to set value.")
      return
    }

    guard let value = value else {
      print("Error: Attempted to set nil value.")
      return
    }

    values[index] = value
  }
}
extension Date {
  static var currentTimeStamp: Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }
}
