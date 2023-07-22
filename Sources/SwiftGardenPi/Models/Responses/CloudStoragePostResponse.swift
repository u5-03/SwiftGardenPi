//
//  Created by yugo.sugiyama on 2023/07/22
//  Copyright © 2023 yugo.sugiyama. All rights reserved.
//

import Foundation

struct CloudStoragePostResponse: Decodable {
    let kind: String
    let id: String
    let selfLink: URL
    let mediaLink: URL
    let name: String
    let bucket: String
    let generation: String
    let metageneration: String
    let contentType: String
    let storageClass: String
    let size: String
    let md5Hash: String
    let crc32c: String
    let etag: String
    let timeCreated: String
    let updated: String
    let timeStorageClassUpdated: String
}

// Sample Response
//{
//  "kind": "storage#object",
//  "id": "(ProjectID)/Images/storage_sample_image.png/1690011077606576",
//  "selfLink": "https://www.googleapis.com/storage/v1/b/(ProjectID)/o/Images%2Fstorage_sample_image.png",
//  "mediaLink": "https://storage.googleapis.com/download/storage/v1/b/(ProjectID)/o/Images%2Fstorage_sample_image.png?generation=1690011077606576&alt=media",
//  "name": "Images/storage_sample_image.png",
//  "bucket": "(ProjectID)",
//  "generation": "1690011077606576",
//  "metageneration": "1",
//  "contentType": "image/png",
//  "storageClass": "STANDARD",
//  "size": "1039254",
//  "md5Hash": "J6a/Q5Y90eYT91eLXlNUwQ==",
//  "crc32c": "J7JKcA==",
//  "etag": "CLD5ye/loYADEAE=",
//  "timeCreated": "2023-07-22T07:31:17.789Z",
//  "updated": "2023-07-22T07:31:17.789Z",
//  "timeStorageClassUpdated": "2023-07-22T07:31:17.789Z"
//}
