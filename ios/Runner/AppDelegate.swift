import UIKit
import SQLite
import Flutter
import Internalsdk
import Toast_Swift

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
     // Flutter Properties
    var flutterViewController: FlutterViewController!
    var flutterbinaryMessenger: FlutterBinaryMessenger!
    //  Model Properties
    var sessionModel: SessionModel!
    var messagingModel: MessagingModel!
    var lanternModel: LanternModel!
    var vpnModel: VpnModel!
    var navigationModel: NavigationModel!
    
    //IOS
    var loadingManager: LoadingIndicatorManager?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initializeFlutterComponents()
        setupAppComponents()
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //Flutter related stuff
    private func initializeFlutterComponents() {
        
        
        flutterViewController = window?.rootViewController as! FlutterViewController
        flutterbinaryMessenger = flutterViewController.binaryMessenger}
    
    
    // Intlize this GO model and callback
    private func setupAppComponents() {
        setupModels()
        startUpSequency()
        setupLoadingBar()
    }
    
    
    //Init all the models
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
        //Init Navigation Model
        navigationModel=NavigationModel(flutterBinary: flutterbinaryMessenger)
    }
    
    // Post start up
    // Init all method needed for user
    func startUpSequency()  {
        setupLocal()
        createUser()
        askNotificationPermssion()
        
    }
    
    func askNotificationPermssion()  {
        
        
        UserNotificationsManager.shared.requestNotificationPermission { granted in
            if granted {
                logger.debug("Notification Permssion is granted")
            } else {
                logger.debug("Notification Permssion is denied")
            }
        }
    }
    
    func setupLoadingBar() {
        loadingManager = LoadingIndicatorManager(parentView: flutterViewController.view)
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
            self.loadingManager?.show()
        }
        DispatchQueue.global().async {
            let success = self.sessionModel.createUser(local: Locale.current.identifier)
            // After the API call is done, move back to the main thread to update UI
            DispatchQueue.main.async {
                self.loadingManager?.hide()
                if success {
                    self.flutterViewController.view.makeToast("User Created")
                } else {
                    self.flutterViewController.view.makeToast("Error while creating user")
                }
            }
        }
        
    }
    
}
