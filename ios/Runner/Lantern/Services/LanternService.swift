//
//  SessionModel.swift
//  Runner
//
//  Created by atavism on 27/02/24.
//

import DBModule
import Foundation
import Internalsdk
import UIKit

class LanternService {
	private var sessionModel: SessionModel
	private var settings: Settings = Settings()
	private var vpnModel: VpnModel

	init(sessionModel: SessionModel, vpnModel: VpnModel) {
		self.sessionModel = sessionModel
		self.vpnModel = vpnModel
	}

	func start() {
      DispatchQueue.global(qos: .userInitiated).async {
        sessionModel.startService(Constants.lanternDirectory.path, locale: "en", settings: settings)
      }
	  //sessionModel.startService(Constants.lanternDirectory.path, locale: "en", settings: settings)
	}
}
