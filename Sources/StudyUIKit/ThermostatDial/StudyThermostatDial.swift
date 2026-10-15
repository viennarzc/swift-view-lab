import UIKit

/// A 270-degree Celsius selector. User changes emit `.valueChanged`; assignments do not.
@MainActor public final class StudyThermostatDial: UIControl {
    private var scale: ThermostatScale
    private var storedTemperature: Double
    private var drag = ThermostatDrag()
    private let track = CAShapeLayer()
    private let ticks = CAShapeLayer()
    private let progress = CAShapeLayer()
    private let indicator = CAShapeLayer()
    private let geometry = CAShapeLayer()
    private let readout: RollingTemperatureReadout
    private let caption = UILabel()
    private let feedback = UISelectionFeedbackGenerator()

    /// Finite, increasing range, fixed for this control's lifetime.
    public var range: ClosedRange<Double> { scale.range }
    /// Step divides the range span into 1...1000 steps.
    public var step: Double { scale.step }
    /// Values are snapped and clamped; nonfinite values become the minimum.
    public var temperature: Double {
        get { storedTemperature }
        set { storedTemperature = scale.snapped(newValue); setNeedsLayout() }
    }
    /// Draws the center and raw touch direction for learning/debugging.
    public var showsGeometry = false { didSet { setNeedsLayout() } }
    public override var isEnabled: Bool { didSet { setNeedsLayout() } }
    /// UIKit's natural size is a square; callers can still constrain it smaller or larger.
    public override var intrinsicContentSize: CGSize { CGSize(width: 280, height: 280) }

    /// Range must be finite and increasing; step must divide its span into 1...1000 steps.
    public init(temperature: Double = 22, range: ClosedRange<Double> = 16...30, step: Double = 0.5) {
        // Validate and retain scale configuration before building the readout's digit slots.
        scale = ThermostatScale(range: range, step: step)
        readout = RollingTemperatureReadout(range: range)
        storedTemperature = scale.snapped(temperature)
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        scale = ThermostatScale(range: 16...30, step: 0.5)
        readout = RollingTemperatureReadout(range: 16...30)
        storedTemperature = 22
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Install each drawing layer and label once. Later layout passes only update geometry.
        tintColor = .systemIndigo
        isAccessibilityElement = true
        accessibilityLabel = "Temperature"
        for shape in [track, ticks, progress, indicator, geometry] {
            shape.fillColor = UIColor.clear.cgColor
            layer.addSublayer(shape)
        }
        readout.isUserInteractionEnabled = false
        addSubview(readout)
        caption.textAlignment = .center
        caption.adjustsFontForContentSizeCategory = true
        caption.adjustsFontSizeToFitWidth = true
        caption.minimumScaleFactor = 0.5
        caption.isUserInteractionEnabled = false
        addSubview(caption)
        registerForTraitChanges([UITraitUserInterfaceStyle.self, UITraitPreferredContentSizeCategory.self]) {
            (self: StudyThermostatDial, _: UITraitCollection) in self.setNeedsLayout()
        }
    }

