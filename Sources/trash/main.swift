import Foundation

let VERSION = "1.1.1"

func trash(paths: [String], verbose: Bool) {
	// Ensures the user's trash is used.
	CLI.revertSudo()

	for path in paths {
		let url = URL(fileURLWithPath: path)

		if (verbose) {
			print(path)
		}

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
case "-v":
	trash(paths: CLI.argumentsWithoutFlag, verbose: true)
case "-rv":
	trash(paths: CLI.argumentsWithoutFlag, verbose: true)
case "-fv":
	trash(paths: CLI.argumentsWithoutFlag, verbose: true)
case "-rfv":
	trash(paths: CLI.argumentsWithoutFlag, verbose: true)
case "-frv":
	trash(paths: CLI.argumentsWithoutFlag, verbose: true)
case .none:
	print("Specify one or more paths", to: .standardError)
	exit(1)
default:
	trash(paths: CLI.arguments, verbose: false)
}
