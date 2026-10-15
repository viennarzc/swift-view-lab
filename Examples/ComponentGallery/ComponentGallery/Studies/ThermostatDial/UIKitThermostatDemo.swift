import SwiftUI
import StudyUIKit

struct UIKitThermostatDemo: UIViewRepresentable {
    @Binding var temperature: Double
    let isEnabled: Bool
    let showsGeometry: Bool

    func makeCoordinator() -> Coordinator { Coordinator(temperature: $temperature) }

    func makeUIView(context: Context) -> StudyUIKit.StudyThermostatDial {
        let dial = StudyUIKit.StudyThermostatDial()
        dial.accessibilityIdentifier = "thermostatDial"
        // Register once. updateUIView runs frequently and must not add more handlers.
        dial.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        return dial
    }

    func updateUIView(_ dial: StudyUIKit.StudyThermostatDial, context: Context) {
        context.coordinator.temperature = $temperature
        dial.temperature = temperature
        dial.isEnabled = isEnabled
        dial.showsGeometry = showsGeometry
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: StudyUIKit.StudyThermostatDial, context: Context) -> CGSize? {
        let side = min(proposal.width ?? 280, proposal.height ?? 280)
        return CGSize(width: side, height: side)
    }

    @MainActor final class Coordinator: NSObject {
        var temperature: Binding<Double>
        init(temperature: Binding<Double>) { self.temperature = temperature }
        @objc func changed(_ dial: StudyUIKit.StudyThermostatDial) {
            temperature.wrappedValue = dial.temperature
        }
    }
}
