// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let rfc6750: Self = "RFC_6750"
}

extension Target.Dependency {
    static var rfc6750: Self { .target(name: .rfc6750) }
}

let package = Package(
    name: "swift-rfc-6750",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: .rfc6750, targets: [.rfc6750]),
    ],
    dependencies: [
        // Add RFC dependencies here as needed
        // .package(url: "https://github.com/swift-web-standards/swift-rfc-1123.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .rfc6750,
            dependencies: [
                // Add target dependencies here
            ]
        ),
        .testTarget(
            name: .rfc6750.tests,
            dependencies: [
                .rfc6750
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
