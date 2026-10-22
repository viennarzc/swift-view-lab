import SwiftUI
import StudySwiftUI

/// A SwiftUI-only rendering comparison. Each renderer receives the same binding,
/// so changing presentation never changes electrical state or increments the log.
struct MechanicalRockerSwitchStudyView: View {
    @State private var isOn = false
    @State private var isEnabled = true
    @State private var activationCount = 0
    @State private var variation = RockerVariation.coreGraphics
    @State private var modelX: Float = 0
    @State private var modelY: Float = 0
    @State private var modelZ: Float = 0
    @State private var modelPitch: Float = 0
    @State private var modelYaw: Float = 0
    @State private var modelRoll: Float = 0

    var body: some View {
        Form {
            RockerVariationSection(variation: $variation)
            RockerPreviewSection(
                variation: variation,
                isOn: $isOn,
                isEnabled: isEnabled,
                activationCount: activationCount,
                position: SIMD3(modelX, modelY, modelZ),
                rotation: SIMD3(modelPitch, modelYaw, modelRoll)
            )
            if variation == .model3D {
                Rocker3DTransformSection(
                    modelX: $modelX,
                    modelY: $modelY,
                    modelZ: $modelZ,
                    modelPitch: $modelPitch,
                    modelYaw: $modelYaw,
                    modelRoll: $modelRoll
                )
            }
            RockerSettingsSection(
                isEnabled: $isEnabled,
                reset: reset
            )
            RockerImplementationNotes(variation: variation)
        }
        .onChange(of: isOn) { _, _ in
            activationCount += 1
        }
        .navigationTitle("Mechanical rocker")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func reset() {
        isOn = false
        activationCount = 0
        modelX = 0
        modelY = 0
        modelZ = 0
        modelPitch = 0
        modelYaw = 0
        modelRoll = 0
    }
}

private enum RockerVariation: String, CaseIterable, Identifiable {
    case coreGraphics = "Core Graphics"
    case model3D = "USDZ 3D"
    case staticImages = "Static images"

    var id: String { rawValue }
}

private struct RockerVariationSection: View {
    @Binding var variation: RockerVariation

    var body: some View {
        Section("Rendering") {
            Picker("Variation", selection: $variation) {
                ForEach(RockerVariation.allCases) { variation in
                    Text(variation.rawValue).tag(variation)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct RockerPreviewSection: View {
    let variation: RockerVariation
    @Binding var isOn: Bool
    let isEnabled: Bool
    let activationCount: Int
    let position: SIMD3<Float>
    let rotation: SIMD3<Float>

    var body: some View {
        Section("Live preview") {
            RockerTogglePreview(
                variation: variation,
                isOn: $isOn,
                isEnabled: isEnabled,
                position: position,
                rotation: rotation
            )
                .padding(.vertical, 18)
            LabeledContent("State", value: isOn ? "On" : "Off")
            LabeledContent("Activations") {
                Text(activationCount, format: .number)
                    .monospacedDigit()
                    .accessibilityIdentifier("rockerActivationCount")
            }
            Text("Tap the rocker or its label to change power.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

}

private struct RockerTogglePreview: View {
    let variation: RockerVariation
    @Binding var isOn: Bool
    let isEnabled: Bool
    let position: SIMD3<Float>
    let rotation: SIMD3<Float>

    @ViewBuilder var body: some View {
        switch variation {
        case .coreGraphics:
            Toggle("Main power", isOn: $isOn)
                .toggleStyle(StudyRockerToggleStyle())
                .disabled(!isEnabled)
        case .model3D:
            Toggle("Main power", isOn: $isOn)
                .toggleStyle(StudyRocker3DToggleStyle(position: position, rotation: rotation))
                .disabled(!isEnabled)
        case .staticImages:
            Toggle("Main power", isOn: $isOn)
                .toggleStyle(StudyRockerImageToggleStyle())
                .disabled(!isEnabled)
        }
    }
}

private struct Rocker3DTransformSection: View {
    @Binding var modelX: Float
    @Binding var modelY: Float
    @Binding var modelZ: Float
    @Binding var modelPitch: Float
    @Binding var modelYaw: Float
    @Binding var modelRoll: Float

    var body: some View {
        Section("3D transform") {
            RockerTransformSlider("Position X", value: $modelX, range: -0.6...0.6)
            RockerTransformSlider("Position Y", value: $modelY, range: -0.6...0.6)
            RockerTransformSlider("Position Z", value: $modelZ, range: -0.6...0.6)
            RockerTransformSlider("Pitch", value: $modelPitch, range: -180...180, suffix: "°")
            RockerTransformSlider("Yaw", value: $modelYaw, range: -180...180, suffix: "°")
            RockerTransformSlider("Roll", value: $modelRoll, range: -180...180, suffix: "°")
        }
    }
}

private struct RockerTransformSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let suffix: String

    init(
        _ title: String,
        value: Binding<Float>,
        range: ClosedRange<Float>,
        suffix: String = ""
    ) {
        self.title = title
        _value = value
        self.range = range
        self.suffix = suffix
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            LabeledContent(title) {
                Text(value, format: .number.precision(.fractionLength(2)))
                    .monospacedDigit()
                    + Text(suffix)
            }
            Slider(value: $value, in: range)
                .accessibilityValue("\(value.formatted(.number.precision(.fractionLength(2))))\(suffix)")
        }
    }
}

private struct RockerSettingsSection: View {
    @Binding var isEnabled: Bool
    let reset: () -> Void

    var body: some View {
        Section("Try a variation") {
            Toggle("Rocker enabled", isOn: $isEnabled)
            Button("Reset power and activations", action: reset)
        }
    }
}

private struct RockerImplementationNotes: View {
    let variation: RockerVariation

    var body: some View {
        Section("Implementation notes") {
            Text(variationNote)
            Text("All three styles are ordinary SwiftUI ToggleStyle values. The gallery owns the Boolean, enabled state, and activation log, so changing a renderer preserves the switch state.")
            Text("Reduce Motion changes state without the 180-millisecond transition. The label stays inside the native Button used by each style, which preserves its accessible name and value.")
                .foregroundStyle(.secondary)
        }
    }

    private var variationNote: String {
        switch variation {
        case .coreGraphics:
            "Canvas forwards to Core Graphics. A normalized state controls the face offset, gradient direction, I/O markings, and indicator brightness at any size."
        case .model3D:
            "RealityKit loads the packaged USDZ scene asynchronously. The named RockerPivot node turns ±12° while the bezel remains fixed; the static image renderer covers a resource-loading failure."
        case .staticImages:
            "Two bundled PNG views of the rocker crossfade. This is the least expensive option because it has no geometry or 3D scene to update."
        }
    }
}

#Preview {
    NavigationStack {
        MechanicalRockerSwitchStudyView()
    }
}
