//
//  EventManager.swift
//  Runner
//
//  Created by jigar fumakiya on 14/07/23.
//

import Foundation
import Flutter


enum Event: String, CaseIterable {
    case all = "All"
    case surveyAvailable = "SurveyAvailable"
    case noNetworkAvailable = "NoNetworkAvailable"
    case networkAvailable = "NetworkAvailable"
    case noProxyAvailable = "NoProxyAvailable"
    case proxyAvailable = "ProxyAvailable"
}



class EventManager: NSObject, FlutterStreamHandler {
    private let name: String
    private var activeSubscribers: [Event : Set<Int>] = [:]
    private var activeSink: FlutterEventSink?
    private let mainThreadHandler = DispatchQueue.main
    var onListenClosure: (Event) -> Void

    init(name: String, binaryMessenger: FlutterBinaryMessenger ,onListenClosure: @escaping ((Event) -> Void)) {
        self.onListenClosure = onListenClosure
        self.name = name
        super.init()
        let eventChannel = FlutterEventChannel(name: name, binaryMessenger: binaryMessenger)
        eventChannel.setStreamHandler(self)
        
    }
    
    func onNewEvent(event: Event, params: [String : Any] = [:]) {
        var params = params
        mainThreadHandler.async {
            self.activeSubscribers[event]?.forEach { subscriberID in
                params["subscriberID"] = subscriberID
                self.activeSink?(params)
            }
            
            self.activeSubscribers[.all]?.forEach { subscriberID in
                params["subscriberID"] = subscriberID
                self.activeSink?(params)
            }
        }
    }
  

    // MARK: - FlutterStreamHandler
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        activeSink = events
        if let args = arguments as? [String: Any],
            let subscriberID = args["subscriberID"] as? Int,
            let eventName = args["eventName"] as? String,
            let event = Event(rawValue: eventName) {
            
            let subscribers = activeSubscribers[event] ?? []
            activeSubscribers[event] = subscribers.union([subscriberID])
            onListenClosure(event)
        }
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let args = arguments as? [String: Any], let subscriberID = args["subscriberID"] as? Int {
            activeSubscribers.forEach { event, subscriberSet in
                activeSubscribers[event]?.remove(subscriberID)
            }
        }
        return nil
    }
    

}
