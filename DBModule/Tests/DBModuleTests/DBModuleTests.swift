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

  func testTransactions() throws {
    let db = try newDB()
    TestsupportTestTransactions(self, db)
  }

  func testSubscriptions() throws {
    let db = try newDB()
    TestsupportTestSubscriptions(self, db)
  }

  func testSubscribeToInitialDetails() throws {
    let db = try newDB()
    TestsupportTestSubscribeToInitialDetails(self, db)
  }

  func testDetailSubscriptionModifyDetails() throws {
    let db = try newDB()
    TestsupportTestDetailSubscriptionModifyDetails(self, db)
  }

  func testDetailSubscriptionModifyIndex() throws {
    let db = try newDB()
    TestsupportTestDetailSubscriptionModifyIndex(self, db)
  }

  func testList() throws {
    let db = try newDB()
    TestsupportTestList(self, db)
  }

  func testSearch() throws {
    let db = try newDB()
    TestsupportTestSearch(self, db)
  }

  func testSearchChinese() throws {
    let db = try newDB()
    TestsupportTestSearchChinese(self, db)
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
