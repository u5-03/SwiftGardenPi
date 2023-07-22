//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct FirestorePostRequest {
    let imageName: String
    let imageURL: URL
    let timestamp: String
    let temperature: Double
    let humidity: Int

    init(imageName: String, imageURL: URL, date: Date, temperature: Double, humidity: Int) {
        self.imageName = imageName
        self.imageURL = imageURL
        let formatter = DateFormatter()
        // change format to be treated as Timestamp type of Firebase
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        timestamp = formatter.string(from: date)
        self.temperature = temperature
        self.humidity = humidity
    }

    enum CodingKeys: String, CodingKey {
        case fields
    }

    enum FieldsKeys: String, CodingKey {
        case imageName
        case imageURL
        case timestamp
        case temperature
        case humidity
    }
}

// Used in linux CLI app using RestAPI
extension FirestorePostRequest: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var fieldsContainer = container.nestedContainer(keyedBy: FieldsKeys.self, forKey: .fields)
        try fieldsContainer.encode(["stringValue": imageName], forKey: .imageName)
        try fieldsContainer.encode(["stringValue": imageURL], forKey: .imageURL)
        try fieldsContainer.encode(["timestampValue": timestamp], forKey: .timestamp)
        try fieldsContainer.encode(["doubleValue": temperature], forKey: .temperature)
        try fieldsContainer.encode(["integerValue": humidity], forKey: .humidity)
    }
}

// Used in iOS app using Firebase SDK
extension FirestorePostRequest: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FieldsKeys.self)
        imageName = try container.decode(String.self, forKey: .imageName)
        imageURL = try container.decode(URL.self, forKey: .imageURL)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        temperature = try container.decode(Double.self, forKey: .temperature)
        humidity = try container.decode(Int.self, forKey: .humidity)
    }
}

// Sample request body
//{
//  "fields": {
//    "testtest": {
//      "stringValue": "test"
//    },
//    "datedate": {
//      "timestampValue": "2023-07-31T13:51:54.107Z"
//    }
//  }
//}
