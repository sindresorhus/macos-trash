import Foundation

let VERSION = "2.0.0"

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

// Handle positionals, at the point when no other flags will be accepted.
// If there is a leading `--` argument, it will be removed (but not any subsequent `--` arguments).
func collectPaths(arguments: some Collection<String>) -> any Collection<String> {
	if
		arguments.count > 0,
		arguments[arguments.startIndex] == "--"
	{
		return arguments.dropFirst()
	}

	return arguments
}

switch argument {
case "--help", "-h":
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	exit(0)
case "--version", "-v":
	print(VERSION)
	exit(0)
case "--interactive", "-i":
	for url in (collectPaths(arguments: CLI.arguments.dropFirst()).map { URL(fileURLWithPath: $0) }) {
		guard FileManager.default.fileExists(atPath: url.path) else {
			print("The file “\(url.relativePath)” doesn't exist.")
			continue
		}

		guard prompt(question: "Trash “\(url.relativePath)”?") else {
			continue
		}

		trash([url])
	}
default:
	// TODO: Use `URL(filePath:` when tarrgeting macOS 15.
	trash(collectPaths(arguments: CLI.arguments).map { URL(fileURLWithPath: $0) })
}
