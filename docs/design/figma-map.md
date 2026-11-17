# DartToDo design source

[Open the editable Figma review board](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-28). The page is **DartToDo · Native reference** (`0:1`). It reconstructs the measured macOS reference and provides adaptive iPhone/iPad specifications. It does not claim exact pixel parity, native font parity, or fidelity to an uninspected Microsoft iOS application.

## Screens

| Screen | Node | Logical size | Figma link |
|---|---|---|---|
| Review board | `7:28` | 2240 × 1920 | [Review](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-28) |
| macOS Tasks with details | `7:35` | 1100 × 720 | [Desktop](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-35) |
| macOS My Day | `7:252` | 1084 × 720 | [My Day](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-252) |
| iPad landscape with first-task details | `7:347` | 1210 × 834 | [iPad](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-347) |
| iPhone Tasks | `7:487` | 390 × 844 | [iPhone list](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-487) |
| iPhone details | `7:558` | 390 × 844 | [iPhone detail](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=7-558) |
| Selected Folded check icon board | `15:452` | Separate light/dark review | [Final icon source](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=15-452) |

The desktop uses a 244-point sidebar and 320-point detail pane. Source tasks were never imported: all displayed task text is synthetic. My Day, Important, Planned, Tasks, custom lists, selected/completed tasks, steps, notes, scheduling actions, file action and bottom composer are editable layers. Local-only exclusions appear on the board.

## Components and tokens

| Component family | Node | Included states/properties |
|---|---|---|
| Completion | `5:72` | Incomplete / Complete |
| Sidebar Item | `5:85` | Default / Selected; label, count, icon swap |
| Task Row | `5:116` | Default / Selected / Completed; title, metadata, star icon swap |
| Detail Action | `5:127` | Default / Active; label, icon swap |
| Search | `5:128` | Editable placeholder |
| Composer | `5:133` | Editable placeholder |
| Fluent icons | IDs in `figma-components.json` | 21 editable vector icon components; Microsoft MIT license/provenance in `icons/` |

The native-reference page now has **32 local main components**: nine variants, 21 icon components, Search and Composer, plus four component sets. The unused provisional icon `8:347` had zero instances and was removed after the user selected the separate Folded check source. Construction components remain outside the review board. Two unrelated library candidate sets were imported only for discovery; their temporary instances were removed. No Code Connect files or mappings existed, and none was fabricated for the Flutter app.

Foundations comprise **66 variables**: 33 hidden primitives and 33 scoped semantic aliases, in `To Do · Primitives` (`VariableCollectionId:4:2`, Value mode) and `To Do · Semantic` (`VariableCollectionId:4:3`, Light mode). All have WEB code syntax for the declared interoperable `--todo-*` naming scheme; these are design-export names, not claims that the Flutter app defines CSS variables. Four shared text styles cover Body, Metadata, Title and Heading. [Token values](reference-tokens.json), [variable/style IDs](figma-foundations.json), [component IDs/properties](figma-components.json) and [machine-readable mapping](../../tool/figma-design-source.json) retain the exact identities.

## Validation and limits

The updated review board has **532 descendants** (533 nodes including the board): 169 descendant frames, 121 text nodes, 139 component instances, 72 vectors, 13 rectangles and 18 ellipses. The photo, visible attribution and editable structure were inspected in one [updated composition screenshot](figma-review-featured.png). Every semantic variable still aliases a primitive; no variables or component roles were changed in this update. The earlier [validation data](figma-validation.json), [state map](figma-state.json) and [review image](figma-review.png) preserve their original 529-node checkpoint and superseded icon identity; they are historical evidence, not the updated board inventory.

Only one review node has an image fill: `7:325`, the My Day wallpaper. It now uses the real free Featured photo [Hpf8lIyrsGc](https://unsplash.com/photos/skyscrapers-in-new-york-city-skyline-Hpf8lIyrsGc), by [Keithen Schwahn](https://unsplash.com/@keithen), from the homepage pool captured on 17 November 2026. The [discrete reference JPEG](my-day-featured-Hpf8lIyrsGc.jpg) retains that photo under the [Unsplash license](https://unsplash.com/license); it is not a flattened UI screenshot. The visible credit is editable text `23:350`, within frames `23:348`/`23:349`. No user task screenshot, avatar or account detail was uploaded. The earlier Microsoft-owned tower image is absent from the current board; historical screenshots record the earlier local reference.

Figma lists SF Pro and accepts loading it, but authored text reports a missing font and refuses instance text edits. The editable Figma artifact therefore uses **Inter**. Flutter should retain the Apple system typeface. [Font limitation](font-limitation.md) records the failed operation and correction. Typography fidelity is **unverified**, despite the editable structure and visual layout passing their own checks.

The user selected **Folded check** in dark and light appearances, then added the final borders. [Final editable icon board](https://www.figma.com/design/P72xp9CQ7S1SkSqLdn7ORO?node-id=15-452) and [final exports](icon-variants/folded-check-themes/README.md) are authoritative. Native catalogs now use these verified exports: light default plus iOS dark appearance, and light/dark macOS Dock imagery. [Integration record](icon-integration.json) separates packaging from native build/runtime verification. The old generic check component and its provisional `darttodo-icon.svg`/`.png` exports were removed; the selected icon source and user edits were not changed.

My Day selects a free Featured Unsplash photo on each app launch, without an API key in default mode. The screen is a representative dated selection, not a prediction of the next random choice. The app uses bounded homepage JSON parsing, cached/seed fallback and photographer attribution; this public webpage shape is not a stable API. See [Unsplash behavior and provenance](../unsplash.md). The first-page scope/fidelity notes (`7:640`) and icon-status note (`23:347`) record these distinctions. The final icon page `12:347` was untouched by this coordination update.
This design is a static editable specification. Real persistence, gestures, reminders, keyboard behavior, accessibility, catalog runtime cases, and simulator coverage must be verified in the application separately. No human design rating or comprehension time has been measured.

## Issue 9 landscape coordination · 18 November 2026

The existing tablet frame now includes an editable 320-point inspector (`28:347`) and uses the actual simulator landscape size of 1210 × 834 logical points. The first visible task is selected automatically; closing details suppresses automatic reopening until list navigation or re-entering landscape. Empty lists show a useful empty inspector in the app. The [composition export](figma-ipad-landscape.png) and [structural record](figma-parity-9.json) show 182 tablet descendants, including 51 component instances, with no complete-screen raster. The 532-descendant board count above is the historical pre-change checkpoint.

The exported composition was inspected for panel boundaries, composer reachability, text clipping and overlap. Text remains Inter in Figma and Apple system in Flutter, so native typography fidelity and human approval remain unverified. Task dragging, reminder navigation and 25 MiB aggregate attachments are application behavior verified separately; static design layers do not establish them.
