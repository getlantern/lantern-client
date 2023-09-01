//
//  VpnModel.swift
//  Runner
//
//  Created by jigar fumakiya on 01/09/23.
//


import Foundation
import Internalsdk
import Flutter


class VpnModel : BaseModel<InternalsdkVpnModel> {
 
    var flutterbinaryMessenger:FlutterBinaryMessenger
 
    init(flutterBinary:FlutterBinaryMessenger) {
        self.flutterbinaryMessenger=flutterBinary
        super.init(type: .vpnModel , flutterBinary: self.flutterbinaryMessenger)
        initializeVpnModel()
    }
    
    func initializeVpnModel()  {
        
    }
    
    
    override func doOnMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
    }
    
}
