import Foundation

let VERSION = "2.2.0"

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

// Extract paths from arguments, filtering out flags for `rm` compatibility.
// Removes leading `--` if present, keeps subsequent `--` as literal paths.
func extractPaths(from arguments: some Collection<String>) -> [String] {
	let trimmed = arguments.first == "--" ? Array(arguments.dropFirst()) : Array(arguments)
	return trimmed.filter { !$0.hasPrefix("-") || $0 == "--" }
}

switch argument {
case "--help", "-h":
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	exit(0)
case "--version", "-v":
	print(VERSION)
	exit(0)
case "--interactive", "-i":
	for url in extractPaths(from: CLI.arguments.dropFirst()).map({ URL(fileURLWithPath: $0) }) {
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
	let paths = extractPaths(from: CLI.arguments)
	guard !paths.isEmpty else {
		exit(0)
	}

	// TODO: Use `URL(filePath:` when targeting macOS 15.
	trash(paths.map { URL(fileURLWithPath: $0) })
}
