import Flutter
import UIKit
import StoreKit

public class SwiftInAppReviewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.britannio.in_app_review", binaryMessenger: registrar.messenger())
        let instance = SwiftInAppReviewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func logMessage(message: String) {
        print("SwiftInAppReviewPlugin: " + message)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logMessage(message: "handle: " + call.method)
        
        switch call.method {
        case "requestReview":
            //App Store Review
            if #available(iOS 14.0, *) {
                logMessage(message: "iOS 14+")
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    logMessage(message: "scene found")
                    SKStoreReviewController.requestReview(in: scene)
                    result(nil)
                } else {
                    logMessage(message: "scene not found")
                    result(FlutterError(code: "no-scene", message: "In-App Review could not find active scene", details: nil))
                }
            } else if #available(iOS 10.3, *) {
                logMessage(message: "iOS 10.3+")
                SKStoreReviewController.requestReview()
                result(nil)
            } else {
                result(FlutterError(code: "unavailable", message: "In-App Review unavailable", details: nil))
            }
        case "isAvailable":
            if #available(iOS 10.3, *) {
                logMessage(message: "available")
                result(true)
            } else {
                logMessage(message: "unavailable")
                result(false)
            }
        case "openStoreListing":
            let storeId : String = call.arguments as! String;
            
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id" + storeId + "?action=write-review")
            else {
                result(FlutterError(code: "url_construct_fail", message: "Failed to construct url", details: nil))
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(writeReviewURL)
                result(nil)
            } else {
                UIApplication.shared.openURL(writeReviewURL)
                result(nil)
            };
        default:
            logMessage(message: "method not implemented")
            result(FlutterMethodNotImplemented)
        }
    }
    
    
}
