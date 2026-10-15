import SwiftUI
import StudySwiftUI

struct AnimatedButtonStudyView: View {
    @State private var framework = DemoFramework.swiftUI
    @State private var title = "Count a tap"
    @State private var isEnabled = true
    @State private var actionCount = 0

    var body: some View {
        Form {
            Section("Implementation") {
                Picker("Framework", selection: $framework) {
                    ForEach(DemoFramework.allCases) { framework in
                        Text(framework.rawValue).tag(framework)
                    }
                }
                .pickerStyle(.segmented)
            }
            Section("Live preview") {
                AnimatedButtonPreview(
                    framework: framework,
                    title: title,
                    isEnabled: isEnabled
                ) {
                    actionCount += 1
                }
                LabeledContent("Actions") {
                    Text(actionCount, format: .number)
                        .monospacedDigit()
                        .accessibilityIdentifier("actionCount")
                }
            }
            Section("Try a variation") {
                TextField("Button title", text: $title)
                    .accessibilityLabel("Button title")
                    .accessibilityIdentifier("buttonTitle")
                Toggle("Button enabled", isOn: $isEnabled)
                Button("Reset action count") { actionCount = 0 }
            }
            ButtonImplementationNotes(framework: framework)
        }
        .navigationTitle("Animated button")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum DemoFramework: String, CaseIterable, Identifiable {
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"

    var id: String { rawValue }
}

private struct AnimatedButtonPreview: View {
    let framework: DemoFramework
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            switch framework {
            case .swiftUI:
                Button(action: action) {
                    Text(verbatim: title).frame(maxWidth: .infinity)
                }
                    .buttonStyle(StudyButtonStyle())
                    .disabled(!isEnabled)
                    .accessibilityIdentifier("studyButton")
            case .uiKit:
                UIKitButtonDemo(title: title, isEnabled: isEnabled, action: action)
            }
        }
        .padding(.vertical, 44)
    }
}

private struct ButtonImplementationNotes: View {
    let framework: DemoFramework

    var body: some View {
        Section("Implementation notes") {
            switch framework {
            case .swiftUI:
                Text("A native Button uses StudyButtonStyle. The style reads pressed, enabled, and Reduce Motion states from SwiftUI.")
            case .uiKit:
                Text("StudyButton subclasses UIButton. Highlight changes drive its spring animation; native actions and enabled behavior stay with UIKit.")
            }
            Text("Both versions use a 0.96 press scale, support Dynamic Type and VoiceOver, and suppress scale animation when Reduce Motion is enabled.")
            Text("The gallery owns the title, enabled state, and counter, so your settings survive framework changes.")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        AnimatedButtonStudyView()
    }
}
