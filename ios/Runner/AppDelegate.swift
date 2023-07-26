import UIKit
import Flutter
import Internalsdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, InternalsdkReceiveStreamProtocol {
    
    // List of channel and event method names
    
    let NAVIGATION_METHOED_CHANNEL="lantern_method_channel"
    
    lazy var flutterEngine = FlutterEngine(name: "LanternIOS")
    var eventManager: EventManager!
    var sessionModel:SessionModel!
    var lanternModel:LanternModel!
    var flutterbinaryMessenger:FlutterBinaryMessenger!
    var lanternMethodChannel:FlutterMethodChannel!
    var navigationChannel:FlutterMethodChannel!
    let goEventHandler = InternalsdkEventChannel("Gohandler")!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger=controller.binaryMessenger
        setupModels()
        prepareChannel()
        setupEventChannel()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupModels(){
        logger.log("setupModels method called")
        //Init Session Model
        sessionModel=SessionModel(flutterBinary: flutterbinaryMessenger)
        
        //Init Session Model
        lanternModel=LanternModel(flutterBinary: flutterbinaryMessenger)
    }
    
    private func prepareChannel (){
        logger.log("prepareChannel method called")
        //Navigation Channel
        navigationChannel=FlutterMethodChannel(name: NAVIGATION_METHOED_CHANNEL, binaryMessenger: flutterbinaryMessenger)
        navigationChannel.setMethodCallHandler(handleNavigationethodCall)
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
    }
    
    func onDataReceived(_ data: String?) {
        logger.log("GoEventHandler onDataReceived with \( data) ")
    }
    
}
