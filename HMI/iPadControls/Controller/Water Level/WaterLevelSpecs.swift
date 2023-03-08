//
//  WaterLevelSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/11/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation

//=============== Water Level Specs

public struct WATER_LEVEL_SENSOR_VALUES{
    
    var scaledValue          = 0.0
    var below_l              = 0
    var below_ll             = 0
    var below_lll            = 0
    var above_High           = 0
    var malfunction          = 0
    var waterMakeup          = 0
    var waterMakeupTimeout   = 0
    var channelFault         = 0
    var lsll                 = 0
    
    var above_high_timer     = 0
    var below_l_timer        = 0
    var below_ll_timer       = 0
    var below_lll_timer      = 0
    var makeup_timeout_timer = 0
    var lsll_delayTimer      = 0
    
    var scaledMin          = 0.0
    var scaledMax          = 0.0
    var aboveHighSP        = 0.0
    var belowlSP           = 0.0
    var belowllSP          = 0.0
    var belowlllSP         = 0.0
   
}

let WATER_LEVEL_SETTINGS_SCREEN_SEGUE          = "waterLevelSettings"
let WATER_LEVEL_LANGUAGE_DATA_PARAM            = "waterLevel"

let WATER_LEVEL_SENSOR_BITS_1            = (startBit: 3000, count: 7)

let WATER_LEVEL_LT1001_SCALED_VALUE_BIT        = 3000

/* Note double check with kranti, so far only two water below_ll */
let WATER_LEVEL_TIMER_BITS                     = (startBit: 6526, count: 6)
//Settings Page Timer Registers
//TYPE: INT

let WATER_LEVEL_LT1001_CHANNEL_FAULT_BIT       = 3000
let WATER_LEVEL_LT1001_SCALED_MAX              = 3004
let WATER_LEVEL_LT1001_SCALED_MIN              = 3002
let WATER_LEVEL_ABOVE_H_SP                     = 3012
let WATER_LEVEL_LT1001_BELOW_L_SP              = 3010
let WATER_LEVEL_LT1001_BELOW_LL_SP             = 3008
let WATER_LEVEL_LT1001_BELOW_LLL_SP            = 3006
let WATER_LEVEL_SLIDER_HEIGHT                  = 450.0
let WATER_LEVEL_SLIDER_LOWER_COORDINATE        = 650.0
let WATER_LEVEL_SLIDER_UPPER_COORDINATE        = 200.0


let WATER_LEVEL_ABOVE_H_DELAY_TIMER            = 6526
let WATER_LEVEL_BELOW_L_TIMER                  = 6527
let WATER_LEVEL_BELOW_LL_TIMER                 = 6528
let WATER_LEVEL_BELOW_LLL_TIMER                = 6529
let WATER_MAKEUP_TIMEROUT_TIMER                = 6530
let LSLL1001_DELAYTIMER                        = 6531

let LT1001_WATER_LEVEL_SCALED_VALUE            = 3000
let LT1001_WATER_LEVEL_SCALED_MIN              = 3002
let LT1001_WATER_LEVEL_SCALED_MAX              = 3004
let LT1001_WATER_LEVEL_BELOW_LLL               = 3016
let LT1001_WATER_LEVEL_BELOW_LL                = 3014
let LT1001_WATER_LEVEL_BELOW_L                 = 3012
let LT1001_WATER_ABOVE_HI                      = 3010
