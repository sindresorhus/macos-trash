// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "trash",
	platforms: [
		.macOS(.v10_10)
	],
	targets: [
		.target(
			name: "trash"
		)
	]
)
