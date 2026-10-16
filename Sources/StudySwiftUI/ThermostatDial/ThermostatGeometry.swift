import Foundation

// Intentionally mirrored in both independent products. Keep behavior tests in parity.
struct ThermostatScale {
    let range: ClosedRange<Double>
    let step: Double
    static let start = 135.0
    static let sweep = 270.0

    /// Reject configurations the rounding math cannot represent safely.
    init(range: ClosedRange<Double>, step: Double) {
        let span = range.upperBound - range.lowerBound
        precondition(range.lowerBound.isFinite && range.upperBound.isFinite && span.isFinite && span > 0)
        precondition(step.isFinite && step > 0 && step <= span)
        // Whole steps make both endpoints reachable with accessibility adjustments.
        precondition(abs(span / step - (span / step).rounded()) < 0.000001 && span / step <= 1000)
        self.range = range
        self.step = step
    }

    /// Clamp first, then round the distance from the lower bound to the nearest step.
    func snapped(_ value: Double) -> Double {
        let finite = value.isFinite ? value : range.lowerBound
        let clamped = min(range.upperBound, max(range.lowerBound, finite))
        return min(range.upperBound, max(range.lowerBound,
            range.lowerBound + ((clamped - range.lowerBound) / step).rounded() * step))
    }

    /// Map a valid temperature linearly to the dial's normalized 0...1 sweep.
    func progress(_ value: Double) -> Double {
        (snapped(value) - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    /// Convert a continuous relative angle into a clamped, snapped temperature.
    func value(at angle: Double) -> Double {
        let progress = min(1, max(0, angle / Self.sweep))
        return snapped(range.lowerBound + progress * (range.upperBound - range.lowerBound))
    }

    /// Convert a screen-space angle and radius into an x/y point around the dial center.
    static func point(angle: Double, radius: Double, center: CGPoint) -> CGPoint {
        let radians = angle * .pi / 180
        return CGPoint(x: center.x + cos(radians) * radius, y: center.y + sin(radians) * radius)
    }

    /// Return a normalized angle relative to the arc's lower-left start point.
    static func angle(at point: CGPoint, center: CGPoint) -> Double {
        // Screen y increases downward, so atan2 advances clockwise on screen.
        let degrees = atan2(point.y - center.y, point.x - center.x) * 180 / .pi
        return (degrees - start + 720).truncatingRemainder(dividingBy: 360)
    }
}

struct ThermostatDrag {
    private(set) var angle: Double?
    private var previous: Double?

    /// Start a gesture only on the active arc; the missing quadrant is not selectable.
    mutating func begin(_ relativeAngle: Double) -> Bool {
        guard relativeAngle <= ThermostatScale.sweep else { return false }
        angle = relativeAngle
        previous = relativeAngle
        return true
    }

    /// Add the shortest angular change to the unwrapped position to avoid 360° jumps.
    mutating func move(_ relativeAngle: Double) {
        guard let previous, let angle else { self.previous = relativeAngle; return }
        // Unwrap 359° → 1° into +2°, not -358°. Retain overshoot in the gap,
        // so the value stays pinned until the finger returns to the active arc.
        var delta = relativeAngle - previous
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        self.angle = angle + delta
        self.previous = relativeAngle
    }

    /// Drop the angle baseline while a finger crosses the center dead zone.
    mutating func pause() { previous = nil }
}
