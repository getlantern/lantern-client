//
//  NetworkMoniter.swift
//  Runner
//
//  Created by jigar fumakiya on 07/12/23.
//
import Network


class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor

    var isConnected: Bool {
        return monitor.currentPath.status == .satisfied
    }

    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                logger.debug("We have internet connection")
                // Do something when network is connected
            } else {
                logger.debug("No internet connection")
                // Do something when network is disconnected
            }
        }
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}
