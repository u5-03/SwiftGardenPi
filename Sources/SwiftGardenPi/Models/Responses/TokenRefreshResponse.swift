//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct TokenRefreshResponse: Decodable {
    let accessToken: String
    let expiresIn: Int
    let scope: String
    let tokenType: String
}
