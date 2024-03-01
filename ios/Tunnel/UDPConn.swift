//
//  udpconn.swift
//  Tunnel
//
//  Created by Ox Cart on 11/20/20.
//  Copyright © 2020 Innovate Labs. All rights reserved.
//

import Foundation
import Internalsdk
import Network

/// UDPDialer provides a mechanism for dialing outbound UDP connections that bypass the VPN.
class UDPDialer: NSObject, IosUDPDialerProtocol {
  /// Dials the given host and port. In practice, nothing actually happens until IosUDPCallbacks get registered on the returned UDPConn.
  func dial(_ host: String?, port: Int) -> IosUDPConnProtocol? {
    return UDPConn(host: NWEndpoint.Host(host!), port: NWEndpoint.Port(rawValue: UInt16(port))!)
  }
}

/// Encapsulates a UDP connection to a specific host and port.
class UDPConn: NSObject, IosUDPConnProtocol {
  var connection: NWConnection
  var cb: IosUDPCallbacks?

  init(host: NWEndpoint.Host, port: NWEndpoint.Port) {
    self.connection = NWConnection(host: host, port: port, using: .udp)
    super.init()
  }

  func register(_ cb: IosUDPCallbacks?) {
    self.cb = cb

    self.connection.stateUpdateHandler = { (newState) in
      switch newState {
      case .ready:
        cb?.onDialSucceeded()
      case .failed(let error):
        cb?.onError(error)
      case .cancelled:
        cb?.onClose()
      default:
        break
      }
    }

    connection.start(queue: .global())
  }

  func writeDatagram(_ data: Data?) {
    self.connection.send(
      content: data,
      completion: NWConnection.SendCompletion.contentProcessed({ [weak self] error in
        if let error = error {
          self?.cb?.onError(error)
          return
        }

        self?.cb?.onWritten()
      }))
  }

  func receiveDatagram() {
    self.connection.receiveMessage { [weak self] (data, _, _, error) in
      if let error = error {
        self?.cb?.onError(error)
        return
      }

      self?.cb?.onReceive(data)
    }
  }

  func close() {
    self.connection.cancel()
  }
}
