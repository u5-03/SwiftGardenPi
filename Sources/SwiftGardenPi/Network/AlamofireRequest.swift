//
//  Created by yugo.a.sugiyama on 2023/07/24
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Alamofire

protocol AlamofireRequest {
    var URL: URLConvertible { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var asRequest: Request { get }
    var asDataRequest: DataRequest? { get }
    var asPostRequest: DataRequest? { get }
    var asUploadRequest: UploadRequest? { get }
    
    func tokenReplaced(token: String) -> AlamofireRequest
}

extension AlamofireRequest {
    var asDataRequest: DataRequest? {
        asRequest as? DataRequest
    }
    
    var asPostRequest: DataRequest? {
        asDataRequest
    }
    
    var asUploadRequest: UploadRequest? {
        asRequest as? UploadRequest
    }
}

struct AlamofireDataRequest: AlamofireRequest {
    let URL: URLConvertible
    let method: HTTPMethod
    let headers: HTTPHeaders?
    
    var asRequest: Request {
        AF.request(
            URL,
            method: method,
            headers: headers
        )
    }
    
    func tokenReplaced(token: String) -> AlamofireRequest {
        var tempHeaders = headers
        tempHeaders?.add(name: "Authorization", value: "Bearer \(token)")
        return AlamofireDataRequest(
            URL: URL,
            method: method,
            headers: tempHeaders
        )
    }
}

struct AlamofireDataPostRequest<T: Encodable>: AlamofireRequest {
    let URL: URLConvertible
    let method: HTTPMethod
    let parameters: T
    let headers: HTTPHeaders?
    
    var asRequest: Request {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return AF.request(
            URL,
            method: method,
            parameters: parameters,
            encoder: .json,
            headers: headers
        )
    }
    
    func tokenReplaced(token: String) -> AlamofireRequest {
        var tempHeaders = headers
        tempHeaders?.add(name: "Authorization", value: "Bearer \(token)")
        return AlamofireDataPostRequest(
            URL: URL,
            method: method,
            parameters: parameters,
            headers: tempHeaders
        )
    }
}

struct AlamofireUploadRequest: AlamofireRequest {
    let fileURL: URL
    let URL: URLConvertible
    let method: HTTPMethod
    let headers: HTTPHeaders?
    
    var asRequest: Request {
        AF.upload(
            fileURL,
            to: URL,
            method: method,
            headers: headers
        )
    }
    
    func tokenReplaced(token: String) -> AlamofireRequest {
        var tempHeaders = headers
        tempHeaders?.add(name: "Authorization", value: "Bearer \(token)")
        return AlamofireUploadRequest(
            fileURL: fileURL,
            URL: URL,
            method: method,
            headers: tempHeaders
        )
    }
}
