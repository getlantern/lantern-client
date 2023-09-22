//
//  LanternTests.swift
//  LanternTests
//
//  Created by Ox Cart on 9/21/23.
//

import Internalsdk
import SQLite
@testable import Runner
import XCTest

final class TestingT: NSObject, TestsupportTestingTProtocol {
    var test = "unknown"
    
    func errorf(_ text: String?) {
        XCTFail("Test \(test) failed with message \(text)")
    }
    
    func failNow() {
        XCTFail("Test \(test) failed")
    }
}

final class LanternTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testList() throws {
        try TestsupportTestList(TestingT(), getDB())
    }

    private func getDB() throws -> MinisqlDBProtocol {
        let dbPath = getDatabasePath()
        let db = try Connection(dbPath)
        return DatabaseManager(database: db)
    }
            
    private func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let dbDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("masterDBv2")
        do {
            try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true, attributes: nil)
            let dbLocation = dbDir.appendingPathComponent("db").path
            return dbLocation
        } catch {
            print("Error creating directory: \(error)")
            return ""  // Return an empty string or handle the error accordingly.
        }
    }
}
