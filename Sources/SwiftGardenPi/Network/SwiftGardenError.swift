//
//  Created by yugo.sugiyama on 2023/07/23
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

enum SwiftGardenError: LocalizedError {
    case retryError
    case unknown
    case errorRespoonse(statusCode: Int)
    case invalidRequest
}
