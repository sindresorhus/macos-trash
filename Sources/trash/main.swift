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
case "--help","-h":
	print("Usage: trash [--help | -h] [--version | -v] [--interactive | -i] <path> […]")
	exit(0)
case "--version","-v":
	print(VERSION)
	exit(0)
case "--interactive","-i":
    var args = CLI.arguments
    args.removeFirst()
    for path in args {
        if !FileManager.default.fileExists(atPath: path) {
	        print("The file “\(path)” doesn’t exist.")
	        continue
        }
        print("remove \(path)? ", terminator: "")
        let response = readLine()!
        switch response {
        case "y","yes":
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
