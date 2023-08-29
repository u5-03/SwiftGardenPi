import Foundation
import SwiftGardenCore

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
    static let retryCount = 3
    static let drainWaterHour = 9
    static let captureDataFrequencySecond = 3_600

    public static func main() async {
        // Use when linux cron process
       let command = CommandKind.converted(from: CommandLine.arguments)
        await runCommand(command: command)
    }

    private static func executeTask() async throws {
        let currentHour = Calendar.current.component(.hour, from: Date())
        // 1時間ごとのタスク
        await runCommand(command: .captureData)
        if currentHour == drainWaterHour {
            await runCommand(command: .drainWater)
        }
    }

    private static func mainLoop() async throws {
        let calendar = Calendar.current
        var lastExecutedHour: Int?

        while true {
            let now = Date()
            let hour = calendar.component(.hour, from: now)
            let minute = calendar.component(.minute, from: now)

            // 1時間に1度実施する処理
            if lastExecutedHour != hour {
                await runCommand(command: .captureData)
                lastExecutedHour = hour
            }

            // 9時に1度実施する処理
            if hour == drainWaterHour && minute == 0 {
                await runCommand(command: .drainWater)
            }

            // wait 5 minites
            try await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
        }
    }

    private static func runCommand(command: CommandKind, retryCount: Int = 0) async {
        do {
            switch command {
            case .captureData:
                let switchbotResponse = try await SwitchbotManger.fetchMeterInfo()
                print(switchbotResponse)
                let URL = try ShellCall.takeImage()
                let cloudStorageResponse = try await FirebaseManager.postImageWithAsyncHTTPClient(fileURL: URL)
                let firestoreRequest = FirestoreDataModel(
                    imageName: cloudStorageResponse.name,
                    imageURL: cloudStorageResponse.mediaLink,
                    date: Date(),
                    temperature: switchbotResponse.temperature,
                    humidity: switchbotResponse.humidity
                )
                let _ = try await FirebaseManager.postData(requestBody: firestoreRequest)
                print("Completed!")
            case .drainWater:
                await GPIOManager.shared.drainWater()
            case .switchLight(let isON):
                try await SwitchbotManger.postSwitchBot(isON: isON)
            }
        } catch {
            if retryCount <= Self.retryCount {
                print(error)
                print("Retry!! \(retryCount) count")
                // after waiting 5 seconds, retry
                try! await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                await runCommand(command: command, retryCount: retryCount + 1)
            } else {
                print(error)
                print("Completed with error!")
            }
        }
    }
}
