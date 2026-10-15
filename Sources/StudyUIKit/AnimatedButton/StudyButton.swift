import UIKit

/// A native button with spring press feedback, Dynamic Type, and Reduce Motion support.
///
/// Use `setTitle(_:for:)`, `tintColor`, `isEnabled`, and standard target/action
/// or `UIAction` APIs to configure it. Titles provide the accessible name.
@MainActor
public final class StudyButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    public override var isHighlighted: Bool {
        didSet { updatePressFeedback() }
    }

    public override var isEnabled: Bool {
        didSet { updatePressFeedback() }
    }

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        setNeedsUpdateConfiguration()
    }

    public override func updateConfiguration() {
        super.updateConfiguration()
        var updated = configuration ?? .filled()
        updated.baseBackgroundColor = tintColor
        updated.baseForegroundColor = .white
        updated.background.cornerRadius = 16
        updated.cornerStyle = .fixed
        updated.titleLineBreakMode = .byWordWrapping
        updated.titleAlignment = .center
        updated.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        updated.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var attributes = incoming
            attributes.font = UIFont.preferredFont(forTextStyle: .headline)
            return attributes
        }
        configuration = updated
    }

    private func configure() {
        tintColor = .systemIndigo
        configuration = .filled()
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (button: StudyButton, _) in
            button.setNeedsUpdateConfiguration()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(motionPreferenceChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
    }

    @objc private func motionPreferenceChanged() {
        updatePressFeedback()
    }

    private func updatePressFeedback() {
        let shouldScale = isHighlighted && isEnabled && !UIAccessibility.isReduceMotionEnabled
        let target = shouldScale ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
        guard !UIAccessibility.isReduceMotionEnabled else {
            layer.removeAllAnimations()
            transform = .identity
            return
        }
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.transform = target
        }
    }
}
