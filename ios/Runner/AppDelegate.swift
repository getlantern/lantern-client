import Flutter
import Internalsdk
import SQLite
import Toast_Swift
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  private var sessionModel: SessionModel!
  private var lanternModel: LanternModel!
  private var vpnModel: VpnModel!
  private var messagingModel: MessagingModel!
  private var lanternService: LanternService!
  // IOS
  var loadingManager: LoadingIndicatorManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //    SentryUtils.startSentry();
    initializeFlutterComponents()
    do {
      try setupAppComponents()
      try setupLanternService()
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

  private func setupLanternService() throws {
    try self.lanternService = LanternService(
      sessionModel: self.sessionModel.model, vpnModel: self.vpnModel)
    // Run Lantern service on a background queue
    DispatchQueue.global(qos: .background).async {
      self.lanternService.start()
    }
  }

  // Intlize this GO model and callback
  private func setupAppComponents() throws {
    try self.setupModels()
    DispatchQueue.main.async {
      self.startUpSequency()
      self.setupLoadingBar()
    }
  }

  // Init all the models
  private func setupModels() throws {
    logger.log("setupModels method called")
    sessionModel = try SessionModel(flutterBinary: flutterbinaryMessenger)
    lanternModel = LanternModel(flutterBinary: flutterbinaryMessenger)
    vpnModel = try VpnModel(
      flutterBinary: flutterbinaryMessenger, vpnBase: VPNManager.appDefault,
      sessionModel: sessionModel)
    // navigationModel = NavigationModel(flutterBinary: flutterbinaryMessenger)
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
