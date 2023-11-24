//
//  Events.swift
//  Lantern
//
//  Created by Ox Cart on 9/28/20.
//  Copyright © 2020 Innovate Labs. All rights reserved.
//

import Foundation

struct Events {
  static let configFetchTakingLongTime = Event<Void>()

  static let updateAvailable = Event<Void>()
}
