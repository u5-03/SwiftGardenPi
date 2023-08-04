//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Alamofire

final class APIManager {    
    static func send<T: Decodable>(request: AlamofireRequest) async throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result: DataResponse<T, AFError>
        if let dataRequest = request.asDataRequest {
            result = await dataRequest.serializingDecodable(T.self, decoder: decoder).response
        } else if let dataPostRequest = request.asPostRequest {
            result = await dataPostRequest.serializingDecodable(T.self, decoder: decoder).response
        } else if let uploadRequest = request.asUploadRequest {
            result = await uploadRequest.serializingDecodable(T.self, decoder: decoder).response
        } else {
            throw SwiftGardenError.invalidRequest
        }

        print("ℹ️ RequestURL: \(try! request.URL.asURL().absoluteString), Headers: \(request.headers ?? [:]), statuscode: \(result.response?.statusCode ?? 0)")
        if let statusCode = result.response?.statusCode, statusCode != 200 {
            throw SwiftGardenError.errorRespoonse(statusCode: statusCode)
        } else {
            switch result.result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
    }
    
    // swift on linux can't use async API code
    // Ref: https://stackoverflow.com/a/70317744
//    static func send<T: Decodable>(request: URLRequest) async throws -> T {
//        let (data, response) = try await URLSession.shared.data(for: request)
//        print("ℹ️ RequestURL: \((request.url?.absoluteString) ?? "")")
//        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
//            throw SwiftGardenError.errorRespoonse(statusCode: response.statusCode)
//        } else {
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            return try data.decoded(usingDecoder: decoder)
//        }
//    }

    static func send<T: Decodable>(request: URLRequest) async throws -> T {
        print("ℹ️ RequestURL: \((request.url?.absoluteString) ?? "")")
        return try await withCheckedThrowingContinuation { continuation in
            // URLRequestを作成します
            URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    continuation.resume(throwing: SwiftGardenError.errorRespoonse(statusCode: response.statusCode))
                } else if let data = data {
                    let response: T = try! data.decoded(usingDecoder: decoder)
                    continuation.resume(returning: response)
                } else {
                    fatalError("This is fatal error!")
                }
            }
            .resume()
        }
    }
    
    static func send<T: Decodable>(request: URLRequest, fileURL: URL) async throws -> T {
        print("ℹ️ RequestURL: \((request.url?.absoluteString) ?? "")")
        return try await withCheckedThrowingContinuation { continuation in
            // URLRequestを作成します
            URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                    continuation.resume(throwing: SwiftGardenError.errorRespoonse(statusCode: response.statusCode))
                } else if let data = data {
                    let response: T = try! data.decoded(usingDecoder: decoder)
                    continuation.resume(returning: response)
                } else {
                    fatalError("This is fatal error!")
                }
            }
            .resume()
        }
    }
}

