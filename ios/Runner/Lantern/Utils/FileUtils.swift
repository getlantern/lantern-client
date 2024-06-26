//
//  FileManager+FileCreation.swift
//  Lantern
//

import Foundation

// Extension exists because we need to do this exact process 3 times:
// 1. For Go Logging
// 2. For iOS Logging
// 3. For Configs
// Function signatures match the core functionality of FileManager.
extension FileManager {

  func ensureDirectoryExists(at url: URL) throws {
    if !fileExists(atPath: url.path, isDirectory: nil) {
      try createDirectory(
        at: url,
        withIntermediateDirectories: false,
        attributes: nil)
    }
  }

  @discardableResult func ensureFilesExist(at urls: [URL]) -> Bool {
    var overallSuccess = true
    //    // Make sure ICloud does not backdup all file
    //    var values = URLResourceValues()
    //    values.isExcludedFromBackup = true

    urls.forEach { url in
      //      url.setResourceValues(values)
      let path = url.path
      if !fileExists(atPath: path) {
        // posix permission 666 is `rw-rw-rw` aka read/write for all
        let rwAllPermission = 0o666 as Int16
        let success = createFile(
          atPath: path, contents: nil, attributes: [.posixPermissions: rwAllPermission])
        if !success { overallSuccess = false }
      }
    }
    return overallSuccess
  }

  func generateLogRotationURLs(count: Int, from baseURL: URL) -> [URL] {
    var urls = [baseURL]
    guard count > 1 else { return urls }
    // make `<baseURL>.log.1` up to X
    for i in 1...count { urls.append(baseURL.appendingPathExtension("\(i)")) }
    return urls
  }
}
