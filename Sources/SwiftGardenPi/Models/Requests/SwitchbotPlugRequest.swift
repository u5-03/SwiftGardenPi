//
//  SwitchbotSwitchRequest.swift
//  
//
//  Created by Yugo Sugiyama on 2023/08/07.
//

import Foundation

struct SwitchbotPlugRequest: Encodable {
    let command: String
    let parameter: String
    let commandType: String
}
