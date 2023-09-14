// swift-tools-version:5.11
import PackageDescription

let package = Package(
	name: "trash",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.executable(
			name: "trash",
			targets: [
				"trash"
			]
		)
	],
	targets: [
		.executableTarget(name: "trash")
	]
)
