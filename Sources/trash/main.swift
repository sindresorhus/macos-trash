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

// Common rm flags to ignore for compatibility when used as an alias
let ignoredRmFlags = Set([
	"-f", "--force",
	"-r", "-R", "--recursive",
	"-rf", "-fr", "-Rf", "-fR",
	"-rR", "-Rr",
	"-v", "--verbose",
	"-d", "--dir",
	"-i", // Interactive handled separately
	"-I",
	"-P", "--preserve-root",
	"--no-preserve-root",
	"-W", "--whiteout"
])

// Filter out common rm flags for compatibility
func filterRmFlags(arguments: some Collection<String>) -> [String] {
	arguments.filter { arg in
		// Keep arguments that don't start with - or are not in the ignored list
		!arg.hasPrefix("-") || !ignoredRmFlags.contains(arg)
	}
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
	let paths = filterRmFlags(arguments: Array(collectPaths(arguments: CLI.arguments)))
	// Exit silently if no paths remain after filtering (e.g., only rm flags were provided)
	guard !paths.isEmpty else {
		exit(0)
	}
	// TODO: Use `URL(filePath:` when tarrgeting macOS 15.
	trash(paths.map { URL(fileURLWithPath: $0) })
}
