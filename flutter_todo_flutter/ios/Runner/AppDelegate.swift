import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DartToDoNative") else { return }
    let native = FlutterMethodChannel(name: "darttodo/native", binaryMessenger: registrar.messenger())
    native.setMethodCallHandler { call, result in
      guard call.method == "printList", let arguments = call.arguments as? [String: String],
            let title = arguments["title"], let body = arguments["body"] else {
        result(FlutterMethodNotImplemented)
        return
      }
      let controller = UIPrintInteractionController.shared
      let info = UIPrintInfo(dictionary: nil)
      info.jobName = title
      info.outputType = .general
      controller.printInfo = info
      controller.printFormatter = UISimpleTextPrintFormatter(text: title + "\n\n" + body)
      controller.present(animated: true) { _, _, error in
        if let error = error {
          result(FlutterError(code: "print", message: error.localizedDescription, details: nil))
        } else { result(nil) }
      }
    }
  }
}
