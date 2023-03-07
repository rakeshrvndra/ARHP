function statusLogWrapper(){

    //console.log("StatusLog script triggered");

    var totalStatus;
    var data = [];
    var status_wof = [];
    var status_windSensor = [];
    var status_pressTransmitter = [];
    var fault_PUMPS = [];
    var status_WaterLevel = [];
    var status_WaterQuality = [];
    var status_LIGHTS = [];
    var fault_ESTOP = [];
    var fault_INTRUSION = [];
    var fault_FOG = [];
    var status_AirPressure = [];
    var status_Ethernet = [];
    var fault_ShowStoppers = [];
    var status_GasPressure = [];

    
if (PLCConnected){

     plc_client.readHoldingRegister(1006,113,function(resp){
      if (resp != undefined && resp != null){
        
        //P101
        if(checkUpdatedValue(vfd1_faultCode[0],resp.register[0],101)){
           vfd1_faultCode[0] = resp.register[0];
        }

        //P102
        if(checkUpdatedValue(vfd1_faultCode[1],resp.register[14],102)){
           vfd1_faultCode[1] = resp.register[14];
        }

        //P103
        if(checkUpdatedValue(vfd1_faultCode[2],resp.register[28],103)){
           vfd1_faultCode[2] = resp.register[28];
        }

        //P104
        if(checkUpdatedValue(vfd1_faultCode[3],resp.register[42],104)){
           vfd1_faultCode[3] = resp.register[42];
        }

        //P105
        if(checkUpdatedValue(vfd1_faultCode[4],resp.register[56],105)){
           vfd1_faultCode[4] = resp.register[56];
        }

        //P106
        if(checkUpdatedValue(vfd1_faultCode[5],resp.register[70],106)){
           vfd1_faultCode[5] = resp.register[70];
        }

        //P107
        if(checkUpdatedValue(vfd1_faultCode[6],resp.register[84],107)){
           vfd1_faultCode[6] = resp.register[84];
        }

        //P108
        if(checkUpdatedValue(vfd1_faultCode[7],resp.register[98],108)){
           vfd1_faultCode[7] = resp.register[98];
        }

        //P109
        if(checkUpdatedValue(vfd1_faultCode[8],resp.register[112],109)){
           vfd1_faultCode[8] = resp.register[112];
        }

      }      
    });
    
    plc_client.readCoils(0,145,function(resp){
        
        if (resp != undefined && resp != null){

            // Show Stoppers - farm
            fault_ShowStoppers.push(resp.coils[5] ? resp.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp.coils[6] ? resp.coils[6] : 0); // WaterLevel ShowStopper
            fault_ShowStoppers.push(resp.coils[7] ? resp.coils[7] : 0); // Wind ShowStopper
            fault_ShowStoppers.push(resp.coils[8] ? resp.coils[8] : 0); // Client_Emergency ESTOP

            var estopIndex = 20; //farm
            fault_ESTOP.push(resp.coils[estopIndex] ? resp.coils[estopIndex] : 0);       // AudioMute
            fault_ESTOP.push(resp.coils[estopIndex+42] ? resp.coils[estopIndex+42] : 0); // PL_Surge Protection
            fault_ESTOP.push(resp.coils[estopIndex+43] ? resp.coils[estopIndex+43] : 0); // Server Reboot
            fault_ESTOP.push(resp.coils[estopIndex+44] ? resp.coils[estopIndex+44] : 0); // Show_Playing
            fault_ESTOP.push(resp.coils[estopIndex+56] ? resp.coils[estopIndex+56] : 0); // Out_BackgroundAudioMuteDMX
            fault_ESTOP.push(resp.coils[estopIndex+57] ? resp.coils[estopIndex+57] : 0); // Out_BackgroundAudioMuteMCRX
            fault_ESTOP.push(resp.coils[estopIndex+64] ? resp.coils[estopIndex+64] : 0); // Out_ServerReset_YY2002
            fault_ESTOP.push(resp.coils[estopIndex+65] ? resp.coils[estopIndex+65] : 0); // Out_OzoneGenerator

            // Wind Speed - farm
            var windIndex = 46; //farm
            status_windSensor.push(resp.coils[windIndex] ? resp.coils[windIndex] : 0);     // ST1001_Abort Show
            status_windSensor.push(resp.coils[windIndex+1] ? resp.coils[windIndex+1] : 0); // ST1001_Above_Hi
            //windHi = status_windSensor[1];
            
            status_windSensor.push(resp.coils[windIndex+2] ? resp.coils[windIndex+2] : 0); // ST1001_Below_Low
            //windLo = status_windSensor[2];

            status_windSensor.push(resp.coils[windIndex+3] ? resp.coils[windIndex+3] : 0); // ST1001_Speed_Channel_Fault
            status_windSensor.push(resp.coils[windIndex+4] ? resp.coils[windIndex+4] : 0); // ST1001_No_Wind
            //windNo = status_windSensor[4];
            
            status_windSensor.push(resp.coils[windIndex+5] ? resp.coils[windIndex+5] : 0); // ST1001_Drctn_Channel_Fault

            // Pressure Transmitters  
            var lightIndex = 78; //farm 
            status_LIGHTS.push(resp.coils[lightIndex] ? resp.coils[lightIndex] : 0);     // MicroshooterLights HA 
            status_LIGHTS.push(resp.coils[lightIndex+1] ? resp.coils[lightIndex+1] : 0); // MicroshooterLights On
            status_LIGHTS.push(resp.coils[lightIndex+2] ? resp.coils[lightIndex+2] : 0); // OarsmanLights HA
            status_LIGHTS.push(resp.coils[lightIndex+3] ? resp.coils[lightIndex+3] : 0); // OarsmanLights On
            status_LIGHTS.push(resp.coils[lightIndex+4] ? resp.coils[lightIndex+4] : 0); // BasinLights HA
            status_LIGHTS.push(resp.coils[lightIndex+5] ? resp.coils[lightIndex+5] : 0); // BasinLights On

            // Water Level Sensor
            var WL_Index = 39; // farm
            status_WaterLevel.push(resp.coils[WL_Index] ? resp.coils[WL_Index] : 0);        // LT1001 Above HiHi
            status_WaterLevel.push(resp.coils[WL_Index+1] ? resp.coils[WL_Index+1] : 0);    // LT1001 Above Hi
            status_WaterLevel.push(resp.coils[WL_Index+2] ? resp.coils[WL_Index+2] : 0);    // LT1001 Below Low
            status_WaterLevel.push(resp.coils[WL_Index+3] ? resp.coils[WL_Index+3] : 0);    // LT1001 Below LowLow
            status_WaterLevel.push(resp.coils[WL_Index+4] ? resp.coils[WL_Index+4] : 0);    // LT1001 ChannelFault
            status_WaterLevel.push(resp.coils[WL_Index+5] ? resp.coils[WL_Index+5] : 0);    // WaterMakeupOn 
            status_WaterLevel.push(resp.coils[WL_Index+6] ? resp.coils[WL_Index+6] : 0);    // WaterMakeup Timeout 

            // Water Quality
            var WQ_Index = 52;//farm
            status_WaterQuality.push(resp.coils[WQ_Index] ? resp.coils[WQ_Index] : 0);       //WQ CommonAlarm
            status_WaterQuality.push(resp.coils[WQ_Index+1] ? resp.coils[WQ_Index+1] : 0);   //WQ PowerFault
            status_WaterQuality.push(resp.coils[WQ_Index+2] ? resp.coils[WQ_Index+2] : 0);   //OarsmanEnable 01
            status_WaterQuality.push(resp.coils[WQ_Index+3] ? resp.coils[WQ_Index+3] : 0);   //OarsmanEnable 02
            status_WaterQuality.push(resp.coils[WQ_Index+4] ? resp.coils[WQ_Index+4] : 0);   //OarsmanEnable 03
            status_WaterQuality.push(resp.coils[WQ_Index+5] ? resp.coils[WQ_Index+5] : 0);   //OarsmanEnable 04
            status_WaterQuality.push(resp.coils[WQ_Index+6] ? resp.coils[WQ_Index+6] : 0);   //OarsmanEnable 05
            status_WaterQuality.push(resp.coils[WQ_Index+7] ? resp.coils[WQ_Index+7] : 0);   //OarsmanEnable 06
            status_WaterQuality.push(resp.coils[WQ_Index+8] ? resp.coils[WQ_Index+8] : 0);   //OarsmanEnable 07
            status_WaterQuality.push(resp.coils[WQ_Index+9] ? resp.coils[WQ_Index+9] : 0);   //OarsmanEnable 08

            var strainerIndex = 25; //farm
            status_WaterQuality.push(resp.coils[strainerIndex] ? resp.coils[strainerIndex] : 0);     //PSL-1001 Clean Strainer
            status_WaterQuality.push(resp.coils[strainerIndex+1] ? resp.coils[strainerIndex+1] : 0); //PSL-1002 Clean Strainer
            status_WaterQuality.push(resp.coils[strainerIndex+2] ? resp.coils[strainerIndex+2] : 0); //PSL-1101 Clean Strainer
            
            var bwashIndex = 131; //farm
            status_WaterQuality.push(resp.coils[bwashIndex] ? resp.coils[bwashIndex] : 0);     // Backwash Pressure Differential High 
            status_WaterQuality.push(resp.coils[bwashIndex+1] ? resp.coils[bwashIndex+1] : 0); // BackWash Running
            status_WaterQuality.push(resp.coils[bwashIndex+2] ? resp.coils[bwashIndex+2] : 0); // In_Backwash
            status_WaterQuality.push(resp.coils[bwashIndex+3] ? resp.coils[bwashIndex+3] : 0); // In_Filtration

            // Pumps
            var pumpIndex = 28; //farm
            fault_PUMPS.push(resp.coils[pumpIndex] ? resp.coils[pumpIndex] : 0);         // VFD 101 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+1] ? resp.coils[pumpIndex+1] : 0);     // VFD 102 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+2] ? resp.coils[pumpIndex+2] : 0);     // VFD 103 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+3] ? resp.coils[pumpIndex+3] : 0);     // VFD 104 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+4] ? resp.coils[pumpIndex+4] : 0);     // VFD 105 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+5] ? resp.coils[pumpIndex+5] : 0);     // VFD 106 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+6] ? resp.coils[pumpIndex+6] : 0);     // VFD 107 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+7] ? resp.coils[pumpIndex+7] : 0);     // VFD 108 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+8] ? resp.coils[pumpIndex+8] : 0);     // VFD 109 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+9] ? resp.coils[pumpIndex+9] : 0);     // VFD 110 PressureFault
            fault_PUMPS.push(resp.coils[pumpIndex+10] ? resp.coils[pumpIndex+10] : 0);   // VFD 111 PressureFault

            var faultIndex = 65; //farm
            fault_PUMPS.push(resp.coils[faultIndex] ? resp.coils[faultIndex] : 0);       // VFD 101 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+1] ? resp.coils[faultIndex+1] : 0);   // VFD 102 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+2] ? resp.coils[faultIndex+2] : 0);   // VFD 103 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+3] ? resp.coils[faultIndex+3] : 0);   // VFD 104 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+4] ? resp.coils[faultIndex+4] : 0);   // VFD 105 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+5] ? resp.coils[faultIndex+5] : 0);   // VFD 106 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+6] ? resp.coils[faultIndex+6] : 0);   // VFD 107 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+7] ? resp.coils[faultIndex+7] : 0);   // VFD 108 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+8] ? resp.coils[faultIndex+8] : 0);   // VFD 109 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+9] ? resp.coils[faultIndex+9] : 0);   // VFD 110 PumpFault
            fault_PUMPS.push(resp.coils[faultIndex+10] ? resp.coils[faultIndex+10] : 0); // VFD 111 PumpFault

            var networkIndex = 86; //farm
            fault_PUMPS.push(resp.coils[networkIndex] ? resp.coils[networkIndex] : 0);       // VFD 101 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+1] ? resp.coils[networkIndex+1] : 0);   // VFD 102 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+2] ? resp.coils[networkIndex+2] : 0);   // VFD 103 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+3] ? resp.coils[networkIndex+3] : 0);   // VFD 104 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+4] ? resp.coils[networkIndex+4] : 0);   // VFD 105 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+5] ? resp.coils[networkIndex+5] : 0);   // VFD 106 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+6] ? resp.coils[networkIndex+6] : 0);   // VFD 107 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+7] ? resp.coils[networkIndex+7] : 0);   // VFD 108 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+8] ? resp.coils[networkIndex+8] : 0);   // VFD 109 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+9] ? resp.coils[networkIndex+9] : 0);   // VFD 110 NetworkFault
            fault_PUMPS.push(resp.coils[networkIndex+10] ? resp.coils[networkIndex+10] : 0); // VFD 111 NetworkFault

            showStopper = 0;
            for (var i=0; i <= (fault_ShowStoppers.length-1); i++){
                showStopper = showStopper + fault_ShowStoppers[i];
                // if(serviceRequired === 1){
                //    showStopper = 1; 
                //    watchDog.eventLog("ShowStopper:: Service Required 1");
                // }
            }   

            totalStatus = [ 
                            fault_ShowStoppers,
                            fault_ESTOP,
                            fault_PUMPS,
                            status_WaterLevel,
                            status_windSensor,
                            status_WaterQuality,
                            status_LIGHTS];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
             //   logChanges(totalStatus); // detects change of total status
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "***************************ESTOP STATUS**************************" : "1",
                            "SPM_AudioMute": fault_ESTOP[0],
                            "PL_Surge Protection": fault_ESTOP[1],
                            "Server Reboot Status": fault_ESTOP[2],
                            "Show_Playing": fault_ESTOP[3],
                            "Out_BackgroundAudioMuteDMX": fault_ESTOP[4],
                            "Out_BackgroundAudioMuteMCRX": fault_ESTOP[5],
                            "Out_ServerReset_YY2002": fault_ESTOP[6],
                            "Out_OzoneGenerator": fault_ESTOP[7],
                            "ShowStopper :Estop": fault_ShowStoppers[0],
                            "ShowStopper :LT1001 WaterLevelLow": fault_ShowStoppers[1],
                            "ShowStopper :Wind_Abort": fault_ShowStoppers[2],
                            "ShowStopper :Client_EmergencyEstop": fault_ShowStoppers[3],
                            "***************************SHOW STATUS***************************" : "2",
                            "Show PlayMode": autoMan,
                            "Show PlayStatus":playing,
                            "CurrentShow Number":show,
                            "deflate":deflate,
                            "NextShowTime": nxtTime,
                            "NextShowNumber": nxtShow,
                            "timeLastCmnd": timeLastCmnd,
                            "SPM_RAT_Mode":Boolean(spmRATMode),
                            "JumpToStepAuto": jumpToStep_auto,
                            "JumpToStepManual": jumpToStep_manual,
                            "DayMode Status":dayModeStatus,
                            "***************************PUMPS STATUS**************************" : "3",
                            "VFD 101 Fault Code":vfd1_faultCode[0],
                            "VFD 102 Fault Code":vfd1_faultCode[1],
                            "VFD 103 Fault Code":vfd1_faultCode[2],
                            "VFD 104 Fault Code":vfd1_faultCode[3],
                            "VFD 105 Fault Code":vfd1_faultCode[4],
                            "VFD 106 Fault Code":vfd1_faultCode[5],
                            "VFD 107 Fault Code":vfd1_faultCode[6],
                            "VFD 108 Fault Code":vfd1_faultCode[7],
                            "VFD 109 Fault Code":vfd1_faultCode[8],
                            "VFD 101 Pressure Fault":fault_PUMPS[0],
                            "VFD 102 Pressure Fault":fault_PUMPS[1],
                            "VFD 103 Pressure Fault":fault_PUMPS[2],
                            "VFD 104 Pressure Fault":fault_PUMPS[3],
                            "VFD 105 Pressure Fault":fault_PUMPS[4],
                            "VFD 106 Pressure Fault":fault_PUMPS[5],
                            "VFD 107 Pressure Fault":fault_PUMPS[6],
                            "VFD 108 Pressure Fault":fault_PUMPS[7],
                            "VFD 109 Pressure Fault":fault_PUMPS[8],
                            "VFD 101 Pump Fault":fault_PUMPS[11],
                            "VFD 102 Pump Fault":fault_PUMPS[12],
                            "VFD 103 Pump Fault":fault_PUMPS[13],
                            "VFD 104 Pump Fault":fault_PUMPS[14],
                            "VFD 105 Pump Fault":fault_PUMPS[15],
                            "VFD 106 Pump Fault":fault_PUMPS[16],
                            "VFD 107 Pump Fault":fault_PUMPS[17],
                            "VFD 108 Pump Fault":fault_PUMPS[18],
                            "VFD 109 Pump Fault":fault_PUMPS[19],
                            "VFD 101 Network Fault":fault_PUMPS[22],
                            "VFD 102 Network Fault":fault_PUMPS[23],
                            "VFD 103 Network Fault":fault_PUMPS[24],
                            "VFD 104 Network Fault":fault_PUMPS[25],
                            "VFD 105 Network Fault":fault_PUMPS[26],
                            "VFD 106 Network Fault":fault_PUMPS[27],
                            "VFD 107 Network Fault":fault_PUMPS[28],
                            "VFD 108 Network Fault":fault_PUMPS[29],
                            "VFD 109 Network Fault":fault_PUMPS[30],
                            "****************************WATERLEVEL STATUS********************" : "4",
                            "LT1001 Above_HiHi":status_WaterLevel[0],
                            "LT1001 Above_Hi":status_WaterLevel[1],
                            "LT1001 Below_Low":status_WaterLevel[2],
                            "LT1001 Below_LowLow":status_WaterLevel[3],
                            "LT1001 ChannelFault":status_WaterLevel[4],
                            "WaterMakeup On":status_WaterLevel[5],
                            "WaterMakeup Timeout":status_WaterLevel[6],
                            "****************************WATER QUALITY STATUS*****************" : "5",
                            "WQ CommonAlarm": status_WaterQuality[0],
                            "WQ PowerFault": status_WaterQuality[1],
                            "OarsmanEnable 01": status_WaterQuality[2],
                            "OarsmanEnable 02": status_WaterQuality[3],
                            "OarsmanEnable 03": status_WaterQuality[4],
                            "OarsmanEnable 04": status_WaterQuality[5],
                            "OarsmanEnable 05": status_WaterQuality[6],
                            "OarsmanEnable 06": status_WaterQuality[7],
                            "OarsmanEnable 07": status_WaterQuality[8],
                            "OarsmanEnable 08": status_WaterQuality[9],
                            "PSL-1001 Clean Strainer": status_WaterQuality[10],
                            "PSL-1002 Clean Strainer": status_WaterQuality[11],
                            "PSL-1101 Clean Strainer": status_WaterQuality[12],
                            "Backwash Pressure Differential High": status_WaterQuality[13],
                            "BackWash Running": status_WaterQuality[14],
                            "In_Backwash": status_WaterQuality[15],
                            "In_Filtration": status_WaterQuality[16],
                            "****************************LIGHTS STATUS*****************" : "6",
                            "MicroshooterLights HA": status_LIGHTS[0],
                            "MicroshooterLights On": status_LIGHTS[1],
                            "OarsmanLights HA": status_LIGHTS[2],
                            "OarsmanLights On": status_LIGHTS[3],
                            "BasinLights HA": status_LIGHTS[4],
                            "BasinLights On": status_LIGHTS[5],
                            "****************************WIND STATUS********************" : "7",
                            "ST1001 Abort_Show": status_windSensor[0],
                            "ST1001 Above_Hi": status_windSensor[1],
                            "ST1001 Below_Low": status_windSensor[2],
                            "ST1001 Speed_Channel_Fault": status_windSensor[3],
                            "ST1001 No_Wind": status_windSensor[4],
                            "ST1001 Direction_Channel_Fault": status_windSensor[5],
                            "****************************DEVICE CONNECTION STATUS*************" : "8",
                            "SPM_Heartbeat": SPM_Heartbeat,
                            "SPM_Modbus_Connection": SPMConnected,
                            "PLC_Heartbeat": PLC_Heartbeat,
                            "PLC_Modbus _Connection": PLCConnected,
                            }];

            playStatus = [{
                            "Play Mode": autoMan,
                            "play status":playing,
                            "Current Show":show,
                            "Current Show Name": shows[show].name,
                            "Current Show Duration":shows[show].duration,
                            "Show Type":showType,
                            "deflate":deflate,
                            "show time remaining": showTime_remaining,
                            "Service Required": serviceRequired,
                            "next Show Time": nxtTime,
                            "enableDeadman": deadMan,
                            "next Show Num": nxtShow,
                            "canSendCmd": cmdFlag
                            }];
                            
            playMode_init = {"autoMan":autoMan};

            fs.writeFileSync(homeD+'/UserFiles/playMode.txt',JSON.stringify(playMode_init),'utf-8');
            fs.writeFileSync(homeD+'/UserFiles/playModeBkp.txt',JSON.stringify(playMode_init),'utf-8');
        
        
        }
    });//end of first PLC modbus call
}
var date = new Date();
// if((date.getDate() >= 10) && (date.getMonth() >= 3)){
//     serviceRequired = 1;
// }

