//
//  Created by yugo.sugiyama on 2023/08/02
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import PythonKit
import SwiftGardenSecrets

final class PythonCall {
    init() {
        // call only once
        let pythonPath: String
#if os(Linux)
        pythonPath = "/lib/arm-linux-gnueabihf/libpython3.9.so"
#else
        pythonPath = Secrets.Other.macPythonPath
#endif
        PythonKit.PythonLibrary.useLibrary(at: pythonPath)
        do {
            try PythonLibrary.loadLibrary()
        } catch {
            print(error)
        }
    }

    static func generateSwitchbotSign() throws -> String {
        let token = Secrets.Switchbot.token
        let secret = Secrets.Switchbot.clientSecret

        let path: String
#if os(Linux)
        path = "\(Secrets.Other.repositoryPath)/SwiftGardenPi/Sources/SwiftGardenPi"
#else
        path = "\(FileManager.default.currentDirectoryPath)/Sources/SwiftGardenPi"
#endif
        let sys = Python.import("sys")
        sys.path.append(path)
        let generateSignObject = Python.import("generate_sign")

        let result = generateSignObject.generate_sign(token, secret)
        return result.description
    }

    static func postImage() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")

        // Pythonスクリプトのパスを指定します
        let pathToScript = "\(Secrets.Other.piHomePath)/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/post_image.py"

        task.arguments = ["python3", pathToScript]

        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        do {
            try task.run()
        } catch {
            print("An error occurred: \(error)")
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)

        print(output)

        return output

        let sys = Python.import("sys")
        let path: String
        let postImage: PythonObject
#if os(Linux)
        // If on linux, `Path.current` returns repository path
        path = "\(FileManager.default.currentDirectoryPath)/Sources/SwiftGardenPi"
        sys.path.append(path)
        postImage = Python.import("post_image")
#else
        // If on Mac, `Path.current` returns DerivedData path
        path = "\(FileManager.default.currentDirectoryPath)/SwiftGardenPi_SwiftGardenPi.bundle/Contents/Resources/"
        print(path)
        sys.path.append(path)
        postImage = Python.import("post_image")
#endif

        return postImage.post_image().description
    }
}

