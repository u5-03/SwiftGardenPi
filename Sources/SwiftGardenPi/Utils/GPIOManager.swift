//
//  GPIOManager.swift
//  
//
//  Created by Yugo Sugiyama on 2023/08/07.
//

import Foundation
import SwiftyGPIO

final class GPIOManager {
    static let shared = GPIOManager()
#if os(Linux)
    private let waterDrainGPIO: GPIO
#endif
    
    init() {
#if os(Linux)
        let gpios = SwiftyGPIO.GPIOs(for: .RaspberryPi4)
        
        waterDrainGPIO = gpios[.P21]!
        waterDrainGPIO.direction = .OUT
#else
        print("This is not linux OS!")
#endif
    }
    
    func drainWater(second: Int) async {
#if os(Linux)
        waterDrainGPIO.value = 1
        print("Started draining water")
        try! await Task.sleep(nanoseconds: UInt64(second * 1_000_000_000))
        waterDrainGPIO.value = 0
        print("Stopped draining water")
#else
        print("This is not linux OS!")
        print("Started draining water")
        try! await Task.sleep(nanoseconds: UInt64(second * 1_000_000_000))
        print("Stopped draining water")
#endif
    }
}
