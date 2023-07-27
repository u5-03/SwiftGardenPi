//
//  Created by yugo.sugiyama on 2023/07/28
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

extension Foundation.URL {
    func pathAppendedURL(path: String) -> URL {
#if os(Linux)
        return URL(string: absoluteString + path)!
#else
        return appending(path: path)
#endif
    }
}
