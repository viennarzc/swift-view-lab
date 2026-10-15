import SwiftUI
import StudySwiftUI

struct ThermostatDialStudyView: View {
    // State lives above the framework branch; replacing a renderer never resets it.
    @State private var temperature = 22.0
    @State private var framework = DemoFramework.swiftUI
    @State private var isEnabled = true
    @State private var showsGeometry = false

    var body: some View {
        Form {
            Section("Implementation") {
                Picker("Framework", selection: $framework) {
                    ForEach(DemoFramework.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
            }
            Section("Live preview") {
                ThermostatPreview(temperature: $temperature, framework: framework,
                                  isEnabled: isEnabled, showsGeometry: showsGeometry)
                LabeledContent("Selected", value: "\(temperature.formatted())°C")
                    .accessibilityIdentifier("selectedTemperature")
                Text("Drag along the ring. Each step changes the temperature by 0.5°C.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Try a variation") {
                Toggle("Dial enabled", isOn: $isEnabled)
                Toggle("Show geometry", isOn: $showsGeometry)
                Button("Reset to 22°C") { temperature = 22 }
            }
            if showsGeometry { ThermostatGeometryNotes(temperature: temperature) }
            ThermostatImplementationNotes(framework: framework)
        }
        .navigationTitle("Thermostat dial")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ThermostatPreview: View {
    @Binding var temperature: Double
    let framework: DemoFramework
    let isEnabled: Bool
    let showsGeometry: Bool

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Group {
                switch framework {
                case .swiftUI:
                    StudySwiftUI.StudyThermostatDial(temperature: $temperature, showsGeometry: showsGeometry)
                        .disabled(!isEnabled)
                        .accessibilityIdentifier("thermostatDial")
                case .uiKit:
                    UIKitThermostatDemo(temperature: $temperature, isEnabled: isEnabled, showsGeometry: showsGeometry)
                }
            }.frame(maxWidth: 320).aspectRatio(1, contentMode: .fit)
            Spacer(minLength: 0)
        }.padding(.vertical, 8)
    }
}

private struct ThermostatGeometryNotes: View {
    let temperature: Double
    var body: some View {
        Section("Geometry explained") {
            LabeledContent("Progress", value: ((temperature - 16) / 14).formatted(.percent.precision(.fractionLength(1))))
            LabeledContent("Selected angle", value: "\(((temperature - 16) / 14 * 270).formatted(.number.precision(.fractionLength(1))))°")
            Text("The orange dot marks the center; the dashed line follows the touch direction while dragging. Angles start at the lower-left endpoint. The selected angle clamps to 0–270° even when the finger enters the gap.")
        }
    }
}

private struct ThermostatImplementationNotes: View {
    let framework: DemoFramework
    var body: some View {
        Section("Implementation notes") {
            Text(framework == .swiftUI
                 ? "SwiftUI Shapes draw the arc and ticks. A binding sends selected values back to this page."
                 : "Core Graphics paths describe the geometry. Shape layers draw it, and UIControl sends valueChanged only for user changes.")
            Text("Touch → offset from center → atan2 angle → arc progress → temperature → nearest 0.5°C step.")
            Text("Continuous angle tracking prevents the bottom gap from jumping between 16°C and 30°C. VoiceOver adjusts one step at a time. The value rolls one digit at a time; Reduce Motion switches the number to a brief fade. The arc and handle still follow touch directly.")
        }
    }
}
