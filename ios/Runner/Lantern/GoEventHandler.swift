//
//  GoEventHandler.swift
//  Runner
//
//  Created by jigar fumakiya on 21/07/23.
//

import Foundation
import Internalsdk

class GoEventHandler:NSObject {
    func onListen(_ arguments: String?, events: InternalsdkEventSinkProtocol?) {
        logger.log("GoEventHandler onListen with \(arguments!)")

    }
    
    func onCancel(_ arguments: String?) {
        logger.log("GoEventHandler with \(arguments!)")
    }
    
    
    
    let goEventHandler = InternalsdkEventChannel("GoHandler")!
    
    
    func setupEventChannel(){
//        goEventHandler.setStreamHandler(self)
        goEventHandler.startSendingEvents()
    }
}
