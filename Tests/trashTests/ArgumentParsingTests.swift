import Testing
@testable import trash

@Test(arguments: [
	["--interactive", "--empty"],
	["--empty", "--interactive"],
	["-i", "--empty"],
	["--empty", "-i"]
])
func emptyTrashTakesPrecedenceOverInteractive(arguments: [String]) {
	#expect(cliAction(for: arguments) == .empty)
}

@Test(arguments: [
	(["--empty", "--help"], CLIAction.help),
	(["--help", "--empty"], CLIAction.help),
	(["--empty", "-h"], CLIAction.help),
	(["--empty", "--version"], CLIAction.version),
	(["-v", "--empty"], CLIAction.version),
	(["--version", "--help", "--empty"], CLIAction.help)
])
func informationalActionsTakePrecedenceOverEmpty(arguments: [String], expectedAction: CLIAction) {
	#expect(cliAction(for: arguments) == expectedAction)
}

@Test(arguments: [
	([], CLIAction.missingArguments),
	(["file"], CLIAction.trash),
	(["--interactive", "file"], CLIAction.interactive),
	(["-rf", "--interactive", "file"], CLIAction.interactive),
	(["-rf", "--empty"], CLIAction.empty),
	(["file", "--empty"], CLIAction.trash),
	(["--", "--empty"], CLIAction.trash)
])
func selectsActionFromLeadingOptions(arguments: [String], expectedAction: CLIAction) {
	#expect(cliAction(for: arguments) == expectedAction)
}

@Test(arguments: [
	(["-rf", "--interactive", "file"], ["file"]),
	(["--", "file"], ["file"]),
	(["file", "--empty"], ["file"])
])
func extractsPathsWhileIgnoringOptions(arguments: [String], expectedPaths: [String]) {
	#expect(extractPaths(from: arguments) == expectedPaths)
}

@Test(arguments: [
	(["--interactive", "file"], ["file"]),
	(["-rf", "--interactive", "file"], ["file"]),
	(["--interactive", "--", "file"], ["file"]),
	(["-rf", "-i", "--", "file"], ["file"])
])
func extractsInteractivePathsAfterActionFlag(arguments: [String], expectedPaths: [String]) {
	#expect(extractInteractivePaths(from: arguments) == expectedPaths)
}
