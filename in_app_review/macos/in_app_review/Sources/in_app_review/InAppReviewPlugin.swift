import Cocoa
import FlutterMacOS
import StoreKit

public class InAppReviewPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "dev.britannio.in_app_review",
            binaryMessenger: registrar.messenger)
        let instance = InAppReviewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(
        _ call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        switch call.method {
        case "requestReview":
            requestReview(result)
        case "isAvailable":
            if #available(OSX 10.14, *) {
                result(true)
            } else {
                result(false)
            }
        case "openStoreListing":
            openStoreListing(storeId: call.arguments as? String, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @available(OSX 13.0, *)
    private func currentViewController() -> NSViewController? {
        let app = NSApplication.shared
        let window = app.keyWindow ?? app.mainWindow ?? app.windows.first(where: { $0.isVisible })
        return window?.contentViewController
    }

    private func requestReview(_ result: @escaping FlutterResult) {
        if #available(OSX 13.0, *) {
            guard let viewController = currentViewController() else {
                result(
                    FlutterError(
                        code: "no-view-controller",
                        message: "Could not get a window view controller",
                        details: nil))
                return
            }

            DispatchQueue.main.async {
                AppStore.requestReview(in: viewController)
                result(nil)
            }
            return
        }

        if #available(OSX 10.14, *) {
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
                result(nil)
            }
            return
        }

        result(
            FlutterError(
                code: "unavailable",
                message: "In-App Review unavailable",
                details: nil))
    }

    private func openStoreListing(storeId: String?, result: @escaping FlutterResult) {
        guard let storeId = storeId, !storeId.isEmpty else {
            result(
                FlutterError(
                    code: "no-store-id",
                    message: "Your store id must be passed as the method channel's argument",
                    details: nil))
            return
        }

        guard
            let writeReviewURL = URL(
                string: "macappstore://apps.apple.com/app/id" + storeId + "?action=write-review")
        else {
            result(
                FlutterError(
                    code: "url_construct_fail",
                    message: "Failed to construct url", details: nil))
            return
        }

        if NSWorkspace.shared.open(writeReviewURL) {
            result(nil)
        } else {
            result(
                FlutterError(
                    code: "open-store-fail",
                    message: "Failed to open Mac App Store listing",
                    details: nil))
        }
    }
}
