import Foundation

let VERSION = "1.2.0"

func trash(paths: [String]) {
	// Ensures the user's trash is used.
	CLI.revertSudo()

	for path in paths {
		let url = URL(fileURLWithPath: path)

		CLI.tryOrExit {
			try FileManager.default.trashItem(at: url, resultingItemURL: nil)
		}
	}
}

switch CLI.arguments.first {
case "--help", "-h":
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	exit(0)
case "--version", "-v":
	print(VERSION)
	exit(0)
case "--interactive", "-i":
	for path in CLI.arguments.dropFirst() {
	    if !FileManager.default.fileExists(atPath: path) {
	        print("The file “\(path)” doesn’t exist.")
	        continue
	    }
	    print("Move “\(path)” to the trash? ", terminator: "")
        var response: String = ""
	    while let input = readLine() {
	        if input == "" {
	            exit(0)
	        }
	        response = input
	        break
        }
	    switch response {
	    case "y", "yes":
	        trash(paths: [path])
	    case "n", "no":
	        continue
	    default:
	        continue
	    }
	}
	exit(0)
case .none:
	print("Specify one or more paths", to: .standardError)
	exit(1)
default:
	trash(paths: CLI.arguments)
}
