//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

enum URLList {
    case tokenRefresh
    case postStorage
    case firestore
    case switchbotMeter
    case switchbotPlug

    var urlString: String {
        switch self {
        case .tokenRefresh:
            return "https://accounts.google.com/o/oauth2/token"
        case .postStorage:
            return "https://storage.googleapis.com/upload/storage/v1/b/\(Secrets.Firebase.projectId)/o?uploadType=media"
        case .firestore:
            return "https://firestore.googleapis.com/v1/projects/\(Secrets.Firebase.projectShortId)/databases/(default)/documents/\(Secrets.Firebase.Firestore.collectionId)"
        case .switchbotMeter:
            return "https://api.switch-bot.com/v1.1/devices/\(Secrets.Switchbot.meterDeviceId)/status"
        case .switchbotPlug:
            return "https://api.switch-bot.com/v1.0/devices/\("")/commands"
        }
    }

    var URL: Foundation.URL {
        Foundation.URL(string: urlString)!
    }
}
