import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        
        let batteryChannel = FlutterMethodChannel(name: "flutter.dev/native-module", binaryMessenger: controller.binaryMessenger)
        
        batteryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            WalletCoreModule.handleMethodCall(call, result)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
