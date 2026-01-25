import Foundation
import SystemConfiguration

extension FileHandle: @retroactive TextOutputStream {
	public func write(_ string: String) {
		write(string.data(using: .utf8)!)
	}
}

enum CLI {
	static var standardInput = FileHandle.standardInput
	static var standardOutput = FileHandle.standardOutput
	static var standardError = FileHandle.standardError

	static let arguments = Array(CommandLine.arguments.dropFirst(1))

	/// Execute code and print to `stderr` and exit with code 1 if it throws.
	static func tryOrExit(_ throwingFunc: () throws -> Void) {
		do {
			try throwingFunc()
		} catch {
			print(error.localizedDescription, to: .standardError)
			exit(1)
		}
	}

	/// Revert back to original user if running as root (via sudo or osascript with administrator privileges).
	static func revertSudo() {
		// Only proceed if running as root.
		guard getuid() == 0 else {
			return
		}

		// First try SUDO_UID (for regular sudo usage).
		if
			let sudoUIDstring = ProcessInfo.processInfo.environment["SUDO_UID"],
			let sudoUID = uid_t(sudoUIDstring)
		{
			setuid(sudoUID)
			return
		}

		// Otherwise, get the console user (for osascript with administrator privileges).
		var uid: uid_t = 0
		guard
			SCDynamicStoreCopyConsoleUser(nil, &uid, nil) != nil,
			uid != 0
		else {
			return
		}

		setuid(uid)
	}
}

enum PrintOutputTarget {
	case standardOutput
	case standardError
}

/// Make `print()` accept an array of items.
/// Since Swift doesn't support spreading...
private func print(
	_ items: [Any],
	separator: String = " ",
	terminator: String = "\n",
	to output: inout some TextOutputStream
) {
	let item = items.map { "\($0)" }.joined(separator: separator)
	Swift.print(item, terminator: terminator, to: &output)
}

func print(
	_ items: Any...,
	separator: String = " ",
	terminator: String = "\n",
	to output: PrintOutputTarget = .standardOutput
) {
	switch output {
	case .standardOutput:
		print(items, separator: separator, terminator: terminator)
	case .standardError:
		print(items, separator: separator, terminator: terminator, to: &CLI.standardError)
	}
}
