import Flutter
import UIKit
import StoreKit

public class SwiftInAppReviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dev.britannio.in_app_review", binaryMessenger: registrar.messenger())
    let instance = SwiftInAppReviewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    switch (call.method) {
        case "requestReview":
          //App Store Review
          if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            result(true)
          } else {
            result(FlutterError(code: "unavailable", message: "In-App Review unavailable", details: nil))
          }
        case "isAvailable":
          if #available(iOS 10.3, *) {
            result(true)
          } else {
            result(false)
          }
        default:
          result(FlutterMethodNotImplemented)
    }
  }
    
    
}
