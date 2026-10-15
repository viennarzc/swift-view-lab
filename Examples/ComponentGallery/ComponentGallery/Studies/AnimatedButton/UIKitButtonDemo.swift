import SwiftUI
import StudyUIKit

struct UIKitButtonDemo: UIViewRepresentable {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeUIView(context: Context) -> StudyButton {
        let button = StudyButton(frame: .zero)
        button.accessibilityIdentifier = "studyButton"
        button.addTarget(context.coordinator, action: #selector(Coordinator.activate), for: .primaryActionTriggered)
        return button
    }

    func updateUIView(_ button: StudyButton, context: Context) {
        context.coordinator.action = action
        button.setTitle(title, for: .normal)
        button.isEnabled = isEnabled
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: StudyButton, context: Context) -> CGSize? {
        let width = proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? uiView.intrinsicContentSize.width
        let insets = uiView.configuration?.contentInsets ?? .zero
        let labelWidth = max(1, width - insets.leading - insets.trailing)
        // UIButton's unconstrained intrinsic width can exceed SwiftUI's proposal.
        // Measure the wrapping label and return the proposed width explicitly.
        let labelSize = uiView.titleLabel?.sizeThatFits(
            CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        ) ?? .zero
        return CGSize(width: width, height: max(52, ceil(labelSize.height + insets.top + insets.bottom)))
    }

    @MainActor final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func activate() { action() }
    }
}
