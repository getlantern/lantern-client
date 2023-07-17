import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // List of channel and event method names
    let LANTERN_EVENT_CHANNEL="lantern_event_channel"
    
    lazy var flutterEngine = FlutterEngine(name: "LanternIOS")
    var eventManager: EventManager?
    var flutterbinaryMessenger:FlutterBinaryMessenger?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger=controller.binaryMessenger
        prepareChannel()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func prepareChannel (){
        eventManager = EventManager(name: LANTERN_EVENT_CHANNEL, binaryMessenger: flutterbinaryMessenger! ){event in
            print("[IOS App] Lantern Event channel setup $event")
        }
        
    }
    
    
}
