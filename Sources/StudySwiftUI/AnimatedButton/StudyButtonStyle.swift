import SwiftUI

/// A filled button style with spring press feedback and a 52-point minimum height.
///
/// Apply this style to a native `Button` to preserve its activation and
/// accessibility behavior. It reads enabled and Reduce Motion settings from
/// the environment. The label controls its accessible name.
public struct StudyButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let tint: Color

    /// Creates a style using the supplied background color.
    public init(tint: Color = .indigo) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .foregroundStyle(.white)
            .background(tint, in: RoundedRectangle(cornerRadius: 16))
            .opacity(isEnabled ? 1 : 0.4)
            .scaleEffect(configuration.isPressed && !reduceMotion && isEnabled ? 0.96 : 1)
            .animation(
                reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.7),
                value: configuration.isPressed
            )
    }
}
