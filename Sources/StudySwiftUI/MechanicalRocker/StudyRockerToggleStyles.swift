import RealityKit
import SwiftUI
import UIKit

/// A Core Graphics appliance-rocker appearance for a standard SwiftUI toggle.
///
/// The label supplied to `Toggle` stays visible and becomes the control's
/// VoiceOver label. The rocker has no independent state; it changes the binding
/// owned by the `Toggle`.
public struct StudyRockerToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        StudyRockerToggle(
            configuration: configuration,
            renderer: .coreGraphics,
            modelPosition: .zero,
            modelRotation: .zero
        )
    }
}

/// A RealityKit/USDZ appliance-rocker appearance for a standard SwiftUI toggle.
///
/// The bundled model contains a named `RockerPivot` entity that rotates between
/// the two electrical states. If the resource cannot load, this style displays
/// the bundled static-image renderer so the toggle remains usable.
public struct StudyRocker3DToggleStyle: ToggleStyle {
    public let position: SIMD3<Float>
    public let rotation: SIMD3<Float>

    /// Creates a 3D rocker style with optional gallery-space adjustments.
    /// - Parameters:
    ///   - position: Translation in normalized scene units on the X, Y, and Z axes.
    ///   - rotation: Pitch, yaw, and roll in degrees.
    public init(
        position: SIMD3<Float> = .zero,
        rotation: SIMD3<Float> = .zero
    ) {
        self.position = position
        self.rotation = rotation
    }

    public func makeBody(configuration: Configuration) -> some View {
        StudyRockerToggle(
            configuration: configuration,
            renderer: .model3D,
            modelPosition: position,
            modelRotation: rotation
        )
    }
}

/// A static-image appliance-rocker appearance for a standard SwiftUI toggle.
///
/// The images are rendered views of the same original model used by
/// `StudyRocker3DToggleStyle`; this variation deliberately trades live depth for
/// the smallest rendering cost.
public struct StudyRockerImageToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        StudyRockerToggle(
            configuration: configuration,
            renderer: .staticImages,
            modelPosition: .zero,
            modelRotation: .zero
        )
    }
}

private enum RockerRenderer {
    case coreGraphics
    case model3D
    case staticImages
}

private struct StudyRockerToggle: View {
    let configuration: ToggleStyleConfiguration
    let renderer: RockerRenderer
    let modelPosition: SIMD3<Float>
    let modelRotation: SIMD3<Float>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 16) {
                configuration.label
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                RockerRendererView(
                    renderer: renderer,
                    isOn: configuration.isOn,
                    reduceMotion: reduceMotion,
                    modelPosition: modelPosition,
                    modelRotation: modelRotation
                )
                .frame(width: 116, height: 78)
                .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
        .accessibilityIdentifier("mechanicalRocker")
    }
}

private struct RockerRendererView: View {
    let renderer: RockerRenderer
    let isOn: Bool
    let reduceMotion: Bool
    let modelPosition: SIMD3<Float>
    let modelRotation: SIMD3<Float>

    var body: some View {
        switch renderer {
        case .coreGraphics:
            RockerCanvas(isOn: isOn, reduceMotion: reduceMotion)
        case .model3D:
            StudyRocker3DModelView(
                isOn: isOn,
                position: modelPosition,
                rotation: modelRotation
            )
        case .staticImages:
            RockerStaticImage(isOn: isOn, reduceMotion: reduceMotion)
        }
    }
}

private struct RockerCanvas: View {
    let isOn: Bool
    let reduceMotion: Bool
    @State private var progress: CGFloat

    init(isOn: Bool, reduceMotion: Bool) {
        self.isOn = isOn
        self.reduceMotion = reduceMotion
        // Canvas does not interpolate a captured Boolean. Keep an animatable
        // scalar so the face, gradients, and lamp can move continuously.
        _progress = State(initialValue: isOn ? 1 : 0)
    }

    var body: some View {
        Canvas { context, size in
            context.withCGContext { cgContext in
                RockerDrawing.draw(in: cgContext, size: size, progress: progress)
            }
        }
        .onChange(of: isOn) { _, newValue in
            if reduceMotion {
                progress = newValue ? 1 : 0
            } else {
                withAnimation(.easeInOut(duration: 0.18)) {
                    progress = newValue ? 1 : 0
                }
            }
        }
        .accessibilityHidden(true)
    }
}

