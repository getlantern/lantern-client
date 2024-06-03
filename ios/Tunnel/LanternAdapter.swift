import Foundation
import NetworkExtension

public class LanternAdapter {
  public typealias LogHandler = (String) -> Void

  /// Packet tunnel provider.
  private weak var packetTunnelProvider: NEPacketTunnelProvider?

  /// Log handler closure.
  private let logHandler: LogHandler

  /// - Parameter packetTunnelProvider: an instance of `NEPacketTunnelProvider`. Internally stored
  ///   as a weak reference.
  /// - Parameter logHandler: a log handler closure.
  public init(with packetTunnelProvider: NEPacketTunnelProvider, logHandler: @escaping LogHandler) {
    self.packetTunnelProvider = packetTunnelProvider
    self.logHandler = logHandler
  }

  /// Tunnel device file descriptor.
  public var tunnelFileDescriptor: Int32 {
    return self.packetTunnelProvider?.packetFlow.value(forKeyPath: "socket.fileDescriptor")
      as! Int32
  }
}
