import Flutter
import Internalsdk
import SQLite
import Sentry
import Toast_Swift
import UIKit

// Before Commit Run linter
// swiftlint autocorrect --format
// swiftlint --fix --format
// swiftlint lint --fix --format

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  var sessionModel: SessionModel!
  var lanternModel: LanternModel!
  var navigationModel: NavigationModel!
  var vpnModel: VpnModel!
  var messagingModel: MessagingModel!

  // IOS
  var loadingManager: LoadingIndicatorManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    SentryUtils.startSentry()
    initializeFlutterComponents()
    do {
      try setupAppComponents()
    } catch {
      logger.error("Unexpected error setting up app components: \(error)")
      SentryUtils.caputure(error: error as NSError)
      fatalError(" Error While Flutter app Components setup")
      //        exit(1)
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
    try setupModels()
    startUpSequency()
    setupLoadingBar()
  }

  // Init all the models
  private func setupModels() throws {
    logger.log("setupModels method called")
    sessionModel = try SessionModel(flutterBinary: flutterbinaryMessenger)
    lanternModel = LanternModel(flutterBinary: flutterbinaryMessenger)
    vpnModel = try VpnModel(flutterBinary: flutterbinaryMessenger, vpnBase: VPNManager.appDefault)
    navigationModel = NavigationModel(flutterBinary: flutterbinaryMessenger)
    messagingModel = try MessagingModel(flutterBinary: flutterbinaryMessenger)

  }

  // Post start up
  // Init all method needed for user
  func startUpSequency() {
    //        setupLocal()
    //        createUser()
    askNotificationPermssion()
    logger.log("Sentry sdk \(SentrySDK.isEnabled)")
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
