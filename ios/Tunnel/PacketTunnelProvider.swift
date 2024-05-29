//
//  PacketTunnelProvider.swift
//  tunnel
//

import Internalsdk
import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {

  // MARK: Dependencies
  let fileManager = FileManager.default
  let constants = Constants(process: .netEx)
  lazy var notificationsManager: UserNotificationsManager = {
    return UserNotificationsManager()
  }()
  let flashlightManager: FlashlightManager = .netExDefault

  // MARK: PacketFlow
  let tunIP = "10.66.66.1"
  let mtu = 1500
  var client: IosClientWriterProtocol?
  var bytesRead: Int = 0
  var bytesWritten: Int = 0

  // MARK: NEPacketTunnelProvider

  override func startTunnel(
    options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void
  ) {
    // this is our first life-cycle event; perform set up
    logMemoryUsage(tag: "Before starting flashlight")
    increaseFileLimit()
    createFilesForNetExGoPackage()
    let logError = flashlightManager.configureGoLoggerReturningError()
    if let error = logError {
      logger.error(error.localizedDescription)
      // crash the tunnel?
    }
    // we have no way to discern if the User toggled VPN on in Settings :(
    let reason = (options?[Constants.netExStartReasonKey] as? NSString) ?? "'On Demand'/Settings"
    logger.debug("startTunnel with reason: \(reason)")

    let settings = generateTunnelNetworkSettings()
    setTunnelNetworkSettings(settings) { error in
      guard error == nil else {
        logger.error(error!.localizedDescription)
        completionHandler(error)
        return
      }
      self.startFlashlight(completionHandler)
    }
  }

  override func stopTunnel(
    with reason: NEProviderStopReason, completionHandler: @escaping () -> Void
  ) {
    logger.debug("stopTunnel with reason: \(reason.debugString)")
    stopFlashlight()
    completionHandler()
  }

  // MARK: NETunnelProvider

  override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
    switch messageData {

    case Constants.configUpdatedMessageData:
      logger.debug("Received app message that config has updated. Generating new tunnel settings.")
      // Regenerate and set network settings so TUN device has correct excluded routes
      let newSettings = generateTunnelNetworkSettings()
      setTunnelNetworkSettings(newSettings) { error in
        if let err = error {
          logger.error("Updating TUN excluded routes - \(err.localizedDescription)")
        } else {
          logger.debug("Updating TUN excluded routes - Success!")
        }
        completionHandler?((error == nil) ? Constants.configUpdatedACKData : nil)
      }

      self.client?.reconfigure()

    case Constants.requestReadWriteCountMessageData:
      logger.debug("Received app message requesting count of bytes read/written.")
      // report back with bytes written/read
      let string = "\(bytesWritten)/\(bytesRead)"
      let data = string.data(using: .utf8)!
      completionHandler?(data)

    default:
      // unrecognized message, log error
      let string = String(bytes: messageData, encoding: .utf8) ?? "<encoding failed>"
      logger.error("\(#function) called with unknown data: \(string)")
      completionHandler?(nil)
    }
  }

  // MARK: NEProvider

  override func sleep(completionHandler: @escaping () -> Void) {
    logger.debug("Device going to sleep")
    completionHandler()
  }

  override func wake() {
    logger.debug("Device woke")
  }
}

extension PacketTunnelProvider {

  // MARK: Start/Stop Flashlight

  func startFlashlight(_ completionHandler: @escaping (Error?) -> Void) {
    flashlightManager.queue.async { [weak self] in
      guard let welf = self else { return }

      // init IosClient, which is just a Swift abstraction for Flashlight
      var error: NSError?
      welf.client = IosClient(
        welf, UDPDialer(), MemChecker(), welf.constants.configDirectoryURL.path, welf.mtu,
        Constants.capturedDNSHost, Constants.realDNSHost, StatsTracker(), &error)

      if let err = error {
        logger.error(err.localizedDescription)
      } else {
        logger.debug("Flashlight started without error.")
      }

      logMemoryUsage(tag: "After starting flashlight")

      // complete to signal to system we are g2g or have failed
      completionHandler(error)

      if error == nil {
        // if we're all set, kick off the reading and writing
        welf.packetFlow.readPacketObjects(completionHandler: welf.onPacket)
      }
    }
  }

  func stopFlashlight() {
    do {
      try client?.close()
    } catch let error {
      logger.error(#function + error.localizedDescription)
    }
  }
}

// IosWriterProtocol is a Swift abstraction for Flashlight, made by gomobile
// and embedded with Ios.xcframework
// The original location in Go code is
// github.com/getlantern/flashlight/ios/ios.go:Writer interface
extension PacketTunnelProvider: IosWriterProtocol {

  // MARK: PacketFlow Read/Write Callbacks

  func write(_ p0: Data?) -> Bool {
    bytesWritten += p0?.count ?? 0
    return self.packetFlow.writePackets([p0!], withProtocols: [AF_INET as NSNumber])
  }

  func onPacket(packets: [NEPacket]) {
    flashlightManager.queue.async { [weak self] in
      var dataCap = 0
      var readTotal = packets.reduce(0, { $0 + $1.data.count })  // get packet byte total

      packets.forEach { packet in
        do {
          try self?.client?.write(packet.data, ret0_: &dataCap)
        } catch let error {
          logger.error(#function + error.localizedDescription)
          readTotal -= packet.data.count  // remove bytes from read count
        }
      }
      if let welf = self {
        welf.packetFlow.readPacketObjects(completionHandler: welf.onPacket)
      }

      self?.bytesRead += readTotal
      if dataCap > 0 {
        self?.notificationsManager.scheduleDataCapLocalNotification(withDataLimit: dataCap)
        //^ internally handles permission, "once a month" notification limit
      }
    }
  }
}

extension PacketTunnelProvider {

