// swift-tools-version:6.2
import PackageDescription

let package = Package(
	name: "trash",
	platforms: [
		.macOS(.v13)
	],
	products: [
		.executable(
			name: "trash",
			targets: [
				"trash"
			]
		)
	],
	dependencies: [
		.package(url: "https://github.com/sindresorhus/DSStore", from: "0.1.0")
	],
	targets: [
		.executableTarget(
			name: "trash",
			dependencies: [
				"DSStore"
			]
		)
	],
	swiftLanguageModes: [.v5]
)
