// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ComponentsStudies",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "StudySwiftUI", targets: ["StudySwiftUI"]),
        .library(name: "StudyUIKit", targets: ["StudyUIKit"])
    ],
    targets: [
        .target(name: "StudySwiftUI"),
        .target(name: "StudyUIKit"),
        .testTarget(name: "StudySwiftUITests", dependencies: ["StudySwiftUI"]),
        .testTarget(name: "StudyUIKitTests", dependencies: ["StudyUIKit"])
    ]
)
