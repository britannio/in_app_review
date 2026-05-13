import Flutter
import UIKit
import StoreKit

public class InAppReviewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.britannio.in_app_review", binaryMessenger: registrar.messenger())
        let instance = InAppReviewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        log("handle", details: call.method)
        
        switch call.method {
        case "requestReview":
            requestReview(result)
        case "isAvailable":
            isAvailable(result)
        case "openStoreListing":
            openStoreListing(storeId: call.arguments as? String, result: result)
        default:
            log("method not implemented")
            result(FlutterMethodNotImplemented)
        }
    }

    @available(iOS 13.0, *)
    private func currentWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        if let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) {
            return activeScene
        }

        return scenes.first
    }
    
    private func requestReview(_ result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            log("iOS 16+")
            guard let scene = currentWindowScene() else {
                result(FlutterError(code: "no-active-scene",
                                  message: "Could not find an active UIWindowScene",
                                  details: nil))
                return
            }

            DispatchQueue.main.async {
                AppStore.requestReview(in: scene)
                result(nil)
            }
        } else if #available(iOS 14.0, *) {
            log("iOS 14+")
            guard let scene = currentWindowScene() else {
                result(FlutterError(code: "no-active-scene",
                                  message: "Could not find an active UIWindowScene",
                                  details: nil))
                return
            }

            DispatchQueue.main.async {
                SKStoreReviewController.requestReview(in: scene)
                result(nil)
            }
        } else if #available(iOS 10.3, *) {
            log("iOS 10.3+")
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
                result(nil)
            }
        } else {
            result(FlutterError(code: "unavailable",
                              message: "In-App Review unavailable",
                              details: nil))
        }
    }
    
    
    private func isAvailable(_ result: @escaping FlutterResult) {
        if #available(iOS 10.3, *) {
            log("available")
            result(true)
        } else {
            log("unavailable")
            result(false)
        }
    }
    
    private func openStoreListing(storeId: String?, result: @escaping FlutterResult) {
        guard let storeId = storeId, !storeId.isEmpty else {
            result(FlutterError(code: "no-store-id",
                              message: "Your store id must be passed as the method channel's argument",
                              details: nil))
            return
        }
        
        let urlString = "https://apps.apple.com/app/id\(storeId)?action=write-review"
        guard let url = URL(string: urlString) else {
            result(FlutterError(code: "url-construct-fail",
                              message: "Failed to construct url",
                              details: nil))
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    result(nil)
                } else {
                    result(FlutterError(code: "open-store-fail",
                                      message: "Failed to open App Store listing",
                                      details: nil))
                }
            }
            return
        }

        result(FlutterError(code: "unsupported-ios-version",
                          message: "Unsupported iOS version",
                          details: nil))
    }
    
    private func log(_ message: String, details: String? = nil) {
        if let details = details {
            NSLog("InAppReviewPlugin: \(message) \(details)")
        } else {
            NSLog("InAppReviewPlugin: \(message)")
        }
    }
}
