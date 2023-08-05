//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

enum Secrets {
    enum Firebase {
        static let refreshToken = "1//0eKPVeFiBndxNCgYIARAAGA4SNwF-L9IrLdweWWHHLXs_XcGSTL8Yu7AGM0H3bcTk1Swgw7xjbBgPHMkwL0PRH1UKYOjH6S4HWUM"
        static let clientId = "682256760035-7srpt172gpd1om7i0a1pjkafh2c15va1.apps.googleusercontent.com"
        static let clientSecret = "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"
        static let projectId = "\(projectShortId).appspot.com"
        static let projectShortId = "mydevelopment-cdc30"
        enum Firestore {
            static let collectionId = "swiftGarden"
        }
    }


    enum Switchbot {
        static let token = "0e39c49e373842bb279f2fb06b7718aaf54b8273cac9b272f839ebb791a97a3b1ae3668d7154a87446de55fe36d23a59"
        static let clientSecret = "65db1e876961bc3f83a84610b63882e1"
        static let meterDeviceId = "F0011D2866AA"
    }
    
    public enum Other {
        public static let macPythonPath = "/Users/yugo.a.sugiyama/.pyenv/versions/3.10.6/lib/libpython3.10.dylib"
    }
}
