import Flutter
import Internalsdk
import SQLite
import Toast_Swift
import UIKit

//know Issue
//  CFPrefsPlistSource<0x28281e580> (Domain: group.getlantern.lantern, User: kCFPreferencesAnyUser, ByHost: Yes, Container: (null), Contents Need Refresh: Yes): Using kCFPreferencesAnyUser with a container is only allowed for System Containers,

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  var sessionModel: SessionModel!
  var lanternModel: LanternModel!
  //  var navigationModel: NavigationModel!
  var vpnModel: VpnModel!
  var messagingModel: MessagingModel!
  // IOS
  var loadingManager: LoadingIndicatorManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //    SentryUtils.startSentry();
    initializeFlutterComponents()
    do {
      try setupModels()
      try setupAppComponents()
    } catch {
      logger.error("Unexpected error setting up app components: \(error)")
      exit(1)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Flutter related stuff
  private func initializeFlutterComponents() {
    flutterViewController = window?.rootViewController as! FlutterViewController
    flutterbinaryMessenger = flutterViewController.binaryMessenger
  }

  // Intlize this GO model and callback
  private func setupAppComponents() throws {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
//        try self.setupModels()
        DispatchQueue.main.async {
          self.startUpSequency()
          self.setupLoadingBar()
        }
      } catch {
        DispatchQueue.main.async {
          logger.error("Unexpected error setting up models: \(error)")
        }
      }
    }

  }

  // Init all the models
  private func setupModels() throws {
    logger.log("setupModels method called")
    lanternModel = LanternModel(flutterBinary: flutterbinaryMessenger)
    sessionModel = try SessionModel(flutterBinary: flutterbinaryMessenger)
    vpnModel = try VpnModel(flutterBinary: flutterbinaryMessenger, vpnBase: VPNManager.appDefault)
    //    navigationModel = NavigationModel(flutterBinary: flutterbinaryMessenger)
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

  func setupLoadingBar() {
    loadingManager = LoadingIndicatorManager(parentView: flutterViewController.view)
  }

}