private enum RockerDrawing {
    static func draw(in context: CGContext, size: CGSize, progress: CGFloat) {
        let scale = min(size.width / 116, size.height / 78)
        let rockerRect = CGRect(x: (size.width - 96 * scale) / 2, y: (size.height - 64 * scale) / 2, width: 96 * scale, height: 64 * scale)
        let bezel = rockerRect.insetBy(dx: -8 * scale, dy: -7 * scale)

        context.setShadow(offset: CGSize(width: 0, height: 4 * scale), blur: 7 * scale, color: UIColor.black.withAlphaComponent(0.28).cgColor)
        context.setFillColor(UIColor(white: 0.13, alpha: 1).cgColor)
        context.addPath(UIBezierPath(roundedRect: bezel, cornerRadius: 12 * scale).cgPath)
        context.fillPath()
        context.setShadow(offset: .zero, blur: 0, color: nil)

        let faceOffset = (0.5 - progress) * 6 * scale
        let face = rockerRect.offsetBy(dx: 0, dy: faceOffset)
        let colors = progress > 0.5
            ? [UIColor(white: 0.23, alpha: 1).cgColor, UIColor(white: 0.05, alpha: 1).cgColor]
            : [UIColor(white: 0.06, alpha: 1).cgColor, UIColor(white: 0.28, alpha: 1).cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
        context.saveGState()
        context.addPath(UIBezierPath(roundedRect: face, cornerRadius: 9 * scale).cgPath)
        context.clip()
        context.drawLinearGradient(gradient, start: CGPoint(x: face.midX, y: face.minY), end: CGPoint(x: face.midX, y: face.maxY), options: [])
        context.restoreGState()

        context.setStrokeColor(UIColor.white.withAlphaComponent(0.72).cgColor)
        context.setLineWidth(2 * scale)
        // The top line and circle are the universal I/O marking. They move with
        // the face, making the 2D variation show the same mechanical tilt.
        context.move(to: CGPoint(x: face.midX, y: face.minY + 12 * scale))
        context.addLine(to: CGPoint(x: face.midX, y: face.minY + 22 * scale))
        context.strokePath()
        context.strokeEllipse(in: CGRect(x: face.midX - 7 * scale, y: face.minY + 17 * scale, width: 14 * scale, height: 14 * scale))

        context.setStrokeColor(UIColor.white.withAlphaComponent(0.58).cgColor)
        context.strokeEllipse(in: CGRect(x: face.midX - 6 * scale, y: face.maxY - 22 * scale, width: 12 * scale, height: 12 * scale))
        let indicator = CGRect(x: face.maxX - 15 * scale, y: face.maxY - 14 * scale, width: 7 * scale, height: 7 * scale)
        context.setFillColor((progress > 0.5 ? UIColor.systemGreen : UIColor(white: 0.25, alpha: 1)).cgColor)
        context.fillEllipse(in: indicator)
    }
}

private struct RockerStaticImage: View {
    let isOn: Bool
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            RockerPNG(name: "MechanicalRocker-off")
                .opacity(isOn ? 0 : 1)
            RockerPNG(name: "MechanicalRocker-on")
                .opacity(isOn ? 1 : 0)
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.18), value: isOn)
    }
}

private struct RockerPNG: View {
    let name: String

    var body: some View {
        if let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            // Keep the public style functional if a consumer strips package
            // resources while embedding it; the gallery documents this fallback.
            RockerCanvas(isOn: name.hasSuffix("on"), reduceMotion: true)
        }
    }
}

/// A standalone RealityKit rendering of the bundled mechanical rocker USDZ.
///
/// Use this when the model is decorative or when building a custom control.
/// For an accessible, interactive control, use ``StudyRocker3DToggleStyle``
/// with SwiftUI's standard `Toggle`.
public struct StudyRocker3DModelView: View {
    public let isOn: Bool
    public let position: SIMD3<Float>
    public let rotation: SIMD3<Float>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didFailToLoad = false

    public init(
        isOn: Bool,
        position: SIMD3<Float> = .zero,
        rotation: SIMD3<Float> = .zero
    ) {
        self.isOn = isOn
        self.position = position
        self.rotation = rotation
    }

