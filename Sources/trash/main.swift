import Foundation
import DSStore

let VERSION = "3.0.0"

struct TrashedFile {
	let originalURL: URL
	let trashedURL: URL

	var trashedFilename: String {
		trashedURL.lastPathComponent
	}

	var originalFilename: String {
		originalURL.lastPathComponent
	}

	var originalDirectoryPath: String {
		let path = originalURL.deletingLastPathComponent().path
		// ptbL stores the path without a leading slash; DSStore.pathValue restores it.
		// Root directory is stored as empty string so pathValue returns "/".
		return path == "/" ? "" : String(path.dropFirst())
	}

	var trashFolderURL: URL {
		trashedURL.deletingLastPathComponent()
	}
}

func trashFiles(_ urls: [URL]) -> (files: [TrashedFile], didFail: Bool) {
	// Ensures the user's trash is used.
	CLI.revertSudo()

	var trashedFiles = [TrashedFile]()
	var didFail = false

	for url in urls {
		var resultingURL: NSURL?
		do {
			try FileManager.default.trashItem(at: url, resultingItemURL: &resultingURL)
			if let trashedURL = resultingURL as URL? {
				trashedFiles.append(TrashedFile(originalURL: url, trashedURL: trashedURL))
			}
		} catch {
			print(error.localizedDescription, to: .standardError)
			didFail = true
		}
	}

	return (files: trashedFiles, didFail: didFail)
}

func trash(_ urls: [URL]) {
	let result = trashFiles(urls)
	writeMissingPutBackRecords(for: result.files)

	if result.didFail {
		exit(1)
	}
}

func emptyTrash() throws {
	CLI.revertSudo()

	try runAppleScript("""
	tell application "Finder"
		if (count items of trash) > 0 then
			empty trash
		end if
	end tell
	""")
}

/// FileManager.trashItem has a macOS bug where only the first file gets Put Back metadata.
/// This ensures all trashed files have ptbN/ptbL records in .DS_Store.
func writeMissingPutBackRecords(for trashedFiles: [TrashedFile]) {
	guard !trashedFiles.isEmpty else {
		return
	}

	// Group by Trash folder to handle external volumes and minimize I/O.
	let filesByTrash = Dictionary(grouping: trashedFiles, by: \.trashFolderURL)

	for (trashFolderURL, files) in filesByTrash {
		let dsStoreURL = trashFolderURL.appending(path: ".DS_Store")

		var store: DSStore
		do {
			store = try DSStore.read(from: dsStoreURL)
		} catch DSStore.Error.fileNotFound {
			store = DSStore()
		} catch {
			continue
		}

		func ensureRecord(for file: TrashedFile, type: DSStore.RecordType, value: String) -> Bool {
			if let existing = store.record(for: file.trashedFilename, type: type),
				case .string(let existingValue) = existing.value,
				existingValue == value {
				return false
			}

			store.add(DSStore.Record(
				filename: file.trashedFilename,
				type: type,
				value: .string(value)
			))

			return true
		}

		var didUpdateStore = false

		for file in files {
			didUpdateStore = ensureRecord(for: file, type: .trashPutBackName, value: file.originalFilename) || didUpdateStore
			didUpdateStore = ensureRecord(for: file, type: .trashPutBackLocation, value: file.originalDirectoryPath) || didUpdateStore
		}

		if didUpdateStore {
			try? store.write(to: dsStoreURL)
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

switch cliAction(for: CLI.arguments) {
case .missingArguments:
	print("Specify one or more paths", to: .standardError)
	exit(1)
case .help:
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] [--empty] <path> […]")
	exit(0)
case .version:
	print(VERSION)
case .empty:
	CLI.tryOrExit {
		try emptyTrash()
	}
case .interactive:
	var trashedFiles = [TrashedFile]()
	var didFail = false

	for url in extractInteractivePaths(from: CLI.arguments).map({ URL(filePath: $0) }) {
		guard FileManager.default.fileExists(atPath: url.path) else {
			print("The file “\(url.relativePath)” doesn't exist.")
			continue
		}

		guard prompt(question: "Trash “\(url.relativePath)”?") else {
			continue
		}

		let result = trashFiles([url])
		trashedFiles.append(contentsOf: result.files)
		didFail = didFail || result.didFail
	}

	writeMissingPutBackRecords(for: trashedFiles)
	exit(didFail ? 1 : 0)
case .trash:
	let paths = extractPaths(from: CLI.arguments)
	guard !paths.isEmpty else {
		exit(0)
	}

	trash(paths.map { URL(filePath: $0) })
}
