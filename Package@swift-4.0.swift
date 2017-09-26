// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "RedShot",
    products: [
        .library(name: "RedShot", targets: ["RedShot"])
    ],
    targets:[
        .target(name:"RedShot", dependencies: []),
        .testTarget(name: "RedShotTests", dependencies: ["RedShot"])
    ]
)
