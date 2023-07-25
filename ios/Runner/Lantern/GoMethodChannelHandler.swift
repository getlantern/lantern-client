////
////  GoMethodChannelHandler.swift
////  Runner
////
////  Created by jigar fumakiya on 21/07/23.
////
//
//import Foundation
//import Internalsdk
//
//enum FlutterMethodChannelError: Error {
//    case goError(NSError)
//}
//
//let goMethodChannelHandler = GoMethodChannelHandler()
//
//class GoMethodChannelHandler {
//    private let channel =
//
//    func invokeMethod(name: String, argument: String) throws -> String {
//        var error: NSError?
//        let result = channel.invokeMethod(name, argument: argument, error: &error)
//        if let error = error {
//            throw FlutterMethodChannelError.goError(error)
//        }
//        return result
//    }
//}
