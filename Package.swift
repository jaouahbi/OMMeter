// swift-tools-version:5.0

import PackageDescription

#if os(macOS)
let package = Package(
    name: "OMMeter",
    products: [
        .library(
            name: "OMMeter",
            targets: ["OMMeter"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OMMeter",
            dependencies: [],
            path: "OMMeter/Classes",
            exclude: ["Example", "ScreenShot", "README.md", "LICENSE", "OMMeter.podspec"]
        ),
    ]
)
#else
fatalError("Unsupported OS")
#endif
