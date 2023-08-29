//
//  Created by yugo.sugiyama on 2023/07/23
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct SwitchbotResponse<T: Decodable>: Decodable {
    let message: String
    let statusCode: Int
    let body: T
}

struct SwitchbotMeterStatusResponse: Decodable {
    let deviceId: String
    let humidity: Int
    let deviceType: String
    let hubDeviceId: String
    let temperature: Double
    let version: String
    let battery: Int
}

//Sample Response
//{
//  "message" : "success",
//  "statusCode" : 100,
//  "body" : {
//    "deviceId" : (DeviceID),
//    "humidity" : 74,
//    "deviceType" : "Meter",
//    "hubDeviceId" : (Hub DeviceID),
//    "temperature" : 24.199999999999999,
//    "version" : "V2.5",
//    "battery" : 98
//  }
//}
