//
//  SentryUtils.swift
//  Runner
//
//  Created by jigar fumakiya on 20/10/23.
//

import Foundation
import Sentry

class SentryUtils {
  static func startSentry() {
    SentrySDK.start { options in
      options.dsn =
        "https://c14296fdf5a6be272e1ecbdb7cb23f76@o75725.ingest.sentry.io/4506081382694912"
      options.attachScreenshot = true
      options.attachStacktrace = true
      options.debug = true
    }

  }

  static func caputure(error: NSError) {
    SentrySDK.capture(error: error as Error)
  }

}
