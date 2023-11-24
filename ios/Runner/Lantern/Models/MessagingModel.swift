//
//  MessagingModel.swift
//  Runner
//
//  Created by jigar fumakiya on 21/08/23.
//

import DBModule
import Flutter
import Foundation
import Internalsdk

class MessagingModel: BaseModel<InternalsdkMessagingModel> {
  init(flutterBinary: FlutterBinaryMessenger) throws {
    var error: NSError?
    guard
      let model = InternalsdkNewMessagingModel(
        try BaseModel<InternalsdkModelProtocol>.getDB(), &error)
    else {
      throw error!
    }
    try super.init(flutterBinary, model)
  }
}
