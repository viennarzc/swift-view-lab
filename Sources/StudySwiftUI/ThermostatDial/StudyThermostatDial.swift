import SwiftUI

/// A clockwise, 270-degree Celsius selector. Give it a square frame (at least 240 points).
public struct StudyThermostatDial: View {
    @Binding private var temperature: Double
    private let scale: ThermostatScale
    private let showsGeometry: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drag = ThermostatDrag()
    @State private var started = false
    @State private var feedback = 0

    /// Range must be finite and increasing; step must divide its span into 1...1000 steps.
    /// Out-of-range values are displayed clamped and snapped; nonfinite values display the minimum.
    /// The binding is written only in response to user interaction.
    public init(temperature: Binding<Double>, range: ClosedRange<Double> = 16...30,
                step: Double = 0.5, showsGeometry: Bool = false) {
        _temperature = temperature
        scale = ThermostatScale(range: range, step: step)
        self.showsGeometry = showsGeometry
    }

    public var body: some View {
        GeometryReader { geometry in
            // Derive every visual position from the same square, center, and radius.
            // Keeping this geometry in one place makes drawing and touch mapping agree.
            let side = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = max(1, side / 2 - 24)
            // Convert the bound value to normalized progress, then back into the arc's angle.
            let progress = scale.progress(temperature)
            let angle = ThermostatScale.start + progress * ThermostatScale.sweep
            ZStack {
                DialArc(progress: 1).stroke(.primary.opacity(0.1), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                DialTicks().stroke(.secondary.opacity(0.5), lineWidth: 1.5)
                DialArc(progress: progress).stroke(.tint, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                Circle().fill(.background).frame(width: 24, height: 24)
                    .overlay(Circle().stroke(.tint, lineWidth: 4))
                    .position(ThermostatScale.point(angle: angle, radius: radius, center: center))
                DialReadout(value: scale.snapped(temperature), reduceMotion: reduceMotion)
                    .frame(width: radius * 1.35)
                if showsGeometry {
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: ThermostatScale.point(
                            angle: ThermostatScale.start + (drag.angle ?? progress * 270), radius: radius, center: center))
                    }.stroke(.orange, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    Circle().fill(.orange).frame(width: 6, height: 6).position(center)
                }
            }
            .contentShape(DialTouchRing())
            .gesture(DragGesture(minimumDistance: 0).onChanged { event in
                // Begin only on the ring; after that, track the finger until it enters
                // the center dead zone or the gesture ends.
                guard isEnabled else { return }
                let distance = hypot(event.location.x - center.x, event.location.y - center.y)
                if !started {
                    started = true
                    let startDistance = hypot(event.startLocation.x - center.x, event.startLocation.y - center.y)
                    guard abs(startDistance - radius) <= 28 else { return }
                    // The drag helper rejects starts in the 90-degree gap.
                    guard drag.begin(ThermostatScale.angle(at: event.startLocation, center: center)) else { return }
                }
                guard drag.angle != nil else { return }
                guard distance >= radius - 28 else { drag.pause(); return }
                // Unwrap each new angle into a continuous sweep position before mapping it to °C.
                drag.move(ThermostatScale.angle(at: event.location, center: center))
                if let angle = drag.angle { select(scale.value(at: angle)) }
            }.onEnded { _ in
                started = false
                drag = ThermostatDrag()
            })
        }
        .aspectRatio(1, contentMode: .fit)
        .opacity(isEnabled ? 1 : 0.4)
        // No interpolated motion: the indicator follows the selected value directly,
        // including with Reduce Motion enabled and when a parent applies animation.
        .transaction { $0.animation = nil }
        .sensoryFeedback(.selection, trigger: feedback)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Temperature")
        .accessibilityValue("\(scale.snapped(temperature).formatted()) degrees Celsius")
        .accessibilityAdjustableAction { direction in
            // VoiceOver uses the same snapped value path as touch input.
            guard isEnabled else { return }
            switch direction {
            case .increment: select(scale.snapped(temperature) + scale.step)
            case .decrement: select(scale.snapped(temperature) - scale.step)
            @unknown default: break
            }
        }
    }

    /// Commits only a changed, snapped value; this also drives the number transition and haptic.
    private func select(_ value: Double) {
        let next = scale.snapped(value)
        guard next != temperature else { return }
        temperature = next
        feedback += 1
    }
}

private struct DialReadout: View {
    let value: Double
    let reduceMotion: Bool

    var body: some View {
        // This view owns only the visible number transition. The parent dial keeps
        // one complete accessibility value so VoiceOver never reads individual digits.
        VStack(spacing: 4) {
            Text("\(value.formatted())°")
                .font(.largeTitle.weight(.semibold)).monospacedDigit()
                .lineLimit(1).minimumScaleFactor(0.4)
                // Roll changed numerals; use a short fade when Reduce Motion is active.
                .contentTransition(reduceMotion ? .opacity : .numericText(value: value))
                .animation(reduceMotion ? .easeInOut(duration: 0.15) : .snappy(duration: 0.25), value: value)
            Text("CELSIUS").font(.caption).foregroundStyle(.secondary)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
    }
}

private struct DialArc: Shape {
    let progress: Double

    func path(in rect: CGRect) -> Path {
        // Drawing from the fixed start to start + progress × sweep keeps the track
        // and active segment on precisely the same 270-degree path.
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: max(1, min(rect.width, rect.height) / 2 - 24),
                    startAngle: .degrees(135), endAngle: .degrees(135 + progress * 270), clockwise: false)
        return path
    }
}

private struct DialTicks: Shape {
    func path(in rect: CGRect) -> Path {
        // Build one path for all marks so SwiftUI can stroke them together.
        var path = Path()
        let radius = max(1, min(rect.width, rect.height) / 2 - 24)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        // Fixed scale divisions avoid excessive drawing for tiny temperature steps.
        for index in 0...28 {
            let angle = 135 + Double(index) / 28 * 270
            path.move(to: ThermostatScale.point(angle: angle, radius: radius - 16, center: center))
            path.addLine(to: ThermostatScale.point(angle: angle, radius: radius - (index.isMultiple(of: 2) ? 25 : 21), center: center))
        }
        return path
    }
}

private struct DialTouchRing: Shape {
    func path(in rect: CGRect) -> Path {
        // A wide stroked arc gives the visible thin ring a forgiving touch target.
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(1, min(rect.width, rect.height) / 2 - 24)
        var arc = Path()
        arc.addArc(center: center, radius: radius, startAngle: .degrees(135), endAngle: .degrees(405), clockwise: false)
        return arc.strokedPath(StrokeStyle(lineWidth: 56, lineCap: .butt))
    }
}
