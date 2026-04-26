// swift-tools-version:6.3

import PackageDescription

let package = Package(
    name: "MediaRemoteAdapter",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "MediaRemoteAdapter",
            type: .dynamic,
            targets: ["MediaRemoteAdapter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MxIris-Reverse-Engineering/OpenSoftLinking", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "MediaRemoteAdapter",
            dependencies: ["CIMediaRemote"],
            resources: [
                .copy("Resources/run.pl")
            ]
        ),
        .target(
            name: "CIMediaRemote",
            dependencies: [
                .product(name: "OpenSoftLinking", package: "OpenSoftLinking"),
            ]
        )
    ],
    swiftLanguageModes: [.v5],
)
