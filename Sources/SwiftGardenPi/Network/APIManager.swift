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
}
