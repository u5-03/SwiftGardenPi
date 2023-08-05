import Foundation
// Ref: https://www.hackingwithswift.com/quick-start/concurrency/how-to-make-async-command-line-tools-and-scripts

@main
public struct SwiftGardenPi {
    public static func main() async {
        do {
//             let result = try PythonCall.postImage()
            // print(result)
            // return
            // try ShellCall.sendImage(token: FirebaseManager.accessToken, fileURL: URL(fileURLWithPath: "/Users/yugo.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/Images/1690651182.jpeg"))
            // return
            //
            
            let URL = try ShellCall.takeImage()
//            let URL = URL(fileURLWithPath: "/Users/yugo.a.sugiyama/Dev/Swift/SwiftGarden/SwiftGardenPi/Sources/SwiftGardenPi/Images/20230803234005.jpeg")
//            let cloudStorageResponse = try await FirebaseManager.postImage(fileURL: URL)
            
            let cloudStorageResponse = try await FirebaseManager.postImageWithAsyncHTTPClient(fileURL: URL)
            let switchbotResponse = try await SwitchbotManger.fetchMeterInfo()
            print(switchbotResponse)
            let firestoreRequest = FirestorePostRequest(
                imageName: cloudStorageResponse.name,
                imageURL: cloudStorageResponse.mediaLink,
                date: Date(),
                temperature: switchbotResponse.temperature,
                humidity: switchbotResponse.humidity
            )
            //           let firestoreRequest = FirestorePostRequest(
            //               imageName: "TestName!",
            //               imageURL: Foundation.URL(string: "https://firebasestorage.googleapis.com/v0/b/mydevelopment-cdc30.appspot.com/o/Images%2F1690133732.181498.jpeg")!,
            //               date: Date(),
            //               temperature: 22.0,
            //               humidity: 70
            //           )
            let _ = try await FirebaseManager.postData(requestBody: firestoreRequest)
            print("Completed!")
        } catch {
            print(error)
        }
    }
}
