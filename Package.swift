// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftDithering",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftDithering",
            targets: ["SwiftDithering"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftDithering",
            resources: [
                .process("Resources/bayer8x8.png"),
                .process("Resources/balancedCenteredPoint6x6.png"),
                .process("Resources/centralWhitePoint6x6.png"),
                .process("Resources/clusteredDots6x6.png"),
                .process("Resources/DiagonalOrdered.png")
            ],
            cSettings: [.define("CI_SILENCE_GL_DEPRECATION")]
        ),

        .testTarget(
            name: "SwiftDitheringTests",
            dependencies: ["SwiftDithering"],
            resources: [
                .process("Resources/bayer8x8.png"),
                .process("Resources/balancedCenteredPoint6x6.png"),
                .process("Resources/centralWhitePoint6x6.png"),
                .process("Resources/clusteredDots6x6.png"),
                .process("Resources/DiagonalOrdered.png")
                       ],
            swiftSettings: [.define("CI_SILENCE_GL_DEPRECATION")]
        ),
    ]
)
