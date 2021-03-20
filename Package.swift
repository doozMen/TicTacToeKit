// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TicTacToeKit",
    platforms: [.macOS(.v11), .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TicTacToeKit",
            targets: ["TicTacToeKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TicTacToeKit",
            dependencies: []
        ),
        .testTarget(
            name: "TicTacToeKitTests",
            dependencies: ["TicTacToeKit"],
            exclude: ["Info.plist"]
        )
    ]
)
