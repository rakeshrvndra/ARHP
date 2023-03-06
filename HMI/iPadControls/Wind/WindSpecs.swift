//
//  WindSpecs.swift
//  iPadControls
//
//  Created by Jan Manalo on 9/5/18.
//  Copyright © 2018 WET. All rights reserved.
//

import Foundation


let WIND_SCREEN_LANGUAGE_DATA_PARAM = "wind"
//The following UI tags are linked to each UI object for each wind sensor on the User Interface
//We use these UI tags to refer to individual wind speed senser UI elements from the code

let WIND_SPEED_1_UI_TAG                 = 102
let WIND_SPEED_2_UI_TAG                 = 112

let WIND_DIRECTION_1_UI_TAG             = 104
let WIND_DIRECTION_2_UI_TAG             = 114

let WIND_SPEED_MEASURE_UNIT_1_UI_TAG    = 103
let WIND_SPEED_MEASURE_UNIT_2_UI_TAG    = 103

let WIND_SET_POINT_ENABLE_BTN_1_UI_TAG  = 101
let WIND_SET_POINT_ENABLE_BTN_2_UI_TAG  = 111

public struct  WIND_SENSOR_1 {
    
    let SPEED_SCALED_VALUE =        (register:800, type:"REAL",  name: "ST1001_Speed_Scaled_Value")
    let SPEED_LOW_SET_POINT =       (register:802, type:"REAL",  name: "ST1001_Speed_Lo_S")
    let SPEED_HIGH_SET_POINT =      (register:804, type:"REAL",  name: "ST1001_Speed_Hi_SP")
    let SPEED_ABORT_SET_POINT =     (register:806, type:"REAL",  name: "ST1001_Speed_Abort_SP")
    let DIRECTION_SCALED_VALUE =    (register:808, type:"REAL",  name: "ST1001_Drctn_Scaled_Value")
    let SPEED_ABORT_SHOW =          (register:800, type:"EBOOL", name: "ST1001_Speed_Abort_Show")
    let SPEED_ABOVE_HIGH =          (register:801, type:"EBOOL", name: "ST1001_Speed_Above_Hi")
    let SPEED_BELOW_LOW =           (register:802, type:"EBOOL", name: "ST1001_Speed_Below_Low")
    let SPEED_NOWIND =              (register:803, type:"EBOOL", name: "ST1001_speed_NoWind")
    let SPEED_CHANNEL_FAULT =       (register:804, type:"EBOOL", name: "ST1001_Speed_Channel_Fault")
    let DIRECTION_CHANNEL_FAULT =   (register:805, type:"EBOOL", name: "ST1001_Drctn_Channel_Fault")
    
}

public struct  WIND_SENSOR_2 {
    
    let SPEED_SCALED_VALUE =        (register:810, type:"REAL",  name: "ST1001_Speed_Scaled_Value")
    let SPEED_LOW_SET_POINT =       (register:812, type:"REAL",  name: "ST1001_Speed_Lo_S")
    let SPEED_HIGH_SET_POINT =      (register:814, type:"REAL",  name: "ST1001_Speed_Hi_SP")
    let SPEED_ABORT_SET_POINT =     (register:816, type:"REAL",  name: "ST1001_Speed_Abort_SP")
    let DIRECTION_SCALED_VALUE =    (register:818, type:"REAL",  name: "ST1001_Drctn_Scaled_Value")
    let SPEED_ABORT_SHOW =          (register:810, type:"EBOOL", name: "ST1001_Speed_Abort_Show")
    let SPEED_ABOVE_HIGH =          (register:811, type:"EBOOL", name: "ST1001_Speed_Above_Hi")
    let SPEED_BELOW_LOW =           (register:812, type:"EBOOL", name: "ST1001_Speed_Below_Low")
    let SPEED_NOWIND =              (register:813, type:"EBOOL", name: "ST1001_speed_NoWind")
    let SPEED_CHANNEL_FAULT =       (register:814, type:"EBOOL", name: "ST1001_Speed_Channel_Fault")
    let DIRECTION_CHANNEL_FAULT =   (register:815, type:"EBOOL", name: "ST1001_Drctn_Channel_Fault")
    
}

public struct  WIND_SENSOR_3 {
    
    let SPEED_SCALED_VALUE =        (register:820, type:"REAL",  name: "ST1001_Speed_Scaled_Value")
    let SPEED_LOW_SET_POINT =       (register:822, type:"REAL",  name: "ST1001_Speed_Lo_S")
    let SPEED_HIGH_SET_POINT =      (register:824, type:"REAL",  name: "ST1001_Speed_Hi_SP")
    let SPEED_ABORT_SET_POINT =     (register:826, type:"REAL",  name: "ST1001_Speed_Abort_SP")
    let DIRECTION_SCALED_VALUE =    (register:828, type:"REAL",  name: "ST1001_Drctn_Scaled_Value")
    let SPEED_ABORT_SHOW =          (register:820, type:"EBOOL", name: "ST1001_Speed_Abort_Show")
    let SPEED_ABOVE_HIGH =          (register:821, type:"EBOOL", name: "ST1001_Speed_Above_Hi")
    let SPEED_BELOW_LOW =           (register:822, type:"EBOOL", name: "ST1001_Speed_Below_Low")
    let SPEED_NOWIND =              (register:823, type:"EBOOL", name: "ST1001_speed_NoWind")
    let SPEED_CHANNEL_FAULT =       (register:824, type:"EBOOL", name: "ST1001_Speed_Channel_Fault")
    let DIRECTION_CHANNEL_FAULT =   (register:825, type:"EBOOL", name: "ST1001_Drctn_Channel_Fault")
    
}

//T_Wind_Bits_ON  - Range : 0 - 60 sec
//T_Wind_Bits_OFF - Range : 0 - 60 sec
//T_Wind_Abort    - Range : 0 - 60 sec


let WIND_TIMER_PLC_ADDRESSES = 6524