    public var body: some View {
        Group {
            if didFailToLoad {
                RockerStaticImage(isOn: isOn, reduceMotion: reduceMotion)
            } else {
                RealityView { content in
                    do {
                        // A package resource is a standalone USDZ. Load its exact
                        // URL instead of relying on name-based scene lookup.
                        guard let url = Bundle.module.url(
                            forResource: "MechanicalRocker",
                            withExtension: "usdz"
                        ) else {
                            didFailToLoad = true
                            return
                        }
                        let displayRoot = Entity()
                        displayRoot.name = "RockerDisplayRoot"
                        let model = try await Entity(contentsOf: url)
                        // USD uses Y as its up axis and this asset was authored
                        // as a tabletop control. RealityView's virtual camera
                        // looks forward along Z, so turn the face toward it
                        // before framing the model with `cameraTarget`.
                        model.orientation = simd_quatf(
                            angle: .pi / 2,
                            axis: SIMD3<Float>(1, 0, 0)
                        )
                        // Normalize the imported bounds, including the USD unit
                        // conversion, instead of guessing a display scale.
                        let bounds = model.visualBounds(relativeTo: nil)
                        let largestExtent = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
                        guard largestExtent.isFinite, largestExtent > 0 else {
                            didFailToLoad = true
                            return
                        }
                        let displayScale: Float = 1 / largestExtent
                        model.scale *= SIMD3<Float>(repeating: displayScale)
                        model.position -= bounds.center * displayScale
                        displayRoot.addChild(model)
                        applyDisplayTransform(to: displayRoot)

                        // cameraTarget only applies to orbit controls. Supply a
                        // real camera with a known pose for this fixed preview.
                        content.camera = .virtual
                        let camera = PerspectiveCamera()
                        camera.camera.fieldOfViewInDegrees = 40
                        camera.look(at: .zero, from: [0, 0, 2], relativeTo: nil)
                        content.add(camera)
                        content.add(displayRoot)
                        content.environment = .default
                        if let pivot = model.findEntity(named: "RockerPivot") {
                            // `update` runs when SwiftUI state changes. Apply the
                            // current binding here as well so the first loaded
                            // frame never waits for a later update.
                            setRockerState(on: pivot, isOn: isOn, reduceMotion: true)
                        }
                    } catch {
                        didFailToLoad = true
                    }
                } update: { content in
                    guard let displayRoot = content.entities.first(where: { $0.name == "RockerDisplayRoot" }),
                          let pivot = displayRoot.findEntity(named: "RockerPivot") else { return }
                    applyDisplayTransform(to: displayRoot)
                    setRockerState(on: pivot, isOn: isOn, reduceMotion: reduceMotion)
                }
                placeholder: {
                    RockerStaticImage(isOn: isOn, reduceMotion: true)
                }
            }
        }
    }

    private func applyDisplayTransform(to displayRoot: Entity) {
        displayRoot.position = position
        let degreesToRadians: Float = .pi / 180
        let pitch = simd_quatf(angle: rotation.x * degreesToRadians, axis: SIMD3<Float>(1, 0, 0))
        let yaw = simd_quatf(angle: rotation.y * degreesToRadians, axis: SIMD3<Float>(0, 1, 0))
        let roll = simd_quatf(angle: rotation.z * degreesToRadians, axis: SIMD3<Float>(0, 0, 1))
        displayRoot.orientation = yaw * pitch * roll
    }

    private func setRockerState(on pivot: Entity, isOn: Bool, reduceMotion: Bool) {
        // The USDZ keeps the face below this node. Rotating the pivot rather
        // than its mesh preserves the recessed bezel's fixed physical position.
        let angle: Float = isOn ? -0.20944 : 0.20944
        var destination = pivot.transform
        destination.rotation = simd_quatf(angle: angle, axis: SIMD3<Float>(1, 0, 0))
        pivot.stopAllAnimations(recursive: false)
        if reduceMotion {
            pivot.transform = destination
        } else {
            pivot.move(to: destination, relativeTo: pivot.parent, duration: 0.18, timingFunction: .easeInOut)
        }
    }
}

#Preview("Mechanical rocker styles") {
    RockerToggleStylesPreview()
        .padding()
}

#Preview("Mechanical rocker USDZ") {
    VStack(spacing: 16) {
        StudyRocker3DModelView(isOn: false)
            .frame(width: 232, height: 156)
        StudyRocker3DModelView(isOn: true)
            .frame(width: 232, height: 156)
    }
    .padding()
}

private struct RockerToggleStylesPreview: View {
    @State private var coreGraphicsIsOn = false
    @State private var model3DIsOn = true
    @State private var imageIsOn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Core Graphics", isOn: $coreGraphicsIsOn)
                .toggleStyle(StudyRockerToggleStyle())

            Toggle("USDZ 3D", isOn: $model3DIsOn)
                .toggleStyle(StudyRocker3DToggleStyle())

            Toggle("Static images", isOn: $imageIsOn)
                .toggleStyle(StudyRockerImageToggleStyle())

            Toggle("Disabled rocker", isOn: .constant(true))
                .toggleStyle(StudyRockerToggleStyle())
                .disabled(true)
        }
        .frame(maxWidth: 420, alignment: .leading)
    }
}