    public override func tintColorDidChange() { super.tintColorDidChange(); setNeedsLayout() }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // UIKit calls this after size, trait, or value changes. Recompute all paths from
        // bounds, then update the readout and the single spoken accessibility value.
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = max(1, min(bounds.width, bounds.height) / 2 - 24)
        // Progress is 0...1; strokeEnd and the indicator position share that fraction.
        let fraction = scale.progress(temperature)
        let angle = 135 + fraction * 270
        // Disable layer animations so the arc and handle follow touch directly.
        // The temperature digits animate independently below.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let arc = UIBezierPath(arcCenter: center, radius: radius, startAngle: 135 * .pi / 180,
                               endAngle: 405 * .pi / 180, clockwise: true)
        for shape in [track, progress] {
            shape.path = arc.cgPath
            shape.lineWidth = 12
            shape.lineCap = .round
        }
        track.strokeColor = UIColor.label.withAlphaComponent(0.1).cgColor
        progress.strokeColor = tintColor.cgColor
        progress.strokeEnd = fraction
        let tickPath = UIBezierPath()
        for index in 0...28 {
            let angle = 135 + Double(index) / 28 * 270
            tickPath.move(to: ThermostatScale.point(angle: angle, radius: radius - 16, center: center))
            tickPath.addLine(to: ThermostatScale.point(angle: angle, radius: radius - (index.isMultiple(of: 2) ? 25 : 21), center: center))
        }
        ticks.path = tickPath.cgPath
        ticks.strokeColor = UIColor.secondaryLabel.withAlphaComponent(0.5).cgColor
        ticks.lineWidth = 1.5
        let position = ThermostatScale.point(angle: angle, radius: radius, center: center)
        indicator.path = UIBezierPath(ovalIn: CGRect(x: position.x - 12, y: position.y - 12, width: 24, height: 24)).cgPath
        indicator.fillColor = UIColor.systemBackground.cgColor
        indicator.strokeColor = tintColor.cgColor
        indicator.lineWidth = 4
        let guide = UIBezierPath()
        guide.move(to: center)
        guide.addLine(to: ThermostatScale.point(angle: 135 + (drag.angle ?? fraction * 270), radius: radius, center: center))
        guide.append(UIBezierPath(ovalIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)))
        geometry.path = guide.cgPath
        geometry.strokeColor = UIColor.systemOrange.cgColor
        geometry.lineDashPattern = [4, 4]
        geometry.isHidden = !showsGeometry
        CATransaction.commit()
        readout.update(temperature, reduceMotion: UIAccessibility.isReduceMotionEnabled)
        readout.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        caption.font = UIFont.preferredFont(forTextStyle: .caption1)
        caption.textColor = .secondaryLabel
        let width = radius * 1.35
        let titleHeight = min(readout.font.lineHeight, radius * 0.65)
        let captionHeight = min(caption.font.lineHeight, radius * 0.3)
        readout.frame = CGRect(x: center.x - width / 2, y: center.y - (titleHeight + captionHeight + 4) / 2, width: width, height: titleHeight)
        caption.frame = CGRect(x: center.x - width / 2, y: readout.frame.maxY + 4, width: width, height: captionHeight)
        alpha = isEnabled ? 1 : 0.4
        accessibilityTraits = isEnabled ? [.adjustable] : [.adjustable, .notEnabled]
        accessibilityValue = "\(temperature.formatted()) degrees Celsius"
    }

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Accept a touch only near the visible arc. ThermostatDrag also rejects its gap.
        guard isEnabled else { return false }
        let point = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 24
        guard abs(hypot(point.x - center.x, point.y - center.y) - radius) <= 28,
              drag.begin(ThermostatScale.angle(at: point, center: center)) else { return false }
        feedback.prepare()
        select(scale.value(at: drag.angle!))
        return true
    }

    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // Keep tracking outside the ring, but pause across the center so its angle
        // cannot create a spurious half-turn jump.
        guard isEnabled else { return false }
        let point = touch.location(in: self)
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 24
        guard hypot(point.x - center.x, point.y - center.y) >= radius - 28 else { drag.pause(); return true }
        drag.move(ThermostatScale.angle(at: point, center: center))
        if let angle = drag.angle { select(scale.value(at: angle)) }
        setNeedsLayout()
        return true
    }

    // Reset the unwrapped angle at the end of every touch; the next touch starts fresh.
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) { drag = ThermostatDrag(); setNeedsLayout() }
    public override func cancelTracking(with event: UIEvent?) { drag = ThermostatDrag(); setNeedsLayout() }

    /// VoiceOver advances by one configured step through the same event-emitting path.
    public override func accessibilityIncrement() { select(temperature + step) }
    /// VoiceOver decreases by one configured step through the same event-emitting path.
    public override func accessibilityDecrement() { select(temperature - step) }

    /// Apply a user change once. Programmatic property assignments only redraw and do
    /// not send `.valueChanged`, preventing feedback loops in SwiftUI bridges.
    private func select(_ value: Double) {
        guard isEnabled else { return }
        let next = scale.snapped(value)
        guard next != temperature else { return }
        temperature = next
        feedback.selectionChanged()
        // Only this user-input path emits events; assignments from the SwiftUI
        // bridge cannot echo back into its binding and create duplicate changes.
        sendActions(for: .valueChanged)
    }
}


/// A locale-aware number strip whose decimal separator and degree mark stay fixed.
@MainActor private final class RollingTemperatureReadout: UIView {
    private let digitColumns: [RollingDigitColumn]
    private let sign = UILabel()
    private let fractionColumn = RollingDigitColumn()
    private let separator = UILabel()
    private let degree = UILabel()
    private let row = UIStackView()
    private let formatter = NumberFormatter()
    private let decimalSeparator = Locale.current.decimalSeparator ?? "."
    private var current: Double?
    var font = UIFont.preferredFont(forTextStyle: .largeTitle) { didSet { updateFonts() } }

