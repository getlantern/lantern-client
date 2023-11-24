//
//  DnsDetector.swift
//  Runner
//
//  Created by jigar fumakiya on 05/09/23.
//

import Darwin
import Foundation
import NetworkExtension

class DnsDetector {

  // Since IOS does allow to read dns server from Setting
  // So while creating setting we will use this as our Ip so this will become dns server IP
  static let DEFAULT_DNS_SERVER = "8.8.8.8"

}
