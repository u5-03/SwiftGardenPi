//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

public extension Data {
    func decoded<T: Decodable>(usingDecoder decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try decoder.decode(T.self, from: self)
    }
}

public extension Dictionary where Key == String, Value == Any {
    func decoded<T: Decodable>(usingDecoder decoder: JSONDecoder = JSONDecoder()) throws -> T {
        try JSONSerialization
            .data(withJSONObject: self, options: .prettyPrinted)
            .decoded()
    }
}
