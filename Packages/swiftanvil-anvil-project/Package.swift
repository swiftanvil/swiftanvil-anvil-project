// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnvilProject",
    platforms: [.iOS(.v16), .macOS(.v13), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1)],
    products: [.library(name: "AnvilProject", targets: ["AnvilProject"])],
    dependencies: [
        .package(url: "https://github.com/swiftanvil/swiftanvil-anvil-template.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AnvilProject",
            dependencies: [.product(name: "AnvilTemplate", package: "swiftanvil-anvil-template")]
        ),
        .testTarget(
            name: "AnvilProjectTests",
            dependencies: ["AnvilProject"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
