import Cocoa
import FlutterMacOS
import Internalsdk
import SQLite

@NSApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // Flutter Properties
  var flutterViewController: FlutterViewController!
  var flutterbinaryMessenger: FlutterBinaryMessenger!
  //  Model Properties
  var sessionModel: SessionModel!
  var lanternModel: LanternModel!
  //  var navigationModel: NavigationModel!
//  var vpnModel: VpnModel!
  var messagingModel: MessagingModel!
  // IOS
//  var loadingManager: LoadingIndicatorManager?

    


    override func applicationDidFinishLaunching(_ aNotification: Notification) {
           // Initialization code goes here
//           initializeFlutterComponents()
//           do {
//               try setupAppComponents()
//           } catch {
//               logger.error("Unexpected error setting up app components: \(error)")
//               NSApp.terminate(nil)
//           }
           // Assuming GeneratedPluginRegistrant is part of your Flutter setup
//           GeneratedPluginRegistrant.register(with: self)
       }
    
//  override func application(
//    _ application: NSApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    //    SentryUtils.startSentry();
//    initializeFlutterComponents()
//    do {
//      try setupAppComponents()
//    } catch {
//      logger.error("Unexpected error setting up app components: \(error)")
//      exit(1)
//    }
//    GeneratedPluginRegistrant.register(with: self)
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }

  // Flutter related stuff
    private func initializeFlutterComponents() {
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController

        self.flutterViewController = controller
        flutterbinaryMessenger = flutterViewController.engine.binaryMessenger
    }

  // Intlize this GO model and callback
  private func setupAppComponents() throws {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try self.setupModels()
//        DispatchQueue.main.async {
//          self.startUpSequency()
//          self.setupLoadingBar()
//        }
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
    
//    vpnModel = try VpnModel(flutterBinary: flutterbinaryMessenger, vpnBase: VPNManager.appDefault)
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
//    UserNotificationsManager.shared.requestNotificationPermission { granted in
//      if granted {
//        logger.debug("Notification Permssion is granted")
//      } else {
//        logger.debug("Notification Permssion is denied")
//      }
//    }
  }

  func setupLoadingBar() {
//    loadingManager = LoadingIndicatorManager(parentView: flutterViewController.view)
  }

}

