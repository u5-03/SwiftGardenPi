// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private extension PackageDescription.Target.Dependency {
    static let crypto: Self = .product(name: "Crypto", package: "swift-crypto")
    static let swiftyGPIO: Self = .product(name: "SwiftyGPIO", package: "SwiftyGPIO")
    static let alamofire: Self = .product(name: "Alamofire", package: "Alamofire")
}

let package = Package(
    name: "SwiftGardenPi",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftGardenPi",
            dependencies: [
                .alamofire,
                .crypto,
                .swiftyGPIO,
            ]),
        .testTarget(
            name: "SwiftGardenPiTests",
            dependencies: ["SwiftGardenPi"]),
    ]
)
