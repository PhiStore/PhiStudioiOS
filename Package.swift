// swift-tools-version: 5.6

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import AppleProductTypes
import PackageDescription

let package = Package(
    name: "PhiStudio",
    platforms: [
        .iOS("15.2"),
    ],
    products: [
        .iOSApplication(
            name: "PhiStudio",
            targets: ["AppModule"],
            bundleIdentifier: "com.tiankaima.phistudio",
            teamIdentifier: "VUW8FV5HN5",
            displayVersion: "1.1.4",
            bundleVersion: "30",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone,
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad])),
            ],
            capabilities: [
                .photoLibrary(purposeString: "添加曲绘🌟"),
                .mediaLibrary(purposeString: "添加音乐🎧"),
                .appTransportSecurity(configuration: .init(
                    exceptionDomains: [
                        .init(
                            domainName: "tiankaima.github.io",
                            includesSubdomains: true,
                            exceptionAllowsInsecureHTTPLoads: true
                        ),
                    ]
                )),
            ],
            appCategory: .utilities
        ),
    ],
    dependencies: [
        .package(url: "https://gitee.com/spm_mirror/ZIPFoundation", "0.9.9" ..< "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "ZIPFoundation", package: "zipfoundation"),
            ],
            path: ".",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
