enum CLIAction: Equatable {
	case missingArguments
	case help
	case version
	case empty
	case interactive
	case trash
}

func cliAction(for arguments: [String]) -> CLIAction {
	guard !arguments.isEmpty else {
		return .missingArguments
	}

	let leadingOptions = arguments.prefix { $0 != "--" && $0.hasPrefix("-") }

	if leadingOptions.contains(where: { ["--help", "-h"].contains($0) }) {
		return .help
	}

	if leadingOptions.contains(where: { ["--version", "-v"].contains($0) }) {
		return .version
	}

	if leadingOptions.contains("--empty") {
		return .empty
	}

	if leadingOptions.contains(where: { ["--interactive", "-i"].contains($0) }) {
		return .interactive
	}

	return .trash
}

// Extract paths from arguments, filtering out flags for `rm` compatibility.
// Removes leading `--` if present, keeps subsequent `--` as literal paths.
func extractPaths(from arguments: some Collection<String>) -> [String] {
	let trimmed = arguments.first == "--" ? Array(arguments.dropFirst()) : Array(arguments)
	return trimmed.filter { !$0.hasPrefix("-") || $0 == "--" }
}

func extractInteractivePaths(from arguments: [String]) -> [String] {
	guard let interactiveIndex = arguments.firstIndex(where: { ["--interactive", "-i"].contains($0) }) else {
		return extractPaths(from: arguments)
	}

	return extractPaths(from: arguments[arguments.index(after: interactiveIndex)...])
}
