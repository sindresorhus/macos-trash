// swift-tools-version:5.3
import PackageDescription

let package = Package(
	name: "trash",
	platforms: [
		.macOS(.v10_10)
	],
	products: [
		.executable(name: "trash", targets: ["trash"])
	],
	targets: [
		.target(name: "trash")
	]
)
