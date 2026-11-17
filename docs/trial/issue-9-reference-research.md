# Issue 9 — native verification prerequisites and published iOS references

Research checkpoint: 18 November 2026 (Asia/Bangkok). Scope: read-only installed-tool/source inspection, public primary-source research and this new document only. No UI was operated, no print job submitted, no software installed, no account login performed and no application/toolchain source or Git history changed by this lane. The main session owns native interaction, captures and actual printing. [Issue 9](https://github.com/jedt3d/DartToDo/issues/9) remains the acceptance source; the facts below do not close it by themselves.

## Device Hub is the installed simulator GUI

Observed locally with `xcode-select -p`, `xcodebuild -version`, bundle inventory and `plutil -p`:

| Evidence | Observed value |
|---|---|
| Selected developer directory | `/Applications/Xcode.app/Contents/Developer` |
| Xcode | 27.2, build 27B52 |
| Installed GUI bundle | `/Applications/Xcode.app/Contents/Applications/DeviceHub.app` |
| Bundle identity | `com.apple.dt.Devices`; display name DeviceHub; version 27.2 / 255.31.3 |
| Info.plist entry executable | `Contents/MacOS/DevicesTrampoline` |
| Additional installed main binary | `Contents/MacOS/DeviceHub` (arm64e Mach-O) |
| Old Simulator location | `Contents/Developer/Applications/Simulator.app` is absent; that Applications directory is absent in this Xcode layout |
| Booted trial devices | iPhone 16 Pro and iPad Pro 11-inch (M4), both iOS 18.5 |

Apple documents Device Hub as the interactive canvas for simulator apps, and opening it from **Xcode → Open Developer Tool → Device Hub**. The supported rotation controls are **Controls → Rotate Left/Rotate Right**, the bezel rotation button, or **Device → Orientation**. This is the concrete path for an actual landscape run. [Device Hub overview](https://developer.apple.com/documentation/xcode/device-hub), [opening/managing devices](https://developer.apple.com/documentation/xcode/managing-your-simulated-and-physical-devices-in-device-hub), [interaction and rotation controls](https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub).

The main session separately reported that selecting the outer DeviceHub app worked on the first attempt and exposed the iPad, native Flutter accessibility controls and Rotate Left. That report removes the need for an untested direct-binary workaround. Binary presence alone was not proof of GUI interaction; this research lane did not reproduce the UI action.

## iPad orientation requests are not native landscape evidence

The app's [Info.plist](../../flutter_todo_flutter/ios/Runner/Info.plist) declares all four iPad interface orientations and omits `UIRequiresFullScreen`. Installed Flutter `/opt/homebrew/share/flutter/packages/flutter/lib/src/services/system_chrome.dart:539` states that iPad honors `SystemChrome.setPreferredOrientations` only with multitasking disabled. The matching [official API documentation](https://api.flutter.dev/flutter/services/SystemChrome/setPreferredOrientations.html) explains that opting out loses Slide Over/Split View. Do not disable multitasking just to obtain a screenshot.

Installed engine source confirms the request mechanism: `engine/src/flutter/shell/platform/darwin/ios/framework/Source/FlutterPlatformPlugin.mm:280` maps the requested orientations to a mask; `FlutterViewController.mm:2112–2144` uses `UIWindowScene` geometry-update requests on iOS 16+, with errors logged asynchronously. Completion of the Dart method-channel future is therefore not proof that the rendered interface rotated.

Apple's [UIRequiresFullScreen documentation](https://developer.apple.com/documentation/bundleresources/information-property-list/uirequiresfullscreen) distinguishes older Split View/Slide Over behavior from Stage Manager and newer windowed modes; the key is deprecated in iPadOS 26. The current trial simulator is iPadOS 18.5. Avoid assuming the same full-screen policy on newer OS modes.

For the independent capture, the main session should rotate the **simulated device** in Device Hub, wait for DartToDo to relayout, inspect actual controls, then capture the native framebuffer and record its actual width/height, orientation, device/OS, app revision, text scale, keyboard and pane state. Installed `xcrun simctl help io` confirms `simctl io <device> screenshot <file>`; use the explicit trial iPad identifier because both simulators are booted. No capture was made by this lane. A wide widget-test surface, a successful orientation API return or a resized image cannot substitute for the native capture.

## Physical printer: configured on macOS, not AirPrint-capable

Read-only `lpstat -d -p -v`, `lpoptions -p Brother_DCP_1610W_series` and `lpstat -W not-completed -o Brother_DCP_1610W_series` showed:

- Default queue **Brother_DCP_1610W_series**, model **Brother DCP-1610W series CUPS**.
- Queue idle, enabled and accepting jobs; no outstanding job was listed during these checks.
- Transport is Bonjour raw printing (`_pdl-datastream._tcp`), and queue sharing is disabled.
- A `toner-low-report` state reason was present. Queue enable/state timestamps were old, so these attributes do not prove the printer is currently reachable or has paper.
- A bounded Bonjour lookup did not produce a service response in this lane. This is a failed reachability observation, not proof the configured printer can never work. No address, serial number or user-device network identifier is published here.

Brother's [DCP-1610W AirPrint FAQ](https://support.brother.com/g/b/sp/faqend.aspx?c=th&faqid=faq00002865_000&lang=en&prod=dcp1610w_eu_as) explicitly says this model does not support AirPrint. Apple requires an AirPrint-capable destination for the standard iPhone/iPad workflow. A macOS CUPS driver queue is not automatically an iOS AirPrint destination. [Apple's iPhone/iPad print requirements](https://support.apple.com/en-us/109349).

The app's actual adapters are [NSPrintOperation on macOS](../../flutter_todo_flutter/macos/Runner/MainFlutterWindow.swift) and [UIPrintInteractionController with a text formatter on iOS](../../flutter_todo_flutter/ios/Runner/AppDelegate.swift). Both currently return a successful method-channel result for cancellation as well as non-error completion; the macOS return value and iOS `completed` boolean are not conveyed to Flutter. A resolved Dart print future or dismissed sheet must not be counted as physical printing.

### Minimal independent print verification

| Target | Concrete check | Evidence boundary |
|---|---|---|
| macOS + installed Brother | In DartToDo, print one short synthetic list, one page, one copy, through the native sheet to this actual queue. Record the preview/destination, submitted queue job and completion/failure state. | CUPS submission/completion and observed paper are different facts. Physical output/content needs an observer or another genuine output observation. This lane submitted nothing. |
| iPhone/iPad native path | Open DartToDo's actual native print UI on each simulator; inspect one-page preview, formatting and the available printer list. If an actual AirPrint destination exists, complete the job and retain its result. | The installed Brother is a documented AirPrint capability blocker. Native preview/cancellation alone is not an iOS physical-print pass. |
| PDF or simulated printer | Save/inspect the generated PDF or submit to Apple's Printer Simulator if independently available. | Establishes rendering/submission to that destination, not physical paper or this Brother model. Keep the exact destination explicit. |

### Printer Simulator availability

No Printer Simulator candidate was found in the installed Xcode bundle inventory, Spotlight search, or bounded app-directory scans of `/Applications`, `/Library/Developer`, `~/Applications` and `~/Downloads`. The scan is evidence of those locations only, not a claim about every mounted volume.

Apple's [archived iOS printing guide](https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/Printing/Printing.html) describes simulated destinations, Preview output and printer logs. Its old bundled path is not present in this installation and must not be presented as a working command. An [Apple DTS answer](https://developer.apple.com/forums/thread/797789) confirms Printer Simulator in an Additional Tools package (the documented example is Xcode 26 beta 6). The [current official download catalog](https://developer.apple.com/download/all/?q=Additional%20Tools) redirected to Apple authentication during this research. No exact Xcode 27.2 archive, installed path or current simulator compatibility was verified. The lane neither logged in nor installed a package. Report that dependency honestly if unavailable.

## Microsoft-published mobile visual references

The [official Microsoft To Do App Store listing](https://apps.apple.com/us/app/microsoft-to-do/id1212616790) is a valid published reference, not an approved project baseline. Apple [Lookup metadata](https://itunes.apple.com/lookup?id=1212616790&country=us) returned Microsoft Corporation, bundle `com.microsoft.to-do`, version **2.177**, version release **6 July 2026**, minimum iOS **17.6**. This does not date each screenshot or prove it depicts the current installed build.

The listing's `serialized-server-data` contained six phone screenshot artworks (1242×2688), a separate phone media item and four iPad artworks (2732×2048). The Lookup endpoint returned a different set of thumbnail URLs, so the source page/gallery and exact asset must be identified rather than silently mixed.

Four exact gallery assets were fetched into memory and visually inspected; no copies were saved to this repository:

| Published gallery item | Exact reference asset | Visible content and limit |
|---|---|---|
| Phone screenshot 1 | [1242×2688 artwork](https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/bc/66/10/bc661030-fa64-bf63-0e80-7420106f658f/pr_source.png/1242x2688bb.jpeg) | My Day heading/date and completion rows, inside a tilted, cropped marketing composition. |
| Phone screenshot 2 | [1242×2688 artwork](https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/03/ef/ba/03efba9f-ec77-687e-8243-f12c01c887b8/pr_source.png/1242x2688bb.jpeg) | Partial photo-backed rows, stars and account avatars; cropped/tilted composition. Inspected at half-size rendition. |
| iPad screenshot 1 | [2732×2048 artwork](https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/14/f6/65/14f665b5-21c5-ca96-13cb-7347d8570bae/pr_source.png/2732x2048bb.jpeg) | Sidebar beside My Day, within cropped marketing artwork. Account-dependent entries are outside the local clone scope. |
| iPad screenshot 2 | [2732×2048 artwork](https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/58/05/5c/58055c55-8e21-880d-dc8b-f266ffd3fad1/7044bb1b-c566-4feb-ba85-d1893e2dcf02_Screenshot_5.png/2732x2048bb.jpeg) | Blue grocery-list pane with row controls and bottom composer, inside a promotional layout. Inspected at half-size rendition. |

These assets support qualitative comparison of visible structure. They do not provide full-screen device captures, runtime interaction, exact type metrics, current-build parity or human approval. Preserve the original asset, document any comparison crop/scale, and do not turn promotional copy/backgrounds into application layout measurements. Do not recreate account avatars, shared-list membership, assignment or Flagged Email as live local features.

For a controlled full-screen comparison, obtain matching reference viewport/state/theme/data/text scale and a genuine reference capture or a separately approved target. The installed macOS source remains available for read-only observation by the main session. Published iOS artwork improves the earlier mobile-reference gap but does not replace live iOS reference interaction or establish an approved whole-UI golden. Human approval and any exact-parity verdict remain unknown.

## Remaining acceptance evidence

The main session owns actual Device Hub rotation/interaction and landscape screenshots, native print previews, a minimal authorized physical macOS job and its observed outcome, notification behavior and final parity decisions. This research supplies prerequisites and source evidence only. It does not count compilation, fixtures, published marketing images or configured hardware as successful native behavior.
