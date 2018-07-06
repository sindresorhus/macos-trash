import Foundation

let VERSION = "1.1.0"

func trash(paths: [String]) {
	// Ensures the user's trash is used
	CLI.revertSudo()

	for path in CLI.arguments {
		let url = URL(fileURLWithPath: path)

		CLI.tryOrExit {
			try FileManager.default.trashItem(at: url, resultingItemURL: nil)
		}
	}
}

switch CLI.arguments.first {
case "--help":
	print("Usage: trash <path> […]")
	exit(0)
case "--version":
	print(VERSION)
	exit(0)
case .none:
	print("Specify one or more paths", to: .standardError)
	exit(1)
default:
	trash(paths: CLI.arguments)
}
