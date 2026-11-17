# Figma font execution limitation

The native reference uses Apple's system typeface. Figma listed `SF Pro` with Regular, Medium and Semibold styles, and `loadFontAsync` returned successfully. However, the authored text reported `hasMissingFont: true`; editing an instance's text property failed with: “Unable to update this text property because the component uses a font that isn't available.” Loading the exact `fontName` returned by styled segments, including variation settings, left that flag true.

The editable Figma specification therefore uses **Inter Regular / Semi Bold** as an explicit service-compatible fallback. Flutter retains its Apple system typeface. This difference prevents a typography-fidelity pass; the Figma file is an editable layout and component specification, not evidence of exact native font rendering. No Apple UI kit EULA was accepted, and no Microsoft task screenshot was uploaded.
