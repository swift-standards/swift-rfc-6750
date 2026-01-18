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
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: .rfc6750, targets: [.rfc6750]),
    ],
    dependencies: [
        .package(path: "../../swift-foundations/swift-ascii"),
    ],
    targets: [
        .target(
            name: .rfc6750,
            dependencies: [
                .product(name: "ASCII", package: "swift-ascii"),
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
