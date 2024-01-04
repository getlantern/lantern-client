//
//  MockVPNManager.swift
//  Lantern
//

import Foundation
import NetworkExtension

// Mostly for testing UI on simulator;
// Calls within actual VPNManager will crash on simulator.
class MockVPNManager: VPNBase {

  var connectionStatus: NEVPNStatus = .disconnected {
    didSet {
      guard oldValue != connectionStatus else { return }
      didUpdateConnectionStatusCallback?(connectionStatus)
    }
  }
  var didUpdateConnectionStatusCallback: ((NEVPNStatus) -> Void)?

  // MARK: Start/Stop Tunnel

  var startTunnelError: VPNManagerError?

  func startTunnel(completion: (Result<Void, VPNManagerError>) -> Void) {
    connectionStatus = .connected
    completion(startTunnelError == nil ? .success(()) : .failure(startTunnelError!))
  }

  func stopTunnel() {
    connectionStatus = .disconnected
  }

  // MARK: Message NetEx

  var messageNetExError: VPNManagerError?
  var messageNetExResponseData: Data?

  func messageNetEx(messageData: Data, responseHandler: ((Data?) -> Void)?) throws {
    if let error = messageNetExError {
      throw error
    } else {
      let data = messageNetExResponseData
      DispatchQueue.global().async { responseHandler?(data) }
    }
  }
}
