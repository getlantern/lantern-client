import Internalsdk
import XCTest

@testable import DBModule

final class DBModuleTests: XCTestCase, TestsupportTestingTProtocol {
  func errorf(_ text: String?) {
    XCTFail(text!)
  }

  func failNow() {
    XCTFail("failing now!")
  }

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

//   func testList() throws {
//     let db = try newDB()
//     TestsupportTestList(self, db)
//   }

  func testTransactions() throws {
    let db = try newDB()
    TestsupportTestTransactions(self, db)
  }

  private func newDB() throws -> MinisqlDBProtocol {
    return try DatabaseFactory.getDbManager(databasePath: newDBPath())
  }

  private func newDBPath() -> String {
    let fileManager = FileManager.default
    let directory = fileManager.temporaryDirectory
    let subdirectory = UUID().uuidString
    let dbDir = directory.appendingPathComponent(subdirectory)

    do {
      try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true, attributes: nil)
      let dbLocation = dbDir.appendingPathComponent("db").path
      return dbLocation
    } catch {
      return ""  // Return an empty string or handle the error accordingly.
    }
  }
}
