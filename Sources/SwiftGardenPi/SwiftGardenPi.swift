import Foundation
// Ref: https://www.hackingwithswift.com/quick-start/concurrency/how-to-make-async-command-line-tools-and-scripts

@main
public struct SwiftGardenPi {
    public static func main() async {
        do {
            let URL = try ShellCall.takeImage()
            let cloudStorageResponse = try await FirebaseManager.postImage(fileURL: URL)
            let switchbotResponse = try await SwitchbotManger.fetchMeterInfo()
            let firestoreRequest = FirestorePostRequest(
                imageName: cloudStorageResponse.name,
                imageURL: cloudStorageResponse.mediaLink,
                date: Date(),
                temperature: switchbotResponse.temperature,
                humidity: switchbotResponse.humidity
            )
//            let firestoreRequest = FirestorePostRequest(
//                imageName: "TestName!",
//                imageURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/mydevelopment-cdc30.appspot.com/o/Images%2F1690133732.181498.jpeg")!,
//                date: Date(),
//                temperature: 22.0,
//                humidity: 70
//            )
            let _ = try await FirebaseManager.postData(requestBody: firestoreRequest)
            print("Completed!")
        } catch {
            print(error)
        }
    }
}
