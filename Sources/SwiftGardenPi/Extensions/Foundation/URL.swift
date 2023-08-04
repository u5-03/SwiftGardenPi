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
    
    var fileByteLength: Int {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path),
              let fileSize = attributes[.size] as? Int else { fatalError() }
        return fileSize
    }
}
