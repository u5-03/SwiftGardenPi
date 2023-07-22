//
//  Created by yugo.sugiyama on 2023/07/21
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct ShellCall {
    // Ref: https://ja.stackoverflow.com/q/65654
    static func takeImage() throws -> Foundation.URL {
        let imageFileName = "\(String(Date().timeIntervalSince1970)).\(Constants.imageFileExtension)"
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
    
    @discardableResult
    static func shell(_ args: String...) throws ->  Int32 {
        let task = Process()
        task.executableURL = Foundation.URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = args
        try task.run()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
