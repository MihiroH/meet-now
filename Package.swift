// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MeetNow",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MeetNow", targets: ["MeetNow"])
    ],
    targets: [
        .executableTarget(
            name: "MeetNow",
            path: "MeetNow"
        ),
        .testTarget(
            name: "MeetNowTests",
            dependencies: ["MeetNow"],
            path: "Tests"
        )
    ]
)
