import UIKit
import SQLite
import Flutter
import Internalsdk
import Toast_Swift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    // List of channel and event method names
    let NAVIGATION_METHOED_CHANNEL="lantern_method_channel"
    
    var sessionModel:SessionModel!
    var messagingModel:MessagingModel!
    var lanternModel:LanternModel!
    var vpnModel:VpnModel!
    var flutterbinaryMessenger:FlutterBinaryMessenger!
    var lanternMethodChannel:FlutterMethodChannel!
    var navigationChannel:FlutterMethodChannel!
    var flutterViewController:FlutterViewController!
    var loadingIndicator: UIActivityIndicatorView!

  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        flutterViewController  = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger=flutterViewController.binaryMessenger
        setupModels()
        prepareChannel()
        setupLocal()
        createUser()
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
        //Init VPN Model
        vpnModel=VpnModel(flutterBinary: flutterbinaryMessenger,vpnBase: VPNManager.appDefault)
    }
    
    
    private func prepareChannel (){
        logger.log("prepareChannel method called")
        //Navigation Channel
        navigationChannel=FlutterMethodChannel(name: NAVIGATION_METHOED_CHANNEL, binaryMessenger: flutterbinaryMessenger)
        navigationChannel.setMethodCallHandler(handleNavigationethodCall)
    }
    
    private func setupLocal(){
        let langStr = Locale.current.identifier
        if langStr != nil{
            sessionModel.setLocal(lang: langStr)
            logger.log("Local value found  \(langStr)")
        }else{
            logger.log("Local value found nil")
        }
    }
    
    // Calling create API
    func createUser(){
        DispatchQueue.main.async {
            self.showLoadingDialog()
        }
        DispatchQueue.global().async {
            let success = self.sessionModel.createUser(local: Locale.current.identifier)
            // After the API call is done, move back to the main thread to update UI
            DispatchQueue.main.async {
                self.hideLoadingDialog()
                if success {
                    self.flutterViewController.view.makeToast("User Created")
                } else {
                    self.flutterViewController.view.makeToast("Error while creating user")
                }
            }
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
    
    
    //Todo-:Sprate this Loading indicator to new class for reuse
    private func showLoadingDialog(){
         loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingIndicator.center = flutterViewController.view.center
        loadingIndicator.hidesWhenStopped = false
        loadingIndicator.startAnimating()
        flutterViewController.view.addSubview(loadingIndicator)
    }
    
    private func hideLoadingDialog() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
    }
    
    
}
