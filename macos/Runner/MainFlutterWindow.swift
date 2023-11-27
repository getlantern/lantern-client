import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    var flutterViewController: FlutterViewController!
    var flutterbinaryMessenger: FlutterBinaryMessenger!
    //  Model Properties
    var sessionModel: SessionModel!
    var lanternModel: LanternModel!
    //  var navigationModel: NavigationModel!
    //  var vpnModel: VpnModel!
    var messagingModel: MessagingModel!
    
    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        self.flutterViewController = flutterViewController
        flutterbinaryMessenger = flutterViewController.engine.binaryMessenger
        
        do {
            try setupModels()
        } catch {
            logger.error("Unexpected error setting up app components: \(error)")
            NSApp.terminate(nil)
        }
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        super.awakeFromNib()
    }
    
    
    private func setupModels() throws {
        logger.log("setupModels method called")
        lanternModel = LanternModel(flutterBinary: flutterbinaryMessenger)
        sessionModel = try SessionModel(flutterBinary: flutterbinaryMessenger)
        
        //    vpnModel = try VpnModel(flutterBinary: flutterbinaryMessenger, vpnBase: VPNManager.appDefault)
        //    navigationModel = NavigationModel(flutterBinary: flutterbinaryMessenger)
        messagingModel = try MessagingModel(flutterBinary: flutterbinaryMessenger)
    }
    
    
}
