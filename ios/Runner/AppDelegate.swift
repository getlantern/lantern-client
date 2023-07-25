import UIKit
import Flutter
import Internalsdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, InternalsdkReceiveStreamProtocol {
    
    
   
    
    
    // List of channel and event method names
    let LANTERN_EVENT_CHANNEL="lantern_event_channel"
    let LANTERN_METHOED_CHANNEL="lantern_method_channel"
    let NAVIGATION_METHOED_CHANNEL="lantern_method_channel"
    
    lazy var flutterEngine = FlutterEngine(name: "LanternIOS")
    var eventManager: EventManager!
    var sessionModel:SessionModel!
    var flutterbinaryMessenger:FlutterBinaryMessenger!
    var lanternMethodChannel:FlutterMethodChannel!
    var navigationChannel:FlutterMethodChannel!
    let goEventHandler = InternalsdkEventChannel( "Gohandler")!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger=controller.binaryMessenger
        prepareChannel()
        setupEventChannel()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func prepareChannel (){
        logger.log("prepareChannel method started")
        
        //Lanter Channles and Event
        eventManager = EventManager(name: LANTERN_EVENT_CHANNEL, binaryMessenger: flutterbinaryMessenger ){event in
            logger.log("Lantern Event channel setup and lisntering $event")
            
        }
        lanternMethodChannel=FlutterMethodChannel(name: LANTERN_METHOED_CHANNEL, binaryMessenger: flutterbinaryMessenger)
        lanternMethodChannel.setMethodCallHandler(handleLanternMethodCall)
        
        //Navigation Channel
        navigationChannel=FlutterMethodChannel(name: NAVIGATION_METHOED_CHANNEL, binaryMessenger: flutterbinaryMessenger)
        navigationChannel.setMethodCallHandler(handleNavigationethodCall)
        //Init Models
        sessionModel=SessionModel(flutterBinary: flutterbinaryMessenger)
    }
    
    
    func handleLanternMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        
        switch call.method {
        case "yourMethod":
            // handle yourMethod
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func handleNavigationethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Handle your method calls here
        // The 'call' contains the method name and arguments
        // The 'result' can be used to send back the data to Flutter
        
        switch call.method {
        case "yourMethod":
            // handle yourMethod
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
  
    func setupEventChannel(){
        goEventHandler.setReceiveStream(self)
        goEventHandler.invoke(onListen: " From Swift")
        goEventHandler.invoke(onListen: " From Flutter")
        goEventHandler.invoke(onListen: " From A")
        goEventHandler.invoke(onListen: " From B")
//        goEventHandler.setStreamHandler(self)
//        goEventHandler.startSendingEvents()
     
    }
    
//    func onCancel(_ arguments: String?) {
//        logger.log("GoEventHandler with \(arguments!)")
//    }
//
//    func onListen(_ arguments: String?, events: InternalsdkEventSinkProtocol?) {
//        logger.log("GoEventHandler onListen with \(arguments!) with \(events)")
//    }
    
    
    func onDataReceived(_ data: String?) {
        logger.log("GoEventHandler onDataReceived with \( data) ")
    }
    
    
    
}
