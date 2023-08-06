//
//  Created by yugo.sugiyama on 2023/07/23
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation
//import Crypto
import Alamofire

struct SwitchbotAuthInfo: Decodable {
    let nonce: String
    let timestamp: String
    let sign: String
    let token: String
}

final class SwitchbotManger {
    // Ref: https://github.com/OpenWonderLabs/SwitchBotAPI#authentication
    static func generateAuthInfo() throws -> SwitchbotAuthInfo {
        let jsonString = try PythonCall.generateSwitchbotSign()
        let jsonData = jsonString.data(using: .utf8)!
        let info = try JSONDecoder().decode(SwitchbotAuthInfo.self, from: jsonData)
        return info
        // code using Crypto
        //        let token = Secrets.Switchbot.token
        //        let secret = Secrets.Switchbot.clientSecret
        //        // 13digits timestamp is required
        //        // my RaspberryPi is 32bit, so length of digits of Int.max is smaller than date value.
        //        // so use Int64
        //        // https://qiita.com/shimesaba/items/dbbc0f4ec80d011273d6
        //        let timestamp = String(Int64(Date().timeIntervalSince1970 * 1000))
        //        let nonce = UUID().uuidString
        //        let data = token + timestamp + nonce
        //
        //        let key = SymmetricKey(data: secret.data(using: .utf8)!)
        //        let hmac = HMAC<SHA256>.authenticationCode(for: data.data(using: .utf8)!, using: key)
        //        let sign = Data(hmac).base64EncodedString()
        //
        //        return .init(nonce: nonce, timestamp: timestamp, sign: sign, token: token)
    }
    
    static func fetchMeterInfo() async throws -> SwitchbotMeterStatusResponse {
        let authInfo = try generateAuthInfo()
        let headers: Alamofire.HTTPHeaders = [
            .authorization(authInfo.token),
            .init(name: "sign", value: authInfo.sign),
            .init(name: "t", value: String(authInfo.timestamp)),
            .init(name: "nonce", value: authInfo.nonce)
        ]
        let request = AlamofireDataRequest(
            URL: URLList.switchbotMeter.URL,
            method: .get,
            headers: headers
        )
        
        let response: SwitchbotResponse<SwitchbotMeterStatusResponse> = try await APIManager.send(request: request)
        return response.body
    }
    
    @discardableResult
    static func postSwitchBot(isON: Bool) async throws -> EmptyResponse {
        let authInfo = try generateAuthInfo()
        let headers: Alamofire.HTTPHeaders = [
            .authorization(authInfo.token),
            .init(name: "sign", value: authInfo.sign),
            .init(name: "t", value: String(authInfo.timestamp)),
            .init(name: "nonce", value: authInfo.nonce),
            .contentType("application/json"),
            .acceptCharset("utf8"),
        ]
        let body = SwitchbotPlugRequest(
            command: isON ? "turnOn" : "turnOff",
            parameter: "default",
            commandType: "command"
        )
        
        let request = AlamofireDataPostRequest(
            URL: URLList.switchbotPlug.URL,
            method: .post,
            parameters: body,
            headers: headers
        )
        
        let response: SwitchbotResponse<EmptyResponse> = try await APIManager.send(request: request)
        if response.statusCode == 200 {
            return response.body
        } else {
            throw SwiftGardenError.unknown
        }
    }
}
