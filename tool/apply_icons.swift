import AppKit
import CryptoKit
import Foundation

// Deterministic packaging of the exact user-approved Figma exports.
let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let source = root.appendingPathComponent("docs/design/icon-variants/folded-check-themes")
let app = root.appendingPathComponent("flutter_todo_flutter")
let manager = FileManager.default
func read(_ url: URL) throws -> [String: Any] {
  try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
}
func write(_ value: [String: Any], _ url: URL) throws {
  try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys]).write(to: url)
}
let manifest = try read(source.appendingPathComponent("manifest.json"))
guard manifest["status"] as? String == "final-bordered-dark-and-light" else { fatalError("Final selection required") }
for appearance in manifest["appearances"] as! [[String: Any]] {
  for file in appearance["pngs"] as! [[String: Any]] {
    let data = try Data(contentsOf: source.appendingPathComponent(file["file"] as! String))
    let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    guard digest == file["sha256"] as? String else { fatalError("Source export hash changed") }
  }
}
func save(_ appearance: String, _ size: Int, _ destination: URL, opaque: Bool = false) throws {
  var path = source.appendingPathComponent("darttodo-folded-check-\(appearance)-\(size).png")
  if !manager.fileExists(atPath: path.path) { path = source.appendingPathComponent("darttodo-folded-check-\(appearance)-1024.png") }
  guard let image = NSImage(contentsOf: path),
        let original = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
        let context = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8,
          bytesPerRow: size * 4, space: CGColorSpaceCreateDeviceRGB(),
          bitmapInfo: opaque ? CGImageAlphaInfo.noneSkipLast.rawValue : CGImageAlphaInfo.premultipliedLast.rawValue)
        else { fatalError("Image conversion failed: \(path.path), size \(size)") }
  context.interpolationQuality = .high
  let rect = CGRect(x: 0, y: 0, width: size, height: size)
  if opaque {
    let color = appearance == "light" ? NSColor(srgbRed: 242/255, green: 248/255, blue: 252/255, alpha: 1) : NSColor(srgbRed: 11/255, green: 35/255, blue: 58/255, alpha: 1)
    context.setFillColor(color.cgColor); context.fill(rect)
  }
  context.draw(original, in: rect)
  guard let rendered = context.makeImage() else { fatalError("Image rendering failed") }
  let bitmap = NSBitmapImageRep(cgImage: rendered)
  guard let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("PNG conversion failed") }
  try png.write(to: destination)
  guard NSBitmapImageRep(data: png)?.pixelsWide == size else { fatalError("Wrong icon dimensions") }
}
var count = 0
for platform in ["macos", "ios"] {
  let catalog = app.appendingPathComponent("\(platform)/Runner/Assets.xcassets/AppIcon.appiconset")
  let contentsURL = catalog.appendingPathComponent("Contents.json")
  var contents = try read(contentsURL)
  var images = (contents["images"] as! [[String: Any]]).filter { $0["idiom"] as? String != "universal" }
  for entry in images {
    let size = Double((entry["size"] as! String).split(separator: "x")[0])!
    let scale = Double((entry["scale"] as? String ?? "1x").dropLast())!
    try save("light", Int((size * scale).rounded()), catalog.appendingPathComponent(entry["filename"] as! String), opaque: platform == "ios")
    count += 1
  }
  if platform == "ios" {
    for appearance in ["light", "dark"] {
      let name = "DartToDo-\(appearance)-1024.png"
      try save(appearance, 1024, catalog.appendingPathComponent(name), opaque: appearance == "light")
      var entry: [String: Any] = ["filename": name, "idiom": "universal", "platform": "ios", "size": "1024x1024"]
      if appearance == "dark" { entry["appearances"] = [["appearance": "luminosity", "value": "dark"]] }
      images.append(entry); count += 1
    }
  }
  contents["images"] = images
  try write(contents, contentsURL)
}
for appearance in ["light", "dark"] {
  let catalog = app.appendingPathComponent("macos/Runner/Assets.xcassets/DartToDo\(appearance.capitalized).imageset")
  try manager.createDirectory(at: catalog, withIntermediateDirectories: true)
  try save(appearance, 1024, catalog.appendingPathComponent("icon.png"))
  try write(["images": [["filename": "icon.png", "idiom": "universal"]], "info": ["author": "xcode", "version": 1]], catalog.appendingPathComponent("Contents.json"))
  count += 1
}
try write(["status": "catalogs-generated", "selected": "folded-check", "catalogEntries": count,
           "figmaBoard": "https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=15-452",
           "sourceManifest": "docs/design/icon-variants/folded-check-themes/manifest.json",
           "iosDefaultOpaque": true, "iosDarkAppearance": true, "macDefault": "light", "macDockAppearance": "follows-system",
           "note": "Native build and runtime verification are recorded separately."], root.appendingPathComponent("docs/design/icon-integration.json"))
print("Packaged \(count) native icon entries from the verified final exports.")
