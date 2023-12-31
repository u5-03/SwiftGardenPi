// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private extension PackageDescription.Target.Dependency {
//    static let crypto: Self = .product(name: "Crypto", package: "swift-crypto")
    static let swiftyGPIO: Self = .product(name: "SwiftyGPIO", package: "SwiftyGPIO")
    static let alamofire: Self = .product(name: "Alamofire", package: "Alamofire")
    static let pythonKit: Self = .product(name: "PythonKit", package: "PythonKit")
    static let asyncHTTPClient: Self = .product(name: "AsyncHTTPClient", package: "async-http-client")
    static let swiftGardenSecrets: Self = .product(name: "SwiftGardenSecrets", package: "SwiftGardenSecrets")
    static let swiftGardenCore: Self = .product(name: "SwiftGardenCore", package: "SwiftGardenCore")
}

let package = Package(
    name: "SwiftGardenPi",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
//        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.7.0"),
        .package(url: "https://github.com/pvieito/PythonKit", branch: "master"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.18.0"),
        .package(url: "https://github.com/u5-03/SwiftGardenSecrets", branch: "main"),
        .package(url: "https://github.com/u5-03/SwiftGardenCore", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftGardenPi",
            dependencies: [
                .alamofire,
//                .crypto,
                .swiftyGPIO,
                .pythonKit,
                .asyncHTTPClient,
                .swiftGardenCore,
                .swiftGardenSecrets,
            ],
            resources: [
                .process("post_image.py"),
                .process("generate_sign.py"),
            ]),
        .testTarget(
            name: "SwiftGardenPiTests",
            dependencies: ["SwiftGardenPi"]),
    ]
)
