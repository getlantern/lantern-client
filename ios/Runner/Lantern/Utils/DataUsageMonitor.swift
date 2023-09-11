//
//  DataUsageMonitor.swift
//  Lantern
//

import Foundation

// TODO: add interface for mockability
class DataUsageMonitor {
    typealias DataUsage = (current: Int, cap: Int)

    // MARK: Public Properties

    var dataCapIsPresent: Bool {
        return dataUsage != nil
    }

    var dataCapReached: Bool {
        guard let usage = dataUsage else { return false }
        return usage.current >= usage.cap
    }
    

    var dataUsage: DataUsage? {
        guard
            let comps = dataUsageStringValue?.components(separatedBy: "/"),
            let current = Int(comps.first ?? ""),
            let cap = Int(comps.last ?? "")
            else { return nil }
        return (current, cap)
    }

    var dataUsageStringValue: String? {
        guard let string = try? String(contentsOf: quotaURL), !string.isEmpty else { return nil }
        return string
    }

    // MARK: Init

    private let quotaURL: URL
    private var fileMonitor: FileWriteMonitor?

    init(quotaURL: URL) {
        self.quotaURL = quotaURL
    }

    func startObservingDataUsageChanges(callback: @escaping (() -> Void)) {
        guard fileMonitor == nil else {
            fatalError("Cannot start observing another file when already observing.")
        }
        fileMonitor = FileWriteMonitor(withFilePath: quotaURL.path,callback: callback)
        assert(fileMonitor != nil)
        fileMonitor?.startObservingFileChanges()
    }
}

// Currently hidden & hard-coded for 'write' events, can abstract if necessary.
private class FileWriteMonitor {

    private let filePath: String
    private let fileSystemEvent: DispatchSource.FileSystemEvent
    private let dispatchQueue: DispatchQueue
    private var eventSource: DispatchSourceFileSystemObject?
    public var onFileEvent: (() -> Void)? {
        willSet {
            self.eventSource?.cancel()
        }
        didSet {
            if (onFileEvent != nil) {
                self.startObservingFileChanges()
            }
        }
    }

    public init?(withFilePath path: String,
                 observeEvent event: DispatchSource.FileSystemEvent = .write,
                 queue: DispatchQueue = DispatchQueue.global(),
                 callback: @escaping () -> Void) {
        filePath = path
        fileSystemEvent = event
        dispatchQueue = queue
        onFileEvent = callback
        if !fileExists {
            assertionFailure(String(format: "Started monitoring a file that doesn't exist yet: %@", path	))
            return nil
        }
    }

    deinit {
        self.eventSource?.cancel()
    }

    private var fileExists: Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }

    private func createFile() {
        if !fileExists {
            FileManager.default.createFile(atPath: self.filePath, contents: nil, attributes: nil)
        }
    }

    func startObservingFileChanges() {
        guard fileExists else {
            assertionFailure("Attempted to observe changes on a non-existant file")
            return
        }
        let descriptor = open(self.filePath, O_EVTONLY)
        guard descriptor != -1 else {
            assertionFailure("Failed to get valid descriptor when observing file")
            return
        }
        eventSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: descriptor,  eventMask: fileSystemEvent,  queue: dispatchQueue)
        eventSource?.setEventHandler { [weak self] in
            self?.onFileEvent?()
        }
        eventSource?.setCancelHandler() {
            close(descriptor)
        }
        eventSource?.resume()
    }
}

