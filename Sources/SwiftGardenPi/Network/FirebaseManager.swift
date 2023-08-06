//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Alamofire
import NIO
import AsyncHTTPClient

enum RequestType {
    case normal(request: AlamofireRequest)
    case file(request: AlamofireRequest, fileURL: URL)
    
    var request: AlamofireRequest {
        switch self {
        case .normal(let request): return request
        case .file(let request, _): return request
        }
    }
    
    func asAccessTokenReplaced(token: String) -> RequestType {
        func tokenReplacedRequest(request: AlamofireRequest, token: String) -> AlamofireRequest {
            return request.tokenReplaced(token: token)
        }
        switch self {
        case .normal(let request):
            return .normal(request: tokenReplacedRequest(request: request, token: token))
        case .file(let request, let fileURL):
            return .file(request: tokenReplacedRequest(request: request, token: token), fileURL: fileURL)
        }
    }
}

final class FirebaseManager {
    static func postImage(fileURL: URL) async throws -> CloudStoragePostResponse {
        let fileName = fileURL.lastPathComponent
        let headers: Alamofire.HTTPHeaders = [
            .authorization("Bearer \(accessToken)"),
            .contentType("image/\(Constants.imageFileExtension)")
        ]
        // `appending()` can't be used in Linux
        let requestURL = URL(string: URLList.postStorage.URL.absoluteString + "&name=\(Constants.imageParentDirectoryName)/\(fileName)")!
        let request = AlamofireUploadRequest(
            fileURL: fileURL,
            URL: requestURL,
            method: .post,
            headers: headers
        )
        return try await send(request: request)
    }
    
    static func postImageWithFormURLRequest(fileURL: URL) async throws -> CloudStoragePostResponse {
        func createFormData(boundary: String, data: Data, mimeType: String, filename: String) -> Data {
            var body = Data()

            let boundaryPrefix = "--\(boundary)\r\n"

            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--".appending(boundary.appending("--")).data(using: .utf8)!)

            return body
        }
        
        let fileName = fileURL.lastPathComponent
        // `appending()` can't be used in Linux
        let requestURL = URL(string: URLList.postStorage.URL.absoluteString + "&name=\(Constants.imageParentDirectoryName)/\(fileName)")!
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "post"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "*/*",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "image/\(Constants.imageFileExtension)",
        ]
        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        let imageData = try? Data(contentsOf: fileURL)
        let formData = createFormData(boundary: boundary, data: imageData!, mimeType: "image/jpeg", filename: fileName)

        urlRequest.httpBody = formData

        return try await send(request: urlRequest, fileURL: nil)
    }
    
    static func postImageWithURLRequest(fileURL: URL) async throws -> CloudStoragePostResponse {
        let fileName = fileURL.lastPathComponent
        // `appending()` can't be used in Linux
        let requestURL = URL(string: URLList.postStorage.URL.absoluteString + "&name=\(Constants.imageParentDirectoryName)/\(fileName)")!
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "post"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "*/*",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "image/\(Constants.imageFileExtension)",
        ]
        return try await send(request: urlRequest, fileURL: nil)
    }
    
    static let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    static func refreshToken() async throws -> TokenRefreshResponse {
        let requestBody = TokenRefreshRequest(
            clientId: Secrets.Firebase.clientId,
            clientSecret: Secrets.Firebase.clientSecret,
            refreshToken: Secrets.Firebase.refreshToken
        )

        /// MARK: - Using Swift Concurrency
        var request = HTTPClientRequest(url: URLList.tokenRefresh.URL.absoluteString)
        request.method = .POST
        request.headers.add(name: "Accept", value: "*/*")
        request.body = .bytes(ByteBuffer(bytes: try requestBody.asData()))
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        try await httpClient.shutdown()
        if response.status == .ok {
            let byteBuffer = try await response.body.collect(upTo: 1024 * 1024) // 1
            let responseData = Data(byteBuffer.readableBytesView)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(TokenRefreshResponse.self, from: responseData)
        } else {
            throw SwiftGardenError.errorRespoonse(statusCode: Int(response.status.code))
        }
    }
    
    static func postImageWithAsyncHTTPClient(fileURL: URL, retryCount: Int = 0) async throws -> CloudStoragePostResponse {
        if retryCount > retryMaxCount {
            throw SwiftGardenError.retryError
        }

        let fileName = fileURL.lastPathComponent
        let fileData = try Data(contentsOf: fileURL)
        
        let requestURL = URL(string: URLList.postStorage.URL.absoluteString + "&name=\(Constants.imageParentDirectoryName)/\(fileName)")!
        var request = HTTPClientRequest(url: requestURL.absoluteString)
        request.method = .POST
        request.headers.add(name: "Accept", value: "*/*")
        request.headers.add(name: "Authorization", value: "Bearer \(accessToken)")
        request.headers.add(name: "Content-Type", value: "image/\(Constants.imageFileExtension)")
        request.body = .bytes(fileData, length: .known(fileURL.fileByteLength))

        /// MARK: - Using Swift Concurrency
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status.code == 401 {
            let _ = try await fetchNewAccessToken()
            return try await postImageWithAsyncHTTPClient(fileURL: fileURL, retryCount: retryCount + 1)
        }
        print(response.status.code)
        try await httpClient.shutdown()
        if response.status == .ok {
            let byteBuffer = try await response.body.collect(upTo: 1024 * 1024) // 1 MB
            let responseData = Data(byteBuffer.readableBytesView)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(CloudStoragePostResponse.self, from: responseData)
        } else {
            throw SwiftGardenError.errorRespoonse(statusCode: Int(response.status.code))
        }
        
//        let eventLoopFuture = httpClient.execute(request: request).flatMapThrowing { response -> CloudStoragePostResponse in
//            guard response.status == .ok else {
//                print("Failed to upload file: \(response.status)")
//                throw SwiftGardenError.errorRespoonse(statusCode: Int(response.status.code))
//            }
//
//            let byteBuffer = response.body ?? ByteBuffer()
//            let data = Data(byteBuffer.readableBytesView)
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            return try decoder.decode(CloudStoragePostResponse.self, from: data)
//        }
//        try eventLoopFuture.wait()
//        return try await eventLoopFuture.get()

//        return try await withCheckedThrowingContinuation { continuation in
//            do {
//
//            } catch {
//                continuation.resume(throwing: error)
//            }
//        }
    }
 
    static func postData(requestBody: FirestorePostRequest) async throws -> FirestorePostResponse {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let headers: Alamofire.HTTPHeaders = [
            .authorization("Bearer \(accessToken)"),
            .contentType("application/json; charset=UTF-8"),
        ]
        let request = AlamofireDataPostRequest(
            URL: URLList.firestore.URL,
            method: .post,
            parameters: requestBody,
            headers: headers
        )
        return try await send(request: request)
    }
}