if (SPMConnected){

     // plc_client.readCoils(3,1,function(resp){
     //    var m3Bit = resp.coils[0];
     //    watchDog.eventLog('Read PLC M3 value: '+m3Bit);
     // });

     // spm_client.readHoldingRegister(3052,5,function(resp){

     // //     // Fire Spire data
     // //     watchDog.eventLog("Fire 401: Value: "  +intByte_HiLo(resp.register[0])[0]);    // Fire Spire - 401
     // //     watchDog.eventLog("Fire 402: Value: "  +intByte_HiLo(resp.register[0])[1]);    // Fire Spire - 402
     // //     watchDog.eventLog("Fire 403: Value: "  +intByte_HiLo(resp.register[1])[0]);    // Fire Spire - 403
     // //     watchDog.eventLog("Fire 404: Value: "  +intByte_HiLo(resp.register[1])[1]);    // Fire Spire - 404
     // //     watchDog.eventLog("Fire 405: Value: "  +intByte_HiLo(resp.register[2])[0]);    // Fire Spire - 405
     // //     watchDog.eventLog("Fire 406: Value: "  +intByte_HiLo(resp.register[2])[1]);    // Fire Spire - 406
     //     // watchDog.eventLog("P:107 Value: "  +intByte_HiLo(resp.register[0])[0]);        // P-107
     //     // watchDog.eventLog("P:207 Value: "  +intByte_HiLo(resp.register[0])[1]);        // P-207
     //     // watchDog.eventLog("P:307 Value: "  +intByte_HiLo(resp.register[1])[0]);        // P-307

     // });

    if(autoMan===1){
       plc_client.writeSingleCoil(4,1,function(resp){});
    }
    else{
      plc_client.writeSingleCoil(4,0,function(resp){});
    }

}

    // compares current state to previous state to log differences
    function logChanges(currentState){
        // {"yes":"n/a","no":"n/a"} object template for detection but no logging... "n/a" disables log
        // {"yes":"positive edge message","no":"negative edge message"} object template for detection and logging
        // pattern of statements must match devStatus and totalStatus format
        var statements=[

            [   // Show Stopper - farm
                {"yes":"Show Stopper: Estop","no":"Show Stopper Resolved: Estop"},
                {"yes":"Show Stopper: Water Level Below L","no":"Show Stopper Resolved: Water Level Below L"},
                {"yes":"Show Stopper: Wind_Speed_Abort_Show","no":"Show Stopper Resolved: Wind_Speed_Abort_Show"},
                {"yes":"Show Stopper: Client EmergencyEstop","no":"Show Stopper Resolved: Client EmergencyEstop"},
            ],

            [   // estop - farm 
                {"yes":"SPM AudioMute","no":"SPM AudioUnmute"}, 
                {"yes":"PL_Surge Protection","no":"PL_Surge Protection Resolved"}, 
                {"yes":"Server Reboot Initiated","no":"Server Reboot Sequence End"}, 
                {"yes":"Show_Playing","no":"Show_Playing Ended"},
                {"yes":"Out_BackgroundAudioMuteDMX Muted","no":"Out_BackgroundAudioMuteDMX Unmuted"},
                {"yes":"Out_BackgroundAudioMuteMCRX Muted","no":"Out_BackgroundAudioMuteMCRX Unmuted"},
                {"yes":"Out_ServerReset_YY2002","no":"Out_ServerReset_YY2002 Resolved"},
                {"yes":"Out_OzoneGenerator On","no":"Out_OzoneGenerator Off"},
            ],

            [   // pumps - farm
                {"yes":"P101 Pressure Fault","no":"Resolved: P101 Pressure Fault"},
                {"yes":"P102 Pressure Fault","no":"Resolved: P102 Pressure Fault"}, 
                {"yes":"P103 Pressure Fault","no":"Resolved: P103 Pressure Fault"}, 
                {"yes":"P104 Pressure Fault","no":"Resolved: P104 Pressure Fault"},  
                {"yes":"P105 Pressure Fault","no":"Resolved: P105 Pressure Fault"},  
                {"yes":"P106 Pressure Fault","no":"Resolved: P106 Pressure Fault"},  
                {"yes":"P107 Pressure Fault","no":"Resolved: P107 Pressure Fault"},  
                {"yes":"P108 Pressure Fault","no":"Resolved: P108 Pressure Fault"},  
                {"yes":"P109 Pressure Fault","no":"Resolved: P109 Pressure Fault"},  
                {"yes":"P110 Pressure Fault","no":"Resolved: P110 Pressure Fault"}, 
                {"yes":"P111 Pressure Fault","no":"Resolved: P111 Pressure Fault"},
                {"yes":"P101 Pump Fault","no":"Resolved: P101 Pump Fault"},
                {"yes":"P102 Pump Fault","no":"Resolved: P102 Pump Fault"}, 
                {"yes":"P103 Pump Fault","no":"Resolved: P103 Pump Fault"}, 
                {"yes":"P104 Pump Fault","no":"Resolved: P104 Pump Fault"},  
                {"yes":"P105 Pump Fault","no":"Resolved: P105 Pump Fault"},  
                {"yes":"P106 Pump Fault","no":"Resolved: P106 Pump Fault"},  
                {"yes":"P107 Pump Fault","no":"Resolved: P107 Pump Fault"},  
                {"yes":"P108 Pump Fault","no":"Resolved: P108 Pump Fault"},  
                {"yes":"P109 Pump Fault","no":"Resolved: P109 Pump Fault"},  
                {"yes":"P110 Pump Fault","no":"Resolved: P110 Pump Fault"}, 
                {"yes":"P111 Pump Fault","no":"Resolved: P111 Pump Fault"},
                {"yes":"P101 Network Fault","no":"Resolved: P101 Network Fault"},
                {"yes":"P102 Network Fault","no":"Resolved: P102 Network Fault"}, 
                {"yes":"P103 Network Fault","no":"Resolved: P103 Network Fault"}, 
                {"yes":"P104 Network Fault","no":"Resolved: P104 Network Fault"},  
                {"yes":"P105 Network Fault","no":"Resolved: P105 Network Fault"},  
                {"yes":"P106 Network Fault","no":"Resolved: P106 Network Fault"},  
                {"yes":"P107 Network Fault","no":"Resolved: P107 Network Fault"},  
                {"yes":"P108 Network Fault","no":"Resolved: P108 Network Fault"},  
                {"yes":"P109 Network Fault","no":"Resolved: P109 Network Fault"},  
                {"yes":"P110 Network Fault","no":"Resolved: P110 Network Fault"}, 
                {"yes":"P111 Network Fault","no":"Resolved: P111 Network Fault"},
                    
            ],

            [   // water level - farm
                
                {"yes":"LT1001 AboveHiHi","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 AboveHi","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Below_Low","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Below_LowLow","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Channel Fault","no":"Resolved: LT1001 Channel Fault Resolved"},
                {"yes":"WaterMakeup On","no":"WaterMakeup Off"},
                {"yes":"WaterMakeup Timeout","no":"Resolved: WaterMakeup Timeout"},
                
            ],

            [   // anemometer - farm
                {"yes":"ST1001 AbortShow","no":"ST1001 AbortShow Resolved"},
                {"yes":"ST1001 Wind Speed Above Hi","no":"ST1001 Wind Above Hi Resolved"},
                {"yes":"ST1001 Wind Speed Below Low","no":"ST1001 Wind Below Low Resolved"},
                {"yes":"ST1001 Speed_Channel_Fault","no":"ST1001 Speed_Channel_Fault Resolved"},
                {"yes":"ST1001 Wind Speed NoWind","no":"ST1001 Wind Speed Notin NoWind"},
                {"yes":"ST1001 Direction_Channel_Fault","no":"ST1001 Direction_Channel_Fault Resolved"},
            ],

            [   //Water Quality Status - farm
                {"yes":"WQ CommonAlarm Triggered","no":"WQ CommonAlarm Resolved"},
                {"yes":"WQ PowerFault Triggered","no":"Resolved : WQ PowerFault"},
                {"yes":"Oarsman01 WaterReady","no":"Oarsman01 WaterNotReady"},
                {"yes":"Oarsman02 WaterReady","no":"Oarsman02 WaterNotReady"},
                {"yes":"Oarsman03 WaterReady","no":"Oarsman03 WaterNotReady"},
                {"yes":"Oarsman04 WaterReady","no":"Oarsman04 WaterNotReady"},
                {"yes":"Oarsman05 WaterReady","no":"Oarsman05 WaterNotReady"},
                {"yes":"Oarsman06 WaterReady","no":"Oarsman06 WaterNotReady"},
                {"yes":"Oarsman07 WaterReady","no":"Oarsman07 WaterNotReady"},
                {"yes":"Oarsman08 WaterReady","no":"Oarsman08 WaterNotReady"},
                {"yes":"PSL-1001 Clean Strainer Warning","no":"PSL-1001 Clean Strainer Warning Resolved"},
                {"yes":"PSL-1002 Clean Strainer Warning","no":"PSL-1002 Clean Strainer Warning Resolved"},
                {"yes":"PSL-1101 Clean Strainer Warning","no":"PSL-1101 Clean Strainer Warning Resolved"},
                {"yes":"PDSH Triggered Backwash","no":"PDSH Triggered Backwash Ended"},
                {"yes":"Backwash Running","no":"Backwash Ended"}, 
                {"yes":"In_Backwash On","no":"In_Backwash Off"}, 
                {"yes":"In_Filtration On","no":"In_Filtration Off"}, 
            ],

            [   //Lights Status - farm
                {"yes":"MicroShooter Lights in Hand Mode","no":"MicroShooter Lights in Auto Mode"},
                {"yes":"MicroShooter Lights On","no":"MicroShooter Lights Off"},
                {"yes":"Oarsman Lights in Hand Mode","no":"Oarsman Lights in Auto Mode"},
                {"yes":"Oarsman Lights On","no":"Oarsman Lights Off"},
                {"yes":"Basin Lights in Hand Mode","no":"Basin Lights in Auto Mode"},
                {"yes":"Basin Lights On","no":"Basin Lights Off"},
            ]
        ];
        
        if (devStatus.length > 0) {
            for(var each in currentState){
                // find all indeces with values different from previous examination
                var suspects = kompare(currentState[each],devStatus[each]);
                for(var each2 in suspects){
                    var text = (currentState[each][suspects[each2]]) ? statements[each][suspects[each2]].yes:statements[each][suspects[each2]].no;
                    var description = "";
                    var message = "";
                    var category = "";
                    if(text !== "n/a"){
                        //watchDog.eventLog('each: ' +each +' and each2: ' +each2+' and suspcts: ' +suspects);
                        watchDog.eventLog(text);
                        watchLog.eventLog(text);
                    }
                }
            }
        }

    }

    // returns the value of the bth bit of n
    function nthBit(n,b){
        var here = 1 << b;
        if (here & n){
            return 1;
        }
        return 0;
    }

    function intByte_HiLo(query){
        var loByte = 0;
        for(var i = 0; i < 8; i++){
            loByte = loByte + (nthBit(query,i)* Math.pow(2, i));
        }
        var hiByte = 0;
        for(var i = 8; i < 16; i++){
            hiByte = hiByte + (nthBit(query,i)* Math.pow(2, i-8));
        }
        var byte_arr = [];
        byte_arr[0] = loByte;
        byte_arr[1] = hiByte;
        return byte_arr;
    }

    //check and execute only once
    function checkUpdatedValue(oldValue,newValue,pumpNumber){
        // watchDog.eventLog("oldValue  :::   "+oldValue);
        // watchDog.eventLog("newValue  :::   "+newValue);
        if(newValue==oldValue){
            return 0;
        } else {
            vfdCode.vfdFaultCodeAnalyzer(pumpNumber,newValue);
            return 1;
        }
    }

    //check and execute only once
    function printForUpdatedValue(oldValue,newValue){
        // watchDog.eventLog("oldValue  :::   "+oldValue);
        // watchDog.eventLog("newValue  :::   "+newValue);
        if(newValue==oldValue){
            return 0;
        } else {
            return 1;
        }
    }

    function checkUpdatedMirrPosValue(oldValue,newValue){
        // watchDog.eventLog("oldValue  :::   "+oldValue);
        // watchDog.eventLog("newValue  :::   "+newValue);
        if(newValue==oldValue){
            return 0;
        } else {
            return 1;
        }
    }

    // converts up to 11-bit binary (including 0 bit) to decimal
    function oddByte(fruit){
        var min=0;
        for (k=0;k<11;k++){
            if(nthBit(fruit,k)){min+=Math.pow(2,k);}
        }
        return min;
    }

    // general function that will help DEEP compare arrays
    function kompare (array1,array2) {
        var collisions = [];

        for (var i = 0, l=array1.length; i < l; i++) {
            // Check if we have nested arrays
            if (array1[i] instanceof Array && array2[i] instanceof Array) {
                // recurse into the nested arrays
                if (!kompare(array1[i],array2[i])){
                    return [false];
                }
            }
            else if (array1[i] !== array2[i]) {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                collisions.push(i);
            }
        }

        return collisions;
    }

    // convert boolean to int
    function bool2int(array){
        for (var each in array) {
            // Check if we have nested arrays
            if (array[each] instanceof Array) {
                // recurse into the nested arrays
                array[each] = bool2int(array[each]);
            }
            else {
                // Warning - two different object instances will never be equal: {x:20} != {x:20}
                array[each] = (array[each]) ? 1 : 0;
            }
        }
        return array;
    }
}

module.exports=statusLogWrapper;
