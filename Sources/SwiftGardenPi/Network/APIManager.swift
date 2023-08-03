//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Alamofire

final class APIManager {
    static func send<T: Decodable>(request: AlamofireRequest) async throws -> T {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // return try await withCheckedThrowingContinuation { continuation in
        //     do {
        //         // URLRequestを作成します
        //         var urlRequest = URLRequest(url: Foundation.URL(string: "https://storage.googleapis.com/upload/storage/v1/b/mydevelopment-cdc30.appspot.com/o?uploadType=media&name=Images%2F1690651182.jpeg")!)
        //         urlRequest.httpMethod = "POST"
        //         urlRequest.allHTTPHeaderFields = request
        //             .headers.map({ $0.dictionary })
        //         urlRequest.httpBody = FileManager.default.contents(atPath: (request as! AlamofireUploadRequest).fileURL.path)
        //         URLSession.shared.uploadTask(with: urlRequest, fromFile: try! (request as! AlamofireUploadRequest).fileURL.asURL()) { (data, response, error) in
        //             let decoder = JSONDecoder()
        //             decoder.keyDecodingStrategy = .convertFromSnakeCase
        //             if let httpResponse = response as? HTTPURLResponse {
        //                 if httpResponse.statusCode == 200 {
        //                     print("URL is reachable.")
        //                 } else {
        //                     print("URL is not reachable. Status code: \(httpResponse.statusCode)")
        //                 }
        //             }
        //             if let error = error {
        //                 continuation.resume(throwing: error)
        //             } else if let data = data {
        //                 let response: T = try! data.decoded(usingDecoder: decoder)
        //                 continuation.resume(returning: response)
        //             } else {
        //                 fatalError("This is fatal error!")
        //             }
        //         }
        //         URLSession.shared.dataTask(with: urlRequest) { data, response, error in
        //             let decoder = JSONDecoder()
        //             decoder.keyDecodingStrategy = .convertFromSnakeCase
        //             if let httpResponse = response as? HTTPURLResponse {
        //                 if httpResponse.statusCode == 200 {
        //                     print("URL is reachable.")
        //                 } else {
        //                     print("URL is not reachable. Status code: \(httpResponse.statusCode)")
        //                 }
        //             }
        //             if let error = error {
        //                 continuation.resume(throwing: error)
        //             } else if let data = data {
        //                 let response: T = try! data.decoded(usingDecoder: decoder)
        //                 continuation.resume(returning: response)
        //             } else {
        //                 fatalError("This is fatal error!")
        //             }
        //         }
        //         .resume()
        //         print("Request did finished!")
        //     } catch {
        //         continuation.resume(throwing: error)
        //     }
        // }
       return try await withCheckedThrowingContinuation { continuation in
           do {
               // URLRequestを作成します
               var urlRequest = URLRequest(url: try! request.URL.asURL())
//                urlRequest.httpMethod = "POST"
               urlRequest.httpMethod = "POST"
               urlRequest.allHTTPHeaderFields = request
                   .headers.map({ $0.dictionary })
               urlRequest.httpBody = FileManager.default.contents(atPath: (request as! AlamofireUploadRequest).fileURL.path)
               URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                   let decoder = JSONDecoder()
                   decoder.keyDecodingStrategy = .convertFromSnakeCase
                   if let error = error {
                       continuation.resume(throwing: error)
                   } else if let data = data {
                       let response: T = try! data.decoded(usingDecoder: decoder)
                       continuation.resume(returning: response)
                   } else {
                       fatalError("This is fatal error!")
                   }
               }
                   .resume()
           } catch {
               continuation.resume(throwing: error)
           }
       }

        // // URLRequestを作成します
        // var urlRequest = URLRequest(url: try! request.URL.asURL())
        // urlRequest.httpMethod = "POST"
        // urlRequest.httpBody = FileManager.default.contents(atPath: (request as! AlamofireUploadRequest).fileURL.path)

        // // 非同期タスクを作成し、URLRequestを使ってデータを送信します

        // let (data, response) = try await URLSession.shared.data(for: urlRequest)
        // let decoder = JSONDecoder()
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        // return try data.decoded(usingDecoder: decoder)


//
//        // レスポンスを処理します
//        if let error = error {
//            print("Error: \(error)")
//        } else if let data = data, let response = response as? HTTPURLResponse {
//            print("Status code: \(response.statusCode)")
//            print("Response data: \(data)")
//        }
//
//        let result: DataResponse<T, AFError>
//        if let dataRequest = request.asDataRequest {
//            result = await dataRequest.serializingDecodable(T.self, decoder: decoder).response
//        } else if let dataPostRequest = request.asPostRequest {
//            result = await dataPostRequest.serializingDecodable(T.self, decoder: decoder).response
//        } else if let uploadRequest = request.asUploadRequest {
//            result = await uploadRequest.serializingDecodable(T.self, decoder: decoder).response
//        } else {
//            throw SwiftGardenError.invalidRequest
//        }
//
//        print("ℹ️ RequestURL: \(try! request.URL.asURL().absoluteString), Headers: \(request.headers ?? [:]), statuscode: \(result.response?.statusCode ?? 0)")
//        if let statusCode = result.response?.statusCode, statusCode != 200 {
//            throw SwiftGardenError.errorRespoonse(statusCode: statusCode)
//        } else {
//            switch result.result {
//            case .success(let response):
//                return response
//            case .failure(let error):
//                throw error
//            }
//        }
    }
}
