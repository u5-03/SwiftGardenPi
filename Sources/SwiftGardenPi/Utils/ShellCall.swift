//
//  Created by yugo.sugiyama on 2023/07/21
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct ShellCall {
    // Ref: https://ja.stackoverflow.com/q/65654
    static func takeImage() throws -> Foundation.URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let currentDateString = dateFormatter.string(from: Date())
        let imageFileName = "\(currentDateString).\(Constants.imageFileExtension)"
        let destinationURL: URL
#if os(Linux)
        let command = "/usr/bin/libcamera-still"
        let parameter1 = "-o"
        let parameter2 = "\(Constants.imageParentDirectoryName)/\(imageFileName)"
        try shell(command, parameter1, parameter2)
        // If on linux, `Path.current` returns repository path
        let imagePath = "\(FileManager.default.currentDirectoryPath)/\(Constants.imageParentDirectoryName)/\(imageFileName)"
        destinationURL = URL(fileURLWithPath: imagePath)
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

    static func hoge() throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")

        let filePath = "/Users/yugo.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/Images/1690651182.jpeg" // ここに送信したいファイルのパスを指定します
        let firebaseBucket = "mydevelopment-cdc30.appspot.com" // ここにFirebaseプロジェクトのストレージバケット名を指定します
        let firebaseToken = FirebaseManager.accessToken // ここにFirebaseの認証トークンを指定します
        let fileName = "1690651182.jpeg" // ここにアップロード後のファイル名を指定します

        let url = "https://firebasestorage.googleapis.com/v0/b/\(firebaseBucket)/o/\(fileName)?uploadType=media&name=\(fileName)"

        process.arguments = ["curl", "-X", "POST", "-H", "Content-Type: image/jpeg", "-H", "Authorization: Bearer \(firebaseToken)", "Content-Length: 720925", "--data-binary", "@\(filePath)", url]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Error: \(error.localizedDescription)")
        }

        if process.terminationStatus == 0 {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: outputData, encoding: .utf8) {
                print("Program output:", output)
            }
        } else {
            print("Error: program exited with status \(process.terminationStatus)")
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
//    /usr/bin/curl --http1.1 -X POST \
//      'https://storage.googleapis.com/upload/storage/v1/b/mydevelopment-cdc30.appspot.com/o?name=Images%2F1690651182.jpeg&uploadType=media' \
//      --header 'Accept: */*' \
//      --header 'Content-Type: image/jpeg' \
//      --header 'Authorization: Bearer ya29.a0AbVbY6OBbIr1cUPbyu2Hd_urUzrQEtsx_oWBI16MC2k77TIo5GaSQVp8AdlouoHRZGAPesxK0sXfYmmwt4IillfwZ5M1IN-Wp1o0c41Pi07JIT0iiShTP0lRdNAex5RHQi3GPhyvh_gvBtpKCr0J5ID_f5bqY08vaCgYKAZgSARMSFQFWKvPldj-AgehiZz44Jbu6UlaWqQ0167' \
//      --data-binary '@/Users/yugo.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/Images/1690651182.jpeg'



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
