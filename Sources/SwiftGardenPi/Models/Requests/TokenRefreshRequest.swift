//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct TokenRefreshRequest: Encodable {
    let clientId: String
    let clientSecret: String
    let refreshToken: String
    let grantType = "refresh_token"

    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case grantType = "grant_type"
        case refreshToken = "refresh_token"
    }
}
