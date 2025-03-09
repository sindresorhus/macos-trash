import Foundation

let VERSION = "2.1.0"

func trash(_ urls: [URL]) {
	// Ensures the user's trash is used.
	CLI.revertSudo()

	for url in urls {
		CLI.tryOrExit {
			try FileManager.default.trashItem(at: url, resultingItemURL: nil)
		}
	}
}

func prompt(question: String) -> Bool {
	print(question, terminator: " ")

	guard
		let input = readLine(),
		!input.isEmpty
	else {
		return false
	}

	return ["y", "yes"].contains(input.lowercased())
}

guard let argument = CLI.arguments.first else {
	print("Specify one or more paths", to: .standardError)
	exit(1)
}

switch argument {
case "--help", "-h":
	print("Usage: trash [--help | -h] [--version | -v] [--force | -f] <path> […]")
	exit(0)
case "--version", "-v":
	print(VERSION)
	exit(0)
case "--force", "-f":
	trash(CLI.arguments.dropFirst().map { URL(fileURLWithPath: $0) })
default:
	for url in (CLI.arguments.map { URL(fileURLWithPath: $0) }) {
		guard FileManager.default.fileExists(atPath: url.path) else {
			print("The file “\(url.relativePath)” doesn't exist.")
			continue
		}

		guard prompt(question: "Trash “\(url.relativePath)”?") else {
			continue
		}

		trash([url])
	}
}
