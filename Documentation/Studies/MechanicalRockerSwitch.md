# Mechanical Rocker Switch

The Mechanical Rocker Switch explores one appliance-style on/off control through three SwiftUI renderers. Each renderer presents a recessed black bezel, I/O markings, and a green on indicator while using the same `Binding<Bool>` supplied by a native `Toggle`.

For a guided implementation walkthrough with renderer diagrams, focused Swift excerpts, and gallery screenshots, read the [step-by-step HTML tutorial](MechanicalRockerSwitchTutorial.html).

## Use

```swift
import SwiftUI
import StudySwiftUI

struct PowerSettings: View {
    @State private var isPowered = false

    var body: some View {
        Toggle("Main power", isOn: $isPowered)
            .toggleStyle(StudyRockerToggleStyle())
    }
}
```

Replace the style with `StudyRocker3DToggleStyle()` or `StudyRockerImageToggleStyle()` to use the same state and interaction with another renderer. All styles require iOS 18 or later.

## How it works

| Variation | Rendering | State transition | Best for |
| --- | --- | --- | --- |
| Core Graphics | SwiftUI `Canvas` forwards to a Core Graphics context. | A Boolean drives a face offset, gradients, markings, and the indicator. | Crisp scalable drawing and small asset size. |
| USDZ 3D | `RealityView` loads `MechanicalRocker.usdz` from the package bundle. | The named `RockerPivot` turns 12° in either direction while the bezel stays still. | Studying a real scene graph and physical pivot. |
| Static images | Two bundled PNG views crossfade. | The full rendered image changes after the binding changes. | Lowest update cost and fixed artwork. |

The toggle style wraps its supplied label and rocker in one native `Button`. This means a tap on either one changes the supplied Boolean exactly once. The label remains visible and provides VoiceOver’s accessible name; the style provides the current On or Off value. The enabled state comes from SwiftUI’s environment, so `disabled(_:)` blocks activation without custom hit testing.

The Core Graphics drawing works in a 116×78 design space, then derives every coordinate from the actual canvas size. The face moves six design points between states. It uses an ease-in-out transition of 180 milliseconds. When Reduce Motion is on, the transition is disabled and the final state appears immediately.

`MechanicalRocker.usda` is the editable scene source. `MechanicalRocker.usdz` is the packaged runtime model. The scene separates `Bezel` from `RockerPivot`; `RockerFace` and `Indicator` are children of the pivot. This hierarchy is why a rotation can move the mechanical face while leaving the recess fixed. The gallery falls back to the static-image renderer if the USDZ resource cannot load.

The on/off PNG artwork lives beside the model resource and depicts the same original appliance-rocker design with matching dimensions and transparent backgrounds. Regenerate the package artifact and images after editing the source files:

```sh
Tools/generate-mechanical-rocker-assets.sh
```

The SVG export sources and USD scene are original assets created for this repository and are covered by the repository’s [MIT License](../../LICENSE). No third-party asset, AR session, sound, or haptic feedback is used.

## Gallery behavior

The gallery owns the Boolean, enabled setting, and activation counter above its rendering picker. Selecting Core Graphics, USDZ 3D, or Static Images does not alter state or increment the counter. The study is intentionally SwiftUI-only: its purpose is to compare three SwiftUI rendering choices, rather than to force an unrelated UIKit pairing.

## Accessibility and limits

- The visible label follows Dynamic Type and is the accessible name for the control.
- VoiceOver announces a single toggle with its current On or Off value.
- Reduce Motion removes the 180-millisecond visual transition in each variation.
- The 3D model is an illustrative appliance control, not a safety-critical control pattern. Use a confirmation step for destructive or hazardous app actions.
