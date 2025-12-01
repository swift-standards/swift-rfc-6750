// swift-tools-version:6.2

import PackageDescription

extension String {
    static let rfc6750: Self = "RFC 6750"
}

extension Target.Dependency {
    static var rfc6750: Self { .target(name: .rfc6750) }
}

let package = Package(
    name: "swift-rfc-6750",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(name: .rfc6750, targets: [.rfc6750]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: .rfc6750,
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
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

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility")
    ]
}
