//
//  SystemStatusSpecs.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/12/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation


let ETHERNET_STATUS = (startingregister: 121, count: 27)
let STRAINER_STATUS = (startingregister: 4500, count: 27)

let SYSTEM_FAULT_YELLOW = 60
let SYSTEM_FAULT_RED    = 65

let SYSTEM_YELLOW_STATUS = [
    (tag: 1, bitwiseLocation: 0, type:"INT", name: "Clean Strainer"),
    (tag: 2, bitwiseLocation: 1, type:"INT", name: "Br Timeout"),
    (tag: 3, bitwiseLocation: 2, type:"INT", name: "Water Makeup Timeout"),
    (tag: 4, bitwiseLocation: 3, type:"INT", name: "WQ warning")
]

let SYSTEM_RED_STATUS = [
    
    (tag: 10, bitwiseLocation: 0,  type:"INT", name: "Hydraulic Pump Fault"),
    (tag: 11, bitwiseLocation: 1,  type:"INT", name: "Filter Pump Fault"),
    (tag: 12, bitwiseLocation: 2,  type:"INT", name: "Cascade Pump Fault"),
    (tag: 13, bitwiseLocation: 3,  type:"INT", name: "WaterLevel Fault"),
    (tag: 14, bitwiseLocation: 4,  type:"INT", name: "WaterQuality Fault"),
    (tag: 15, bitwiseLocation: 5,  type:"INT", name: "Estop"),
    (tag: 16, bitwiseLocation: 6,  type:"INT", name: "Fog PumpFault"),
    (tag: 17, bitwiseLocation: 7,  type:"INT", name: "Network Fault")
]
