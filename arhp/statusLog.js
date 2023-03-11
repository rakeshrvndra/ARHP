
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

    plc_client.readCoils(0,9,function(resp1){
        
        if (resp1 != undefined && resp1 != null){  
            // Show Stoppers - atho
            fault_ShowStoppers.push(resp1.coils[5] ? resp1.coils[5] : 0); // System Estop
            fault_ShowStoppers.push(resp1.coils[6] ? resp1.coils[6] : 0); // LT1001 Below LL
            fault_ShowStoppers.push(resp1.coils[7] ? resp1.coils[7] : 0); // LS1001 Below LL Lights OFF
            fault_ShowStoppers.push(resp1.coils[8] ? resp1.coils[8] : 0); // ST1001 Abort
        }
    });//end of first PLC modbus call  

    plc_client.readHoldingRegister(70,4,function(resp){
      if (resp != undefined && resp != null){
        
        //Estop
        fault_ESTOP.push(nthBit(resp.register[0],0) ? nthBit(resp.register[0],0) : 0); // Estop
        fault_ESTOP.push(nthBit(resp.register[0],1) ? nthBit(resp.register[0],1) : 0); // ACP101 Estop
        fault_ESTOP.push(nthBit(resp.register[0],2) ? nthBit(resp.register[0],2) : 0); // MCC101 Estop

        //WaterLevel 
        status_WaterLevel.push(nthBit(resp.register[0],6) ? nthBit(resp.register[0],6) : 0);   // LT1001 ChannelFault
        status_WaterLevel.push(nthBit(resp.register[0],7) ? nthBit(resp.register[0],7) : 0);   // LT1001 Above Hi 
        status_WaterLevel.push(nthBit(resp.register[0],8) ? nthBit(resp.register[0],8) : 0);   // LT1001 Below Low 
        status_WaterLevel.push(nthBit(resp.register[0],9) ? nthBit(resp.register[0],9) : 0);   // LT1001 Below LowLow
        status_WaterLevel.push(nthBit(resp.register[0],10) ? nthBit(resp.register[0],10) : 0); // LT1001 Below LowLowLow
        status_WaterLevel.push(nthBit(resp.register[0],11) ? nthBit(resp.register[0],11) : 0); // WaterMakeupOn
        status_WaterLevel.push(nthBit(resp.register[0],12) ? nthBit(resp.register[0],12) : 0); // WaterMakeup Timeout 
        status_WaterLevel.push(nthBit(resp.register[0],13) ? nthBit(resp.register[0],13) : 0); // LSLL1001 Lights ShutOff

        //WaterQuality
        status_WaterQuality.push(nthBit(resp.register[1],0) ? nthBit(resp.register[1],0) : 0);   // PH Channel Fault
        status_WaterQuality.push(nthBit(resp.register[1],1) ? nthBit(resp.register[1],1) : 0);   // PH Above Hi
        status_WaterQuality.push(nthBit(resp.register[1],2) ? nthBit(resp.register[1],2) : 0);   // PH Below Low
        status_WaterQuality.push(nthBit(resp.register[1],3) ? nthBit(resp.register[1],3) : 0);   // ORP Channel Fault
        status_WaterQuality.push(nthBit(resp.register[1],4) ? nthBit(resp.register[1],4) : 0);   // ORP Above Hi
        status_WaterQuality.push(nthBit(resp.register[1],5) ? nthBit(resp.register[1],5) : 0);   // ORP Below Low
        status_WaterQuality.push(nthBit(resp.register[1],6) ? nthBit(resp.register[1],6) : 0);   // TDS Channel Fault
        status_WaterQuality.push(nthBit(resp.register[1],7) ? nthBit(resp.register[1],7) : 0);   // TDS Above Hi
        status_WaterQuality.push(nthBit(resp.register[1],8) ? nthBit(resp.register[1],8) : 0);   // TDS Below Low
        status_WaterQuality.push(nthBit(resp.register[1],10) ? nthBit(resp.register[1],10) : 0); // Backwash Schedule Trigger
        status_WaterQuality.push(nthBit(resp.register[1],11) ? nthBit(resp.register[1],11) : 0); // Backwash Running
        status_WaterQuality.push(nthBit(resp.register[1],12) ? nthBit(resp.register[1],12) : 0); // Backwash due to PDSH

        //Fire
        status_wof.push(nthBit(resp.register[2],0) ? nthBit(resp.register[2],0) : 0);   // Fire System Enabled
        status_wof.push(nthBit(resp.register[2],1) ? nthBit(resp.register[2],1) : 0);   // Call For Ignition On
        status_wof.push(nthBit(resp.register[2],2) ? nthBit(resp.register[2],2) : 0);   // Fire Alarm
        status_wof.push(nthBit(resp.register[2],3) ? nthBit(resp.register[2],3) : 0);   // Fire Channel #1 Active
        status_wof.push(nthBit(resp.register[2],4) ? nthBit(resp.register[2],4) : 0);   // Fire Channel #2 Active

        //Wind
        status_windSensor.push(nthBit(resp.register[2],8) ? nthBit(resp.register[2],8) : 0);   // ST1001_Speed_Channel_Fault
        status_windSensor.push(nthBit(resp.register[2],9) ? nthBit(resp.register[2],9) : 0);   // ST1001_Drctn_Channel_Fault 
        status_windSensor.push(nthBit(resp.register[2],10) ? nthBit(resp.register[2],10) : 0); // ST1001_Abort Show
        status_windSensor.push(nthBit(resp.register[2],11) ? nthBit(resp.register[2],11) : 0); // ST1001_Above_Hi
        status_windSensor.push(nthBit(resp.register[2],12) ? nthBit(resp.register[2],12) : 0); // ST1001_Above_Medium
        status_windSensor.push(nthBit(resp.register[2],13) ? nthBit(resp.register[2],13) : 0); // ST1001_Above_Low
        status_windSensor.push(nthBit(resp.register[2],14) ? nthBit(resp.register[2],14) : 0); // ST1001_No_Wind

        //Pumps
        fault_PUMPS.push(nthBit(resp.register[3],0) ? nthBit(resp.register[3],0) : 0); // VFD 101 PumpFault (TWW1 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],1) ? nthBit(resp.register[3],1) : 0); // VFD 102 PumpFault (TWW2 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],2) ? nthBit(resp.register[3],2) : 0); // VFD 103 PumpFault (TWW3 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],3) ? nthBit(resp.register[3],3) : 0); // VFD 104 PumpFault (TWW4 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],4) ? nthBit(resp.register[3],4) : 0); // VFD 105 PumpFault (TWW5 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],5) ? nthBit(resp.register[3],5) : 0); // VFD 106 PumpFault (TWW6 Pump)
        fault_PUMPS.push(nthBit(resp.register[3],6) ? nthBit(resp.register[3],6) : 0); // VFD 107 PumpFault (RR Pump)  
        fault_PUMPS.push(nthBit(resp.register[3],7) ? nthBit(resp.register[3],7) : 0); // VFD 108 PumpFault (GWW Pump)  
        fault_PUMPS.push(nthBit(resp.register[3],8) ? nthBit(resp.register[3],8) : 0); // VFD 109 PumpFault (Filter Pump)  

        //Lights
        status_LIGHTS.push(nthBit(resp.register[3],12) ? nthBit(resp.register[3],12) : 0);    // LCP101 HOA 
        status_LIGHTS.push(nthBit(resp.register[3],13) ? nthBit(resp.register[3],13) : 0);    // LCP101 Sch ON   
        status_LIGHTS.push(nthBit(resp.register[3],14) ? nthBit(resp.register[3],14) : 0);    // LCP101 ON 

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
                            status_wof,
                            status_WaterLevel,
                            status_windSensor,
                            status_WaterQuality,
                            status_LIGHTS];

            totalStatus = bool2int(totalStatus);

            if (devStatus.length > 1) {
                logChanges(totalStatus); // detects change of total status
            }

            devStatus = totalStatus; // makes the total status equal to the current error state

            // creates the status array that is sent to the iPad (via errorLog) AND logged to file
            sysStatus = [{
                            "***************************ESTOP STATUS**************************" : "1",
                            "ESTOP OK": fault_ESTOP[0],
                            "ACP-101 ESTOP": fault_ESTOP[1],
                            "MCC-101 ESTOP": fault_ESTOP[2],
                            "ShowStopper :Estop": fault_ShowStoppers[0],
                            "ShowStopper :LT1001 WaterLevelLow": fault_ShowStoppers[1],
                            "ShowStopper :LS1001 Lights Shut OFF": fault_ShowStoppers[2],
                            "ShowStopper :Wind_Abort": fault_ShowStoppers[3],
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
                            "VFD 101 Pump Fault":fault_PUMPS[0],
                            "VFD 102 Pump Fault":fault_PUMPS[1],
                            "VFD 103 Pump Fault":fault_PUMPS[2],
                            "VFD 104 Pump Fault":fault_PUMPS[3],
                            "VFD 105 Pump Fault":fault_PUMPS[4],
                            "VFD 106 Pump Fault":fault_PUMPS[5],
                            "VFD 107 Pump Fault":fault_PUMPS[6],
                            "VFD 108 Pump Fault":fault_PUMPS[7],
                            "VFD 109 Pump Fault":fault_PUMPS[8],
                            "****************************WATERLEVEL STATUS********************" : "4",
                            "LT1001 ChannelFault":status_WaterLevel[0],
                            "LT1001 Above_Hi":status_WaterLevel[1],
                            "LT1001 Below_Low":status_WaterLevel[2],
                            "LT1001 Below_LowLow":status_WaterLevel[3],
                            "LT1001 Below_LowLowLow":status_WaterLevel[4],
                            "WaterMakeup On":status_WaterLevel[5],
                            "WaterMakeup Timeout":status_WaterLevel[6],
                            "Lights Shut OFF LS1001LL":status_WaterLevel[7],
                            "****************************WATER QUALITY STATUS*****************" : "5",
                            "PH ChannelFault": status_WaterQuality[0],
                            "PH Above Hi": status_WaterQuality[1],
                            "PH Below Low": status_WaterQuality[2],
                            "ORP ChannelFault": status_WaterQuality[3],
                            "ORP Above Hi": status_WaterQuality[4],
                            "ORP Below Low": status_WaterQuality[5],
                            "TDS ChannelFault": status_WaterQuality[6],
                            "TDS Above Hi": status_WaterQuality[7],
                            "TDS Below Low": status_WaterQuality[8],
                            "Backwash: Schedule Trigger": status_WaterQuality[9],
                            "Backwash Running": status_WaterQuality[10],
                            "Backwash: PDSH Trigger": status_WaterQuality[11],
                            "****************************LIGHTS STATUS*****************" : "6",
                            "BasinLights HA": status_LIGHTS[0],
                            "BasinLights Schedule On": status_LIGHTS[1],
                            "BasinLights On": status_LIGHTS[2],
                            "****************************WIND STATUS********************" : "7",
                            "ST1001 Speed_Channel_Fault": status_windSensor[0],
                            "ST1001 Direction_Channel_Fault": status_windSensor[1],
                            "ST1001 Abort_Show": status_windSensor[2],
                            "ST1001 Above_Hi": status_windSensor[3],
                            "ST1001 Above_Med": status_windSensor[4],
                            "ST1001 Above_Low": status_windSensor[5],
                            "ST1001 No_Wind": status_windSensor[6],
                            "****************************FIRE STATUS********************" : "8",
                            "Fire System Enabled": status_wof[0],
                            "Fire System Call For Ignition": status_wof[1],
                            "Fire System Alarm": status_wof[2],
                            "Fire Channel #1 Active": status_wof[3],
                            "Fire Channel #2 Active": status_wof[4],
                            "****************************DEVICE CONNECTION STATUS*************" : "9",
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
                            "next Show Num": nxtShow,
                            "canSendCmd": cmdFlag
                            }];
                            
            playMode_init = {"autoMan":autoMan};

            fs.writeFileSync(homeD+'/UserFiles/playMode.txt',JSON.stringify(playMode_init),'utf-8');
            fs.writeFileSync(homeD+'/UserFiles/playModeBkp.txt',JSON.stringify(playMode_init),'utf-8');
      }      
    });
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

            [   // Show Stopper - arhp
                {"yes":"Show Stopper: Estop","no":"Show Stopper Resolved: Estop"},
                {"yes":"Show Stopper: LT1001 Water Level Below LL","no":"Show Stopper Resolved: Water Level"},
                {"yes":"Show Stopper: LS1001 Water Level Below LL","no":"Show Stopper Resolved: Water Level"},
                {"yes":"Show Stopper: ST1001 Wind_Speed_Abort_Show","no":"Show Stopper Resolved: Wind_Speed_Abort_Show"},
            ],

            [   // estop - arhp 
                {"yes":"Estop Triggered","no":"Resolved: Estop"}, 
                {"yes":"ACP101 Estop Triggered","no":"Resolved: ACP101 Estop"}, 
                {"yes":"MCC101 Estop Triggered","no":"Resolved: MCC101 Estop"}, 
            ],

            [   // pumps - arhp
                
                {"yes":"P101 Pump Fault","no":"Resolved: P101 Pump Fault"},
                {"yes":"P102 Pump Fault","no":"Resolved: P102 Pump Fault"}, 
                {"yes":"P103 Pump Fault","no":"Resolved: P103 Pump Fault"}, 
                {"yes":"P104 Pump Fault","no":"Resolved: P104 Pump Fault"},  
                {"yes":"P105 Pump Fault","no":"Resolved: P105 Pump Fault"},  
                {"yes":"P106 Pump Fault","no":"Resolved: P106 Pump Fault"},  
                {"yes":"P107 Pump Fault","no":"Resolved: P107 Pump Fault"},  
                {"yes":"P108 Pump Fault","no":"Resolved: P108 Pump Fault"},  
                {"yes":"P109 Pump Fault","no":"Resolved: P109 Pump Fault"},  
                    
            ],

            [   // fire - arhp
                
                {"yes":"Fire Enabled","no":"Fire Disabled"},
                {"yes":"Call For Ignition ON","no":"Call For Ignition OFF"}, 
                {"yes":"Fire Alarm","no":"Resolved: Fire Alarm"}, 
                {"yes":"Fire Channel #1 Active","no":"Fire Channel #1 InActive"},  
                {"yes":"Fire Channel #2 Active","no":"Fire Channel #2 InActive"},  
                    
            ],

            [   // water level - arhp

                {"yes":"LT1001 Channel Fault","no":"Resolved: LT1001 Channel Fault Resolved"},
                {"yes":"LT1001 AboveHi","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Below_Low","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Below_LowLow","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"LT1001 Below_LowLowLow","no":"Resolved: LT1001 WaterLevel Resolved"},
                {"yes":"WaterMakeup On","no":"WaterMakeup Off"},
                {"yes":"WaterMakeup Timeout","no":"Resolved: WaterMakeup Timeout"},
                {"yes":"LS1001 Below_LowLow","no":"Resolved: LS1001 WaterLevel Resolved"},
                
            ],

            [   // anemometer - arhp
                {"yes":"ST1001 Speed_Channel_Fault","no":"ST1001 Speed_Channel_Fault Resolved"},
                {"yes":"ST1001 Direction_Channel_Fault","no":"ST1001 Direction_Channel_Fault Resolved"},
                {"yes":"ST1001 AbortShow","no":"ST1001 AbortShow Resolved"},
                {"yes":"ST1001 Wind Speed Above Hi","no":"ST1001 Wind Above Hi Resolved"},
                {"yes":"ST1001 Wind Speed Above Med","no":"ST1001 Wind Above Med Resolved"},
                {"yes":"ST1001 Wind Speed Above Low","no":"ST1001 Wind Above Low Resolved"},
                {"yes":"ST1001 Wind Speed NoWind","no":"ST1001 Wind Speed Not in NoWind"},
                
            ],

            [   //Water Quality Status - arhp
                
                {"yes":"PH Channel Fault","no":"Resolved: PH Channel Fault"},
                {"yes":"PH AboveHi","no":"Resolved: PH Above Hi Alarm "},
                {"yes":"PH Below_Low","no":"Resolved: PH Below Low Alarm "},
                {"yes":"ORP Channel Fault","no":"Resolved: ORP Channel Fault"},
                {"yes":"ORP AboveHi","no":"Resolved: ORP Above Hi Alarm "},
                {"yes":"ORP Below_Low","no":"Resolved: ORP Below Low Alarm "},
                {"yes":"TDS Channel Fault","no":"Resolved: TDS Channel Fault"},
                {"yes":"TDS AboveHi","no":"Resolved: TDS Above Hi Alarm "},
                {"yes":"TDS Below_Low","no":"Resolved: TDS Below Low Alarm "},
                {"yes":"Backwash Schedule Trigger ON","no":"Backwash Schedule Trigger OFF"},
                {"yes":"Backwash Running","no":"Backwash Not Running"},
                {"yes":"Backwash PDSH Trigger ON","no":"Backwash PDSH Trigger OFF"},
                
            ],

            [   //Lights Status - arhp
                {"yes":"Basin Lights in Hand Mode","no":"Basin Lights in Auto Mode"},
                {"yes":"Basin Lights Schedule ON","no":"Basin Lights Schedule OFF"},
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
