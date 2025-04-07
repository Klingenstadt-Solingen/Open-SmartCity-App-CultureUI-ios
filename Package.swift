// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaCultureVersion = Version("1.1.0")
let oscaSafariViewVersion = Version("1.1.0")

let package = Package(
  name: "OSCACultureUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCACultureUI",
      targets: ["OSCACultureUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMinor(from: oscaEssentialsVersion)),
    /* OSCACulture */
    packageLocal ? .package(path: "../OSCACulture") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaculture-ios.git",
             .upToNextMinor(from: oscaCultureVersion)),
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMinor(from: oscaTestCaseExtensionVersion)),
    // OSCASafariView
    packageLocal ? .package(path: "../OSCASafariView") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscasafariview-ios.git",
             .upToNextMinor(from: oscaSafariViewVersion))],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCACultureUI",
      dependencies: [.product(name: "OSCACulture",
                              package: packageLocal ? "OSCACulture" : "oscaculture-ios"),
                     .product(name: "OSCAEssentials",
                              package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                     .product(name: "OSCASafariView",
                              package: packageLocal ? "OSCASafariView" : "oscasafariview-ios")],
      path: "OSCACultureUI/OSCACultureUI",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "OSCACultureUITests",
      dependencies: ["OSCACultureUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")
      ],
      path: "OSCACultureUI/OSCACultureUITests",
      exclude: ["Info.plist"],
      resources: [.process("Resources")]
    ),
  ]
)
