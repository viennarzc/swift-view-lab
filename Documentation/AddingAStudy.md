# Add a paired study

## 1. Create the experiment

Create a folder under `Examples/ComponentGallery/ComponentGallery/Studies/<StudyName>/` containing:

- `<StudyName>StudyView.swift`: the page that owns shared demo settings and state
- A SwiftUI demonstration
- A UIKit demonstration hosted through `UIViewRepresentable` or `UIViewControllerRepresentable`

Start with the animated button study as a working example. Keep experimental components here until their reuse boundary is clear. A renderer comparison that is intentionally SwiftUI-only, such as the Mechanical Rocker Switch, should state that exception in its documentation and preserve shared state across renderers. Xcode's synchronized folders include new source files automatically; you do not need to edit the project file.

## 2. Match the behavior

Use one SwiftUI/UIKit picker on the study page. Keep title, values, enabled state, and counters above the framework-specific branch. Pass only the settings and callbacks each implementation needs. Update coordinator callbacks in the representable's update method, and register actions only once in its creation method.

Compare the same behavior in both implementations. Document intentional differences instead of forcing a shared abstraction across frameworks.

## 3. Register the study

In `Catalog/Study.swift`, add:

1. One stable enum case.
2. Its title, category, short summary, and SF Symbol.
3. Its destination view in the destination switch.

Add a category to `StudyCategory` only if needed. The catalog groups registered studies automatically.

## 4. Document it

Create `Documentation/Studies/<StudyName>.md` with:

- Goal and interaction
- A SwiftUI/UIKit comparison table
- Usage examples and minimum OS requirements
- Experiment or reusable status, limitations, and availability requirements
- Accessibility behavior, screenshots where useful, and inspiration/source credits

Add the study to the README table. Capture screenshots from the actual gallery and store them under `Documentation/Images/`; use relative links in public docs.

## 5. Promote for reuse

Move the reusable implementation into `Sources/StudySwiftUI/<StudyName>/` and `Sources/StudyUIKit/<StudyName>/`. Add public access only to the component and its intentional configuration API. Document public symbols and defaults.

Import the package module from the gallery and keep settings, sample content, counters, and bridges in the app. Package modules must not depend on the gallery or on each other. Avoid creating a package or module for each study.

For APIs newer than iOS 18, add `@available` to the component and a clear `if #available` fallback in its gallery destination. Preserve the existing deployment target.

## 6. Validate

1. Build each affected package product for iOS Simulator independently.
2. Build and run the gallery on iPhone and iPad.
3. Switch frameworks and confirm shared state remains intact.
4. Check enabled/disabled behavior and one action per activation.
5. Check light/dark appearance, long labels, accessibility text sizes, VoiceOver, and Reduce Motion.
6. Add focused behavioral tests when the component introduces interaction or state risks. Avoid tests that only repeat the implementation.
