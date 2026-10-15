import SwiftUI

/// Register each paired study once here; its destination owns the demo state.
enum Study: String, CaseIterable, Identifiable {
    case animatedButton
    case thermostatDial

    var id: String { rawValue }

    var title: LocalizedStringResource {
        switch self {
        case .thermostatDial: "Thermostat dial"
        case .animatedButton: "Animated button"
        }
    }

    var category: StudyCategory {
        switch self {
        case .animatedButton, .thermostatDial: .controls
        }
    }

    var summary: LocalizedStringResource {
        switch self {
        case .thermostatDial: "Circular gestures, temperature steps, and geometry explained."
        case .animatedButton: "Spring feedback, native interaction, and accessible states."
        }
    }

    var symbol: String {
        switch self {
        case .thermostatDial: "thermometer.medium"
        case .animatedButton: "hand.tap"
        }
    }

    @MainActor @ViewBuilder var destination: some View {
        switch self {
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