  // MARK: Tunnel Settings
  func generateTunnelNetworkSettings() -> NETunnelNetworkSettings {
    let remoteAddress = "0.0.0.0"  // display use only
    let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: remoteAddress)

    let dnsServerStrings = [Constants.capturedDNSHost]
    let dnsSettings = NEDNSSettings(servers: dnsServerStrings)
    dnsSettings.matchDomains = [""]  // makes all DNS queries first go through the tunnel's DNS
    networkSettings.dnsSettings = dnsSettings

    networkSettings.mtu = NSNumber(value: mtu)

    let ipv4Settings = NEIPv4Settings(addresses: [tunIP], subnetMasks: ["255.255.224.0"])
    ipv4Settings.includedRoutes = [
      NEIPv4Route(destinationAddress: "0.0.0.0", subnetMask: "0.0.0.0")
    ]
    networkSettings.ipv4Settings = ipv4Settings
    networkSettings.ipv4Settings?.excludedRoutes = loadExcludedRoutes()

    return networkSettings
  }

  private func loadExcludedRoutes() -> [NEIPv4Route] {
    // Loads excluded routes from disk, written by app side
    var routes = [
      NEIPv4Route(destinationAddress: Constants.realDNSHost, subnetMask: "255.255.255.255")
    ]  // dns
    routes.append(NEIPv4Route(destinationAddress: "127.0.0.1", subnetMask: "255.255.255.255"))  // local servers like dnsgrab

    // see FlashlightManager+FetchConfig.swift for how String is being saved
    do {
      let ipsString = try String(contentsOf: constants.excludedIPsURL, encoding: .utf8)
      logger.debug("Excluding \(ipsString)")
      let ips = ipsString.components(separatedBy: ",")

      ips.forEach { address in
        routes.append(NEIPv4Route(destinationAddress: address, subnetMask: "255.255.255.255"))
      }
    } catch {
      logger.error(
        "Loading excluded routes failed, killing tunnel process: \(error.localizedDescription)")
      stopTunnel(with: .configurationFailed, completionHandler: {})
    }

    return routes
  }
}

extension PacketTunnelProvider {
  // MARK: File Management

  private func createFilesForNetExGoPackage() {
    // where "~" is the shared app group container...

    // create process-specific directory @ ~/netEx
    do {
      try fileManager.ensureDirectoryExists(at: constants.targetDirectoryURL)
    } catch {
      logger.error("failed to create directory @ \(constants.targetDirectoryURL.path)")
    }

    // create process-specific log files @ ~/netEx/lantern.log.#
    let logURLs = fileManager.generateLogRotationURLs(
      count: Constants.defaultLogRotationFileCount, from: constants.goLogBaseURL)
    let success = fileManager.ensureFilesExist(at: logURLs)
    if !success {
      logger.error("Failed to create log URLs")
    }
  }
}

// MARK: File Limits
extension PacketTunnelProvider {
  // I've noticed occassional dial errors saying "unable to assign requested address" followed by a crash, which might be due to running out of file descriptors
  func increaseFileLimit() {
    var limits = rlimit()

    guard getrlimit(RLIMIT_NOFILE, &limits) != -1 else {
      logger.error("Problem with rlimit")
      return
    }

    logger.debug("File descriptor limit current: \(limits.rlim_cur) max: \(limits.rlim_max)")

    limits.rlim_cur = 16384
    if setrlimit(RLIMIT_NOFILE, &limits) == -1 {
      logger.error("Problem updating rlimit")
    }
  }
}

// MARK: Logging Memory Usage
class MemChecker: NSObject, IosMemCheckerProtocol {
  func bytesRemain() -> Int {
    return getBytesRemain()
  }
}

func getBytesRemain() -> Int {
  var info = task_vm_info_data_t()
  var infoCount = TASK_VM_INFO_COUNT

  let kerr = withUnsafeMutablePointer(to: &info) {
    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
      task_info(mach_task_self_, thread_flavor_t(TASK_VM_INFO), $0, &infoCount)
    }
  }
  guard kerr == KERN_SUCCESS else {
    logger.error("\(#function) - Attempt to read memory usage unsuccessful")
    return 0
  }

  // It's important that this value aligns closely to what iOS monitors to enforce the 15MB memory limit for network extensions,
  // because we use this number to tell if we're getting close to the limit and start taking remedial action.
  // Per the below discussion, phys_footprint is a good value to use, and from our own observations it looks like
  // limit_bytes_remaining is a good indicator of how close we are to hitting the limit.
  //
  // https://developer.apple.com/forums/thread/97636
  //
  // Note that the way that Go frees memory to the OS doesn't always play well with memory usage reporting, but per the below discussion
  // and from our testing, using task_vm_info should work okay.
  //
  // https://github.com/golang/go/issues/29844
  //
  return Int(info.limit_bytes_remaining)
}

func logMemoryUsage(tag: String? = nil, bytesRemain: Int? = nil) {
  let remain = bytesRemain ?? getBytesRemain()

  var format = "stats Memory Remaining"
  if let actualTag = tag {
    format = format + ": " + actualTag
  }
  format = format + ": %d bytes"
  let string = String(format: format, remain)
  logger.debug(string)
}

// used for logging memory usage
// based on https://gist.github.com/nh7a/70832fa2658b591dca22e4606388a07f
private let TASK_VM_INFO_COUNT = mach_msg_type_number_t(
  MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<UInt32>.size)
