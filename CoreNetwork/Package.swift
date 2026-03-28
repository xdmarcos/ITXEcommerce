// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CoreNetwork",
    platforms: [
        .iOS(.v18),
        .macCatalyst(.v18),
    ],
    products: [
        .library(
            name: "CoreNetwork",
            targets: ["CoreNetwork"]
        ),
    ],
    targets: [
        .target(
            name: "CoreNetwork",
            swiftSettings: [
                .enableUpcomingFeature("MemberImportVisibility"),
            ]
        ),
        .testTarget(
            name: "CoreNetworkTests",
            dependencies: ["CoreNetwork"]
        ),
    ]
)
