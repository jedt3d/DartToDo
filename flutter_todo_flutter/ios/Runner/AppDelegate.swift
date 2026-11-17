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
#if DEBUG
      if call.method == "notificationDiagnostics",
         let args = call.arguments as? [String: Any],
         let id = args["id"] as? Int, id >= 0x60000000, id < 0x70000000 {
        let center = UNUserNotificationCenter.current()
        let delegateClass = center.delegate.map { String(describing: type(of: $0)) } ?? "nil"
        center.getNotificationSettings { settings in
          center.getPendingNotificationRequests { requests in
            center.getDeliveredNotifications { delivered in
              let pending = requests.filter { $0.identifier == String(id) }.map { request -> [String: Any] in
                let calendar = request.trigger as? UNCalendarNotificationTrigger
                return ["id": request.identifier,
                        "triggerClass": String(describing: type(of: request.trigger)),
                        "nextTrigger": calendar?.nextTriggerDate().map { ISO8601DateFormatter().string(from: $0) } ?? "nil",
                        "dateComponents": String(describing: calendar?.dateComponents)]
              }
              let diagnostics: [String: Any] = ["delegateClass": delegateClass,
                "authorization": settings.authorizationStatus.rawValue,
                "alert": settings.alertSetting.rawValue,
                "notificationCenter": settings.notificationCenterSetting.rawValue,
                "pending": pending,
                "deliveredCount": delivered.filter { $0.request.identifier == String(id) }.count]
              DispatchQueue.main.async { result(diagnostics) }
            }
          }
        }
        return
      }
#endif
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