extension FirebaseManager {
    private static let retryMaxCount = 2
    static var accessTokenFileURL: URL {
        // `appending()` can't be used in Linux
        URL(fileURLWithPath: #file).deletingLastPathComponent().pathAppendedURL(path: "accessToken.txt")
    }
    
    static var accessToken: String {
        get {
            return try! String(contentsOf: accessTokenFileURL, encoding: .utf8)
                .replacingOccurrences(of: "\n", with: "")
        }
        set {
            try! newValue.write(to: accessTokenFileURL, atomically: true, encoding: .utf8)
        }
    }
    
    static func send<T: Decodable>(request: AlamofireRequest, retryCount: Int = 0) async throws -> T {
        if retryCount > retryMaxCount {
            throw SwiftGardenError.retryError
        }
        do {
            let response: T = try await APIManager.send(request: request)
            print("API Manager Response!")
            return response
        } catch {
            // if http status code is 401, issue new acecss token using refresh token.
            if case SwiftGardenError.errorRespoonse(let statusCode) = error, statusCode == 401 {
                print("------------------------------------------------------------------------------------")
                print("Retry due to status code 401")
                
                let token = try await fetchNewAccessToken()
                print("NewAccessToken: \(token)")
                print("------------------------------------------------------------------------------------")
                return try await send(request: request.tokenReplaced(token: token), retryCount: retryCount + 1)
            } else {
                throw error
            }
        }
    }
    
    static func send<T: Decodable>(request: URLRequest, fileURL: URL?, retryCount: Int = 0) async throws -> T {
        if retryCount > retryMaxCount {
            throw SwiftGardenError.retryError
        }
        do {
            
            let response: T
            if let fileURL = fileURL {
                response = try await APIManager.send(request: request, fileURL: fileURL)
            } else {
                response = try await APIManager.send(request: request)
            }
            print("API Manager Response!")
            return response
        } catch {
            // if http status code is 401, issue new acecss token using refresh token.
            if case SwiftGardenError.errorRespoonse(let statusCode) = error, statusCode == 401 {
                print("------------------------------------------------------------------------------------")
                print("Retry due to status code 401")
                
                let token = try await fetchNewAccessToken()
                print("NewAccessToken: \(token)")
                print("------------------------------------------------------------------------------------")
                var request = request
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                return try await send(request: request, fileURL: fileURL, retryCount: retryCount + 1)
            } else {
                throw error
            }
        }
    }
    
    static func fetchNewAccessToken() async throws -> String {
        let requestBody = TokenRefreshRequest(
            clientId: Secrets.Firebase.clientId,
            clientSecret: Secrets.Firebase.clientSecret,
            refreshToken: Secrets.Firebase.refreshToken
        )
        let headers: Alamofire.HTTPHeaders = [
            HTTPHeader(name: "Accept", value: "*/*")
        ]
        let request = AlamofireDataPostRequest(
            URL: URLList.tokenRefresh.URL,
            method: .post,
            parameters: requestBody,
            headers: headers
        )
        let tokenRefreshResponse: TokenRefreshResponse = try await APIManager.send(request: request)
        accessToken = tokenRefreshResponse.accessToken
        return tokenRefreshResponse.accessToken
    }
}
