//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Alamofire

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