    override var intrinsicContentSize: CGSize {
        row.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    init(range: ClosedRange<Double>) {
        let largestMagnitude = max(abs(range.lowerBound), abs(range.upperBound))
        let integerWidth = max(1, String(Int(largestMagnitude)).count)
        digitColumns = (0..<integerWidth).map { _ in RollingDigitColumn() }
        super.init(frame: .zero)
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 0
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor), row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: topAnchor), row.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        sign.text = "−"
        sign.textAlignment = .center
        sign.isHidden = range.lowerBound >= 0
        row.addArrangedSubview(sign)
        digitColumns.forEach { row.addArrangedSubview($0) }
        separator.text = decimalSeparator
        separator.textAlignment = .center
        row.addArrangedSubview(separator)
        row.addArrangedSubview(fractionColumn)
        degree.text = "°"
        degree.textAlignment = .center
        row.addArrangedSubview(degree)
        isAccessibilityElement = false // The parent control speaks only its final value.
        updateFonts()
    }

    required init?(coder: NSCoder) { fatalError("Use init(temperature:range:step:)") }

    /// Split a formatted temperature into stable integer, separator, tenths, and degree slots.
    /// Only the digit whose character changed receives a transition.
    func update(_ value: Double, reduceMotion: Bool) {
        // layoutSubviews can run repeatedly while a digit is still animating.
        guard current != value else { return }
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "0"
        let parts = formatted.components(separatedBy: decimalSeparator)
        let wholePart = parts.first ?? "0"
        sign.isHidden = !wholePart.hasPrefix("-") && !wholePart.hasPrefix("−")
        // Align integer digits from the right so carries such as 19 → 20 affect
        // their own columns instead of shifting the whole string.
        let digits = wholePart.compactMap(\.wholeNumberValue)
        let prefixCount = max(0, digitColumns.count - digits.count)
        let isInitial = current == nil
        let direction: CGFloat = value >= (current ?? value) ? 1 : -1
        for index in digitColumns.indices {
            if index < prefixCount {
                digitColumns[index].setDigit("0", visible: false, direction: direction,
                                             animated: false, reduceMotion: reduceMotion)
            } else {
                let digit = digits[index - prefixCount]
                let visible = digit != 0 || index == digitColumns.count - 1
                digitColumns[index].setDigit(String(digit), visible: visible, direction: direction,
                                             animated: !isInitial, reduceMotion: reduceMotion)
            }
        }
        // Reserve a hidden fractional slot for whole values; showing .5 later does
        // not move the integer columns or degree mark sideways.
        let hasFraction = parts.count > 1 && !parts[1].isEmpty
        separator.isHidden = !hasFraction
        fractionColumn.setDigit(hasFraction ? String(parts[1].prefix(1)) : "0", visible: hasFraction,
                                direction: direction, animated: !isInitial, reduceMotion: reduceMotion)
        current = value
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private func updateFonts() {
        sign.font = font
        digitColumns.forEach { $0.font = font }
        fractionColumn.font = font
        separator.font = font
        degree.font = font
        invalidateIntrinsicContentSize()
    }
}

@MainActor private final class RollingDigitColumn: UIView {
    private let label = UILabel()
    private var incomingLabel: UILabel?
    private var animationID = 0
    var font = UIFont.preferredFont(forTextStyle: .largeTitle) {
        didSet { label.font = font; incomingLabel?.font = font; invalidateIntrinsicContentSize() }
    }
    override var intrinsicContentSize: CGSize {
        let width = ("8" as NSString).size(withAttributes: [.font: font]).width
        return CGSize(width: ceil(width), height: ceil(font.lineHeight))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        label.textAlignment = .center
        label.font = font
        addSubview(label)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is unavailable") }

    /// Roll one changed numeral vertically, or cross-fade it when Reduce Motion is on.
    func setDigit(_ digit: String, visible: Bool, direction: CGFloat, animated: Bool, reduceMotion: Bool) {
        guard label.text != digit || label.isHidden == visible else { return }
        animationID += 1
        let thisAnimation = animationID
        // Rapid drags may select another step before the previous roll finishes.
        // Settle the old slot first so stale completions cannot replace the new value.
        incomingLabel?.layer.removeAllAnimations()
        incomingLabel?.removeFromSuperview()
        incomingLabel = nil
        label.layer.removeAllAnimations()
        label.transform = .identity
        guard animated, window != nil else {
            label.text = digit
            label.isHidden = !visible
            label.transform = .identity
            setNeedsLayout()
            return
        }
        if reduceMotion {
            UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve) {
                self.label.text = digit
                self.label.isHidden = !visible
            }
            return
        }
        let next = UILabel()
        next.text = digit
        next.textAlignment = .center
        next.font = font
        next.isHidden = !visible
        addSubview(next)
        incomingLabel = next
        next.frame = bounds
        next.transform = CGAffineTransform(translationX: 0, y: direction * bounds.height)
        // Upward motion means the next value increased; downward means it decreased.
        UIView.animate(withDuration: 0.24, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut]) {
            self.label.transform = CGAffineTransform(translationX: 0, y: -direction * self.bounds.height)
            next.transform = .identity
        } completion: { _ in
            // An older animation may finish after a fast drag selected a newer digit.
            guard self.animationID == thisAnimation else { return }
            self.label.text = digit
            self.label.isHidden = !visible
            self.label.transform = .identity
            next.removeFromSuperview()
            self.incomingLabel = nil
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        incomingLabel?.frame = bounds
    }
}
