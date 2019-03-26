// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "trash",
	platforms: [
		.macOS(.v10_9)
	],
	targets: [
		.target(
			name: "trash"
		)
	]
)
