//
//  Created by yugo.sugiyama on 2023/07/21
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import SwiftGardenSecrets

struct ShellCall {
    // Ref: https://ja.stackoverflow.com/q/65654
    static func takeImage() throws -> Foundation.URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let currentDateString = dateFormatter.string(from: Date())
        let imageFileName = "\(currentDateString).\(Constants.imageFileExtension)"
        let destinationURL: URL
#if os(Linux)
        let command = "/usr/bin/libcamera-jpeg"
        let parameter1 = "-o"
        let imagePath = "\(Secrets.Other.piHomePath)/\(Constants.imageParentDirectoryName)/\(imageFileName)"
        try shell(command, parameter1, imagePath)
        // If on linux, `Path.current` returns repository path
        destinationURL = url(fileURLWithPath: imagePath)
#else
        var currentFileURL = Foundation.URL(filePath: #file)
        currentFileURL.deleteLastPathComponent() // Delete file name

        let fileManager = FileManager.default
        let sourcePath = currentFileURL.appending(path: "../\(Constants.imageParentDirectoryName)/sample.\(Constants.imageFileExtension)").absoluteString
            .replacingOccurrences(of: "file://", with: "")
        let sourceURL = URL(fileURLWithPath: sourcePath)
        let destinationPath = currentFileURL.appending(path: "../\(Constants.imageParentDirectoryName)/\(imageFileName)").absoluteString
            .replacingOccurrences(of: "file://", with: "")

        destinationURL = URL(fileURLWithPath: destinationPath)
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
#endif
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return destinationURL
        } else {
            fatalError("Image file don't exist!")
        }
    }

    static func sendImage(token: String, fileURL: URL) throws {
        let command = "curl"
        let fileName = "169065112.jpeg"
        let URL = URL(string: "https://storage.googleapis.com/upload/storage/v1/b/mydevelopment-cdc30.appspot.com/o?name=Images%2F\(fileName)&uploadType=media")!
        print(fileURL.path)
        let httpOption = "--http1.1"
//        let parameters: String... = [
//
//            //            "-H", "Accept: */*",
//        ]
        let result = try shell(
            command,
            httpOption,
            "-X", "POST",
            "-H", "Content-Type: image/jpeg",
            "-H", "Authorization: Bearer \(token)",
            "--data-binary", "@\(fileURL.path)",
            "-H", "Content-Length: 123",
            URL.absoluteString
        )
        print("Result: \(result)")
    }

    @discardableResult
    static func shell(_ args: String...) throws ->  Int32 {
        let process = Process()
        process.executableURL = Foundation.URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = args
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        print("Running command: \(process.executableURL!.path) \(process.arguments!.joined(separator: " "))")
        try process.run()
        process.waitUntilExit()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: outputData, encoding: .utf8) {
            print(output)
        } else {
            print("Failed to decode output.")
        }
        return process.terminationStatus
    }
}
