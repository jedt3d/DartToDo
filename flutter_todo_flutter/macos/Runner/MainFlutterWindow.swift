import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(NSRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: 1100, height: 720), display: true)
    self.minSize = NSSize(width: 520, height: 480)
    self.title = "DartToDo"
    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    let native = FlutterMethodChannel(name: "darttodo/native", binaryMessenger: flutterViewController.engine.binaryMessenger)
    native.setMethodCallHandler { call, result in
      guard call.method == "printList",
            let arguments = call.arguments as? [String: String],
            let title = arguments["title"], let body = arguments["body"] else {
        result(FlutterMethodNotImplemented)
        return
      }
      let text = NSTextView(frame: NSRect(x: 0, y: 0, width: 520, height: 720))
      text.string = title + "\n\n" + body
      text.font = NSFont.systemFont(ofSize: 14)
      text.textContainerInset = NSSize(width: 24, height: 24)
      // The print operation paginates the full text, but drawing is clipped to
      // the view's bounds. Expand those bounds to include every laid-out line.
      if let container = text.textContainer, let layout = text.layoutManager {
        container.size = NSSize(width: 472, height: CGFloat.greatestFiniteMagnitude)
        container.widthTracksTextView = true
        container.heightTracksTextView = false
        layout.ensureLayout(for: container)
        let height = ceil(layout.usedRect(for: container).height) + 48
        text.setFrameSize(NSSize(width: 520, height: max(1, height)))
      }
      let operation = NSPrintOperation(view: text)
      operation.jobTitle = title
      operation.run()
      result(nil)
    }

    super.awakeFromNib()
  }
}
