//
//  SessionModel.swift
//  Runner
//
//  Created by jigar fumakiya on 17/07/23.
//

import Foundation
import Internalsdk
import Flutter

class SessionModel:BaseModel<InternalsdkSessionModel> {
   
    var flutterbinaryMessenger:FlutterBinaryMessenger
 
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init(type: .sessionModel , flutterBinary: self.flutterbinaryMessenger)
        
        
    }

  
    
    func invokeMethodOnGo(name: String, argument: Any) throws -> Any {
        //Convert any argument to Minisql values
        let result = try model.invokeMethod(name, arguments: argument as? MinisqlValuesProtocol)
        return result
    }
    
    
    override func doMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
    }
    
}


