// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MigrationMacros",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MigrationMacros",
            targets: ["MigrationMacros"]
        ),
        .executable(
            name: "MigrationMacrosClient",
            targets: ["MigrationMacrosClient"]
        ),
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.38.0"),
    ],
    targets: [
        .macro(
            name: "CreateMigrationMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "FluentKit", package: "fluent-kit")
            ]
        ),

        .target(name: "MigrationMacros", dependencies: [
            "CreateMigrationMacro",
            .product(name: "FluentKit", package: "fluent-kit")
        ]),

        .executableTarget(name: "MigrationMacrosClient", dependencies: ["MigrationMacros"]),

        .testTarget(
            name: "MigrationMacrosTests",
            dependencies: [
                "CreateMigrationMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
