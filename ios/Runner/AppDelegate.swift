import Flutter
import Internalsdk
import SQLite
import Toast_Swift
import UIKit

//know Issue
//  CFPrefsPlistSource<0x28281e580> (Domain: group.getlantern.lantern, User: kCFPreferencesAnyUser, ByHost: Yes, Container: (null), Contents Need Refresh: Yes): Using kCFPreferencesAnyUser with a container is only allowed for System Containers,

//For ios trakcing:- https://stackoverflow.com/questions/65207375/nsusertrackingdescription-failure

// For IOS App Lunch time issue
//https://developer.apple.com/videos/play/wwdc2019/423/?time=305
@main
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  private var sessionModel: SessionModel!
  private var lanternModel: LanternModel!
  private var vpnModel: VpnModel!
  private var messagingModel: MessagingModel!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    initializeFlutterComponents()
    try! setupModels()
    try! setupAppComponents()
    GeneratedPluginRegistrant.register(with: self)
    NSSetUncaughtExceptionHandler { exception in
      print(exception.reason)
      print(exception.callStackSymbols)
    }
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
  }

  // Init all the models
  private func setupModels() throws {
    logger.log("setupModels method called")

    // If flutterbinaryMessenger nil somehow then assign it again
    if flutterbinaryMessenger == nil || flutterViewController == nil {
      initializeFlutterComponents()
    }
    lanternModel = LanternModel(flutterBinary: self.flutterbinaryMessenger)
    sessionModel = try SessionModel(flutterBinary: self.flutterbinaryMessenger)
    vpnModel = try VpnModel(
  flutterBinary: self.flutterbinaryMessenger, vpnBase: VPNManager.appDefault,
  sessionModel: sessionModel)
    messagingModel = try MessagingModel(flutterBinary: flutterbinaryMessenger)
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

}
