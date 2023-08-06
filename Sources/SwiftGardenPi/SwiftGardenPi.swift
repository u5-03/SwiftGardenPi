import Foundation

enum CommandKind {
    case captureData
    case drainWater
    case switchLight(isON: Bool)
    
    static func converted(from arguments: [String]) -> CommandKind {
        let arguments = CommandLine.arguments
        print(arguments)
        if arguments.isEmpty {
            fatalError("Parameter is required!")
        } else if arguments.count == 3 {
            switch arguments[1] {
            case "--switchLight":
                switch arguments[2] {
                case "isOn":
                    return .switchLight(isON: true)
                case "isOff":
                    return .switchLight(isON: false)
                default:
                    fatalError("Invalid parameter")
                }
            default:
                fatalError("Invalid parameter")
            }
        } else if arguments.count == 2 {
            switch arguments[1] {
            case "--captureData":
                return .captureData
            case "--drainWater":
                return .drainWater
            default:
                fatalError("Invalid parameter")
            }
        } else {
            fatalError("Parameter is required!")
        }
    }
}

// Ref: https://www.hackingwithswift.com/quick-start/concurrency/how-to-make-async-command-line-tools-and-scripts


@main
public struct SwiftGardenPi {
    static let retryCount = 1
    
    public static func main() async {
        let command = CommandKind.converted(from: CommandLine.arguments)
        await runCommand(command: command)
    }

    private static func runCommand(command: CommandKind, retryCount: Int = 0) async {
        print("Command is \(command)")
        do {
            switch command {
            case .captureData:
                let URL = try ShellCall.takeImage()
                let cloudStorageResponse = try await FirebaseManager.postImageWithAsyncHTTPClient(fileURL: URL)
                let switchbotResponse = try await SwitchbotManger.fetchMeterInfo()
                let firestoreRequest = FirestorePostRequest(
                    imageName: cloudStorageResponse.name,
                    imageURL: cloudStorageResponse.mediaLink,
                    date: Date(),
                    temperature: switchbotResponse.temperature,
                    humidity: switchbotResponse.humidity
                )
                let _ = try await FirebaseManager.postData(requestBody: firestoreRequest)
                print("Completed!")
            case .drainWater:
                await GPIOManager.shared.drainWater(second: 3)
            case .switchLight(let isON):
                try await SwitchbotManger.postSwitchBot(isON: isON)
            }
        } catch {
            print(error)
            if retryCount >= Self.retryCount {
                await runCommand(command: command, retryCount: retryCount + 1)
            }
        }
    }
}
