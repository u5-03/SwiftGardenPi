//
//  Created by yugo.sugiyama on 2023/07/23
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
import Crypto
import Alamofire

struct SwitchbotAuthInfo {
    let nonce: String
    let timestamp: String
    let sign: String
    let token: String
}

final class SwitchbotManger {
    // Ref: https://github.com/OpenWonderLabs/SwitchBotAPI#authentication
    static func generateAuthInfo() -> SwitchbotAuthInfo {
        let token = Secrets.Switchbot.token
        let secret = Secrets.Switchbot.clientSecret
        // 13digits timestamp is required
        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
        let nonce = UUID().uuidString
        let data = token + timestamp + nonce

        let key = SymmetricKey(data: secret.data(using: .utf8)!)
        let hmac = HMAC<SHA256>.authenticationCode(for: data.data(using: .utf8)!, using: key)
        let sign = Data(hmac).base64EncodedString()

        return .init(nonce: nonce, timestamp: timestamp, sign: sign, token: token)
    }

    static func fetchMeterInfo() async throws -> SwitchbotMeterStatusBodyResponse {
        let authInfo = generateAuthInfo()
        let headers: Alamofire.HTTPHeaders = [
            .authorization(authInfo.token),
            .init(name: "sign", value: authInfo.sign),
            .init(name: "t", value: authInfo.timestamp),
            .init(name: "nonce", value: authInfo.nonce)
        ]
        let request = AlamofireDataRequest(
            URL: URLList.switchbotMeter.URL,
            method: .get,
            headers: headers
        )

        let response: SwitchbotMeterStatusResponse = try await APIManager.send(request: request)
        return response.body
    }
}
