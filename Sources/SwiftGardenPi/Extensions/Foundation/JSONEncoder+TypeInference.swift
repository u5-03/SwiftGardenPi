//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

public extension Encodable {
    func encoded(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        try encoder.encode(self)
    }

    func encodeToJSONData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data? {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(self)
        guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            fatalError()
        }
        let urlEncodedString = json.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        print(urlEncodedString)
        return urlEncodedString.data(using: .utf8)
    }

    func asDictionary(using encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoded(using: encoder)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw EncodingError.invalidValue(jsonObject, EncodingError.Context(codingPath: [], debugDescription: "Object is not of type [String: Any]"))
        }

        return dictionary
    }
    
    func asData(using encoder: JSONEncoder = JSONEncoder()) throws -> Data {
        return try encoder.encode(self)
    }
}
