import UIKit
import SQLite
import Flutter
import Internalsdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    // List of channel and event method names
    let NAVIGATION_METHOED_CHANNEL="lantern_method_channel"
    
    var sessionModel:SessionModel!
    var messagingModel:MessagingModel!
    var lanternModel:LanternModel!
    var flutterbinaryMessenger:FlutterBinaryMessenger!
    var lanternMethodChannel:FlutterMethodChannel!
    var navigationChannel:FlutterMethodChannel!
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger=controller.binaryMessenger
        setupModels()
        prepareChannel()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setupModels(){
        logger.log("setupModels method called")
        //Init Session Model
        sessionModel=SessionModel(flutterBinary: flutterbinaryMessenger)
        //Init Messaging Model
        messagingModel=MessagingModel(flutterBinary: flutterbinaryMessenger)
        //Init Lantern Model
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
}
