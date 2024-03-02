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
	private var sessionModel: InternalsdkSessionModel
	private var settings: Settings = Settings()
	private var vpnModel: VpnModel

	init(sessionModel: InternalsdkSessionModel, vpnModel: VpnModel) {
		self.sessionModel = sessionModel
		self.vpnModel = vpnModel
	}

	func start() {
	  self.sessionModel.startService(Constants.lanternDirectory.path, locale: "en", settings: self.settings)
	}
}
