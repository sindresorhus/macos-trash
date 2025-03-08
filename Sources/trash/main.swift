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

func secondarg(arg: String) -> Void {
	if ["--help", "-h"].contains(arg) {
	    print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	    exit(0)
	}
	
	if ["--version", "-v"].contains(arg) {
	    print(VERSION)
	    exit(0)
	}
}

guard let argument = CLI.arguments.first else {
	print("Specify one or more paths", to: .standardError)
	exit(1)
}

switch argument {
case "--help", "-h":
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	exit(0)
case "--version", "-v":
	print(VERSION)
	exit(0)
case "--interactive", "-i":
	for url in (CLI.arguments.dropFirst().map { URL(fileURLWithPath: $0) }) {
	    if ["--help", "-h", "--version", "-v"].contains(url.relativePath) {
	        secondarg(arg: url.relativePath)
	    }
	    
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
	trash(CLI.arguments.map { URL(fileURLWithPath: $0) })
}
