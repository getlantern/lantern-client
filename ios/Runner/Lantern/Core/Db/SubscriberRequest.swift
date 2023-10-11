//
//  SubscriberRequest.swift
//  Runner
//
//  Created by jigar fumakiya on 25/08/23.
//

import DBModule
import Foundation
import Internalsdk

class DetailsSubscriber: InternalsdkSubscriptionRequest {

  var subscriberID: String
  var path: String
  var updaterDelegate: DetailsSubscriberUpdater

  init(subscriberID: String, path: String, onChanges: @escaping ([String: Any], [String]) -> Void) {
    self.subscriberID = subscriberID
    self.path = path
    self.updaterDelegate = DetailsSubscriberUpdater()
    super.init()
    self.id_ = subscriberID
    self.pathPrefixes = path
    self.receiveInitial = true
    self.updater = updaterDelegate
    updaterDelegate.onChangesCallback = onChanges
  }

}

class DetailsSubscriberUpdater: NSObject, InternalsdkUpdaterModelProtocol {
  var onChangesCallback: (([String: Any], [String]) -> Void)?

  func onChanges(_ cs: InternalsdkChangeSet?) throws {
    guard let cs = cs else {
      throw NSError(
        domain: "onChangesError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ChangeSet is nil"]
      )
    }
    var updatesDictionary: [String: Any] = [:]
    var deletesList: [String] = []

    // Deserialize updates
    while cs.hasUpdate() {
      let update = try cs.popUpdate()
        updatesDictionary[update.path] = ValueUtil.convertFromMinisqlValue(from:update.value!)
    }

    while cs.hasDelete() {
      deletesList.append(cs.popDelete())
    }

    onChangesCallback?(updatesDictionary, deletesList)
  }
}
