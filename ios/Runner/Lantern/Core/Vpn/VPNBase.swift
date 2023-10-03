//
//  VPNManagerType.swift
//  Lantern
//

import NetworkExtension

protocol VPNBase: AnyObject {
    var connectionStatus: NEVPNStatus { get }
    var didUpdateConnectionStatusCallback: ((NEVPNStatus) -> Void)? { get set }
    func startTunnel(completion: @escaping (Result<Void, VPNManagerError>) -> Void)
    func stopTunnel()
    func messageNetEx(messageData: Data, responseHandler: ((Data?) -> Void)?) throws
}
