# Components Studies

A small laboratory for custom iOS interfaces: the same idea explored in **SwiftUI and UIKit**, with reusable components you can bring into your own apps.

## Requirements

- Xcode 16 or later, Swift 6, and an iOS Simulator runtime
- iOS 18 or later; iPhone and iPad
- No third-party dependencies or Apple developer team needed for simulator builds

## Run the gallery

1. Clone or download this repository.
2. Open `Examples/ComponentGallery/ComponentGallery.xcodeproj` in Xcode.
3. Select the **ComponentGallery** scheme and an iPhone or iPad simulator, then Run.
4. Open **Animated button** and switch between SwiftUI and UIKit. Title, enabled state, and action count stay shared.

For a physical device, choose your own development team and a unique bundle identifier in the app target's Signing & Capabilities settings.

<img src="Documentation/Images/animated-button-swiftui.png" width="320" alt="The component gallery showing the SwiftUI animated button study">

## Studies

| Study | SwiftUI | UIKit | Status |
| --- | --- | --- | --- |
| [Animated button](Documentation/Studies/AnimatedButton.md) | `StudyButtonStyle` | `StudyButton` | Reusable, experimental API |

Experiments live in the gallery. Components promoted for reuse live in the package. APIs may change before the first stable release.

## Use the components

### Local checkout

In your app's Xcode project, select **File → Add Package Dependencies → Add Local**, choose this repository's root directory, and add `StudySwiftUI`, `StudyUIKit`, or both to your app target.

### Once this repository is published

In **File → Add Package Dependencies**, paste this repository's GitHub clone URL. Until a version is tagged, select the `main` branch. After a release is tagged, use its version rule. There is no remote repository or release configured by this scaffold.

```swift
import SwiftUI
import StudySwiftUI

struct ExampleView: View {
    var body: some View {
        Button("Continue") {
            // Perform your action.
        }
        .buttonStyle(StudyButtonStyle())
    }
}
```

```swift
import UIKit
import StudyUIKit

@MainActor
func makeButton() -> StudyButton {
    let button = StudyButton(frame: .zero)
    button.setTitle("Continue", for: .normal)
    button.addAction(UIAction { _ in
        // Perform your action.
    }, for: .primaryActionTriggered)
    return button
}
```

Each library is independent. SwiftUI/UIKit bridging belongs to the gallery or your consuming app.

## Repository map

| Location | Responsibility |
| --- | --- |
| `Package.swift`, `Sources/` | Reusable libraries and their public APIs |
| `Examples/ComponentGallery/` | Runnable gallery, demo settings, and experiments |
| `Documentation/Studies/` | Study explanations, examples, and credits |
| [AddingAStudy.md](Documentation/AddingAStudy.md) | Step-by-step workflow for the next study |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution and review expectations |

## Build and verify

Run these commands from the repository root:

```sh
xcodebuild -scheme StudySwiftUI -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -scheme StudyUIKit -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Examples/ComponentGallery/ComponentGallery.xcodeproj -scheme ComponentGallery -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build-for-testing
```

Run the shared scheme's UI test in Xcode with **Product → Test** on an iPhone and an iPad simulator. It checks single action delivery, shared state when switching frameworks, and disabled state in both versions.

Before contributing, also check light/dark appearance, larger accessibility text, VoiceOver, and Reduce Motion. The GitHub Actions workflow builds both libraries separately and compiles the gallery and UI tests; it does not execute simulator tests.

## Public release checklist

1. Review source, screenshots, and attribution.
2. Create an empty public GitHub repository named `Components-Studies`.
3. Add its clone URL as this repository's `origin`, then push `main`.
4. Confirm the Build workflow passes.
5. Tag a release when you are ready to offer version-based package installation.

## License

[MIT](LICENSE), copyright © 2026 Viennarz Curtiz. Credit external inspiration in each study's documentation; include source licenses when required.
