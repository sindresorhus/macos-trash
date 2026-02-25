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
	var trashedFiles = [TrashedFile]()
	var didFail = false

	for url in extractPaths(from: CLI.arguments.dropFirst()).map({ URL(filePath: $0) }) {
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
default:
	let paths = extractPaths(from: CLI.arguments)
	guard !paths.isEmpty else {
		exit(0)
	}

	trash(paths.map { URL(filePath: $0) })
}
