import SwiftUI

/// Register each paired study once here; its destination owns the demo state.
enum Study: String, CaseIterable, Identifiable {
    case animatedButton
    case thermostatDial
    case mechanicalRocker

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .mechanicalRocker: "Mechanical rocker switch"
        case .thermostatDial: "Thermostat dial"
        case .animatedButton: "Animated button"
        }
    }

    var category: StudyCategory {
        switch self {
        case .animatedButton, .thermostatDial, .mechanicalRocker: .controls
        }
    }

    var summary: LocalizedStringResource {
        switch self {
        case .mechanicalRocker: "Three SwiftUI rendering approaches for one physical control."
        case .thermostatDial: "Circular gestures, temperature steps, and geometry explained."
        case .animatedButton: "Spring feedback, native interaction, and accessible states."
        }
    }

    var symbol: String {
        switch self {
        case .mechanicalRocker: "switch.2"
        case .thermostatDial: "thermometer.medium"
        case .animatedButton: "hand.tap"
        }
    }

    @MainActor @ViewBuilder var destination: some View {
        switch self {
        case .mechanicalRocker: MechanicalRockerSwitchStudyView()
        case .thermostatDial: ThermostatDialStudyView()
        case .animatedButton: AnimatedButtonStudyView()
        }
    }
}

enum StudyCategory: String, CaseIterable, Identifiable {
    case controls

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .controls: "Controls"
        }
    }
}
