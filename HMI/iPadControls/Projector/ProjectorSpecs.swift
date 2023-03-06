//
//  ProjectorSpecs.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/3/21.
//  Copyright © 2021 WET. All rights reserved.
//

import Foundation

struct PROJECTOR_STATS{
    var pos1 = 0
    var pos2 = 0
    var pos3 = 0
    var pos4 = 0
    var pos5 = 0
    var pos6 = 0
    var pos7 = 0
    var liftSchOn = 0
    var liftStatus = 0
    var liftHOAStatus = 0
    var liftHandCmd = 0
    var liftHOATrigger = 0
}

let WALL1_HANDCMD = 8004
let WALL2_HANDCMD = 8009
let WALL3_HANDCMD = 8014

let PROJ_WARNING_TEMP = 29
let PROJ_FAULT_TEMP   = 35
let WALL1_HOA_STATUS = 8005
let WALL1_MIRROR_STATUS = 8016

let WALL1_HOA_TRIGCMD = 8005
let WALL2_HOA_TRIGCMD = 8010
let WALL3_HOA_TRIGCMD = 8015

let WALL1_LIFTSTATUS = 8002

let READ_PRJ_SERVER_PATH              = "readPrjSch"
let WRITE_PRJ_SERVER_PATH             = "writePrjSch"
