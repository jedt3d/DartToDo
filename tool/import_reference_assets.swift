import AppKit
import Foundation

// Extract only shipped visual assets, never account/task data.
let source = "/Applications/Microsoft To Do.app/Contents/Frameworks/WLUICore.framework"
guard let bundle = Bundle(path: source) else { fatalError("Reference app not installed") }
let destination = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
for theme in ["tv_tower", "beach", "desert", "fern", "field", "gradient", "lighthouse", "safari", "sea"] {
    let name = "photo_\(theme)/image"
    guard let image = bundle.image(forResource: NSImage.Name(name)),
          let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Cannot load \(name)")
    }
    try png.write(to: destination.appendingPathComponent("\(theme).png"))
    print("Imported \(theme): \(bitmap.pixelsWide)x\(bitmap.pixelsHigh)")
}
