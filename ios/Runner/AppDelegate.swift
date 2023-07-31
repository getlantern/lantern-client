import UIKit
import SQLite
import Flutter
import Internalsdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, InternalsdkReceiveStreamProtocol {
    
    // List of channel and event method names
    let NAVIGATION_METHOED_CHANNEL="lantern_method_channel"
    
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
        setupDbModel()
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
    
    func getDatabasePath() -> String {
           let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
           let fileURL = documentDirectory.appendingPathComponent("LANTERN").appendingPathExtension("sqlite3")
           return fileURL.path
       }
    
    func setupDbModel() {
        logger.log("createNewModel called")
        let dbName = "Session"
        do {
            let dbPath = getDatabasePath()
            let db = try Connection(dbPath)
            let swiftDB = DatabaseManager(database: db)
            var error: NSError?
            guard let model = InternalsdkNewModel(dbName, swiftDB, &error) else {
                throw error!
            }
            let stringValue = ValueUtil.makeValue(from: "test/db")
            let args = ValueArrayHandler(values: [stringValue])
            
            
            let result = try model.invokeMethod("testDbConnection", arguments: args)

            let resultValue = ValueUtil.getValue(from: result)
            logger.log("Model Invoke method result converted \(resultValue)")
        } catch {
            logger.log("Failed to create new model: \(error)")
        }
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
