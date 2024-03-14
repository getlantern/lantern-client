import Flutter
import Internalsdk
import SQLite
import Toast_Swift
import UIKit

//know Issue
//  CFPrefsPlistSource<0x28281e580> (Domain: group.getlantern.lantern, User: kCFPreferencesAnyUser, ByHost: Yes, Container: (null), Contents Need Refresh: Yes): Using kCFPreferencesAnyUser with a container is only allowed for System Containers,

// For IOS App Lunch time issue
//https://developer.apple.com/videos/play/wwdc2019/423/?time=305
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  var sessionModel: SessionModel!
  var lanternModel: LanternModel!
  //  var navigationModel: NavigationModel!
  var vpnModel: VpnModel!
  var messagingModel: MessagingModel!
  // IOS
  var loadingManager: LoadingIndicatorManager?
  let mainQueue = DispatchQueue.main

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //    SentryUtils.startSentry();
    initializeFlutterComponents()
    try! setupModels()
    try! setupAppComponents()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    

    

  // Flutter related stuff
  private func initializeFlutterComponents() {
    if flutterViewController == nil || flutterbinaryMessenger == nil {
      flutterViewController = window?.rootViewController as! FlutterViewController
      flutterbinaryMessenger = flutterViewController.binaryMessenger
    }

  }

  // Intlize this GO model and callback
  private func setupAppComponents() throws {
    startUpSequency()
    setupLoadingBar()
  }

  // Init all the models
  private func setupModels() throws {
    logger.log("setupModels method called")
      
    let dispatchGroup = DispatchGroup()
    // If flutterbinaryMessenger nil somehow then assign it again
    if flutterbinaryMessenger == nil || flutterViewController == nil {
      initializeFlutterComponents()
    }
      lanternModel = LanternModel(flutterBinary: self.flutterbinaryMessenger)
      sessionModel = try SessionModel(flutterBinary: self.flutterbinaryMessenger)
      vpnModel = try VpnModel(
        flutterBinary: self.flutterbinaryMessenger, vpnBase: VPNManager.appDefault,sessionModel:sessionModel)
      messagingModel = try MessagingModel(flutterBinary: flutterbinaryMessenger)
//    // Initialize LanternModel
//    dispatchGroup.enter()
//    DispatchQueue.global(qos: .userInitiated).async {
//      self.lanternModel = LanternModel(flutterBinary: self.flutterbinaryMessenger)
//      dispatchGroup.leave()
//    }
//
//    // Initialize SessionModel
//    dispatchGroup.enter()
//    DispatchQueue.global(qos: .userInitiated).async {
//      do {
//        self.sessionModel = try SessionModel(flutterBinary: self.flutterbinaryMessenger)
//      } catch {
//        logger.error("Error initializing SessionModel: \(error)")
//      }
//      dispatchGroup.leave()
//    }
//
//    // Initialize VpnModel
//    dispatchGroup.enter()
//    DispatchQueue.global(qos: .userInitiated).async {
//      do {
//        self.vpnModel = try VpnModel(
//          flutterBinary: self.flutterbinaryMessenger, vpnBase: VPNManager.appDefault)
//      } catch {
//        logger.error("Error initializing vpnModel: \(error)")
//      }
//      dispatchGroup.leave()
//    }
//    logger.log("Initializing setupModels done")
//    messagingModel = try MessagingModel(flutterBinary: flutterbinaryMessenger)
//    dispatchGroup.wait()  // Wait for all initializations to complete
  }

  // Post start up
  // Init all method needed for user
  func startUpSequency() {
    // Do not show notification dialog in Appium Env
    if AppEnvironment.current != AppEnvironment.appiumTest {
      askNotificationPermssion()
    }
  }

  func askNotificationPermssion() {
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

}
