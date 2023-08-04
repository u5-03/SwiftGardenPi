//
//  Created by yugo.sugiyama on 2023/08/02
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
//import PythonKit

final class PythonCall {
//    static func postImage() -> String {
//        let task = Process()
//        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
//
//        // Pythonスクリプトのパスを指定します
//        let pathToScript = "/Users/yugo.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/post_image.py"
//
//        task.arguments = ["python3", pathToScript]
//
//        let outputPipe = Pipe()
//        task.standardOutput = outputPipe
//
//        do {
//            try task.run()
//        } catch {
//            print("An error occurred: \(error)")
//        }
//
//        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(decoding: outputData, as: UTF8.self)
//
//        print(output)
//
//        return output

//        let sys = Python.import("sys")
//        let path: String
//        let postImage: PythonObject
//        #if os(Linux)
//        // If on linux, `Path.current` returns repository path
//        path = "\(FileManager.default.currentDirectoryPath)/Sources/SwiftGardenPi"
//        sys.path.append(path)
//        postImage = Python.import("post_image")
//        #else
//        // If on Mac, `Path.current` returns DerivedData path
//        path = "\(FileManager.default.currentDirectoryPath)/SwiftGardenPi_SwiftGardenPi.bundle/Contents/Resources/"
//        print(path)
//        sys.path.append(path)
//        postImage = Python.import("post_image")
//        #endif
//
//        return postImage.post_image().description
//    }
}
