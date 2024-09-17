//
//  DB.swift
//  Runner
//
//  Created by jigar fumakiya on 28/07/23.
//

import Foundation
import Internalsdk
import SQLite

public class DatabaseManager: NSObject, MinisqlDBProtocol, MinisqlTxProtocol {
  private let path: String
  private let connection: Connection
  private let transactional: Bool
  private var currentTransaction: DatabaseManager?
  private var savepointName: String?

  public init(_ path: String, connection: Connection? = nil, transactional: Bool = false) throws {
    self.path = path
    if let conn = connection {
      self.connection = conn
    } else {
      guard !path.isEmpty else {
        throw NSError(
          domain: "DatabasePathError", code: 1,
          userInfo: [NSLocalizedDescriptionKey: "Database path cannot be blank"])
      }
      let conn = try! Connection(path)
      try conn.execute("PRAGMA journal_mode=WAL")
      try conn.execute("PRAGMA busy_timeout=5000")
      self.connection = conn
    }
    self.transactional = transactional
  }

  public func begin() throws -> MinisqlTxProtocol {
    currentTransaction = try DatabaseManager(path, connection: connection, transactional: true)
    return currentTransaction!
  }

  public func commit() throws {
    do {
      if let savepointName = savepointName {
        try connection.run("RELEASE '\(savepointName)'")
      }
      savepointName = nil
    } catch {
      print("Failed to commit: \(error)")
    }

  }

  public func rollback() throws {
    if let savepointName = savepointName {
      try connection.run("ROLLBACK TO SAVEPOINT '\(savepointName)'")
      try connection.run("RELEASE '\(savepointName)'")
    }
    savepointName = nil
  }

  public func close() throws {
    // Automatically manages the database connections
  }

  private func beginTransaction() throws {
    savepointName = "Savepoint\(UUID().uuidString)"
    if let savepointName = savepointName {
      try connection.run("SAVEPOINT '\(savepointName)'")
    }
  }

  public func exec(_ query: String?, args: MinisqlValuesProtocol?) throws {
    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }

    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try connection.prepare(query)
    // Start a transaction if none has been started yet
    if transactional && savepointName == nil {
      try beginTransaction()
    }

    try runStatement(statement, bindings)
  }

  public func query(_ query: String?, args: MinisqlValuesProtocol?) throws -> MinisqlRowsProtocol {
    guard let query = query, let args = args else {
      throw NSError(
        domain: "ArgumentError", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Query or arguments are nil"])
    }

    let bindings = ValueUtil.toBindingsArray(args)
    let statement = try connection.prepare(query)
    // Start a transaction if none has been started yet
    if transactional && savepointName == nil {
      try beginTransaction()
    }

    var rows: [Statement.Element] = []

    for row in try runStatement(statement, bindings) {
      rows.append(row)
    }

    return RowData(rows: rows)
  }

  func runStatement(_ statement: Statement, _ bindings: [Binding?]) throws -> Statement {
    do {
      return try statement.run(bindings)
    } catch let SQLite.Result.error(message, code, _) {
      throw NSError(domain: message, code: Int(code), userInfo: nil)
    } catch let error {
      throw NSError(domain: String(describing: error), code: 0, userInfo: nil)
    }
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
        if value != nil {
          ValueUtil.setValueFromBinding(binding: value!, value: miniSqlValue)
        }
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
      return nil
    }
    return values[index]
  }

  func len() -> Int {
    return values.count
  }

  func set(_ index: Int, value: MinisqlValue?) {
    guard index < values.count else {
      return
    }

    guard let value = value else {
      return
    }

    values[index] = value
  }
}
