function fireLogger(){
	if (((show==3) || (show==6) || (show==9)) && (playing==1)){
       noe_client.readHoldingRegister(2203,7,function(resp){
          if (resp != undefined && resp != null){
            var spmData = resp.register[0]; 
                if (spmData == spmPLCData){

                }  else {
                   spmPLCData = spmData;
                   fireLog.fireEventLog('SPM to PLC ShowData:: ' +spmData); 
                   fireLog.fireEventLog('MW2203 SPM Data Current Val:: ' +resp.register[0]);
                   // fireLog.fireEventLog('MW2204 Fire Spire 1 Current Val:: ' +resp.register[1]);
                   // fireLog.fireEventLog('MW2205 Fire Spire 2 Current Val:: ' +resp.register[2]);
                   // fireLog.fireEventLog('MW2206 Fire Spire 3 Current Val:: ' +resp.register[3]);
                   // fireLog.fireEventLog('MW2207 Fire Spire 4 Current Val:: ' +resp.register[4]);
                   // fireLog.fireEventLog('MW2208 Fire Spire 5 Current Val:: ' +resp.register[5]);
                   // fireLog.fireEventLog('MW2209 Fire Spire 6 Current Val:: ' +resp.register[6]);
                   readPressureData(5500,1);  
                   readPressureData(5560,2);  
                   readPressureData(5620,3);  
                   readPressureData(5680,4);  
                   readPressureData(5740,5);  
                   readPressureData(5800,6); 
                   readN2FlowData(6075); 
                   readAlarmStatus(6055);  
                   readValveStatus(6040);    
                }
          }
       }); 
    } else {
        //watchDog.eventLog('Im here');
    }
}

function readPressureData(register,spireID){
    plc_client.readHoldingRegister(register, 2, function(resp){
      var mixTankP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5: 
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  MixTank Pressure::  '+mixTankP); 
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        } 
    });
    plc_client.readHoldingRegister(register+10, 2, function(resp){
      var h2TankP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5: 
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  HydrogenTank Pressure::  '+h2TankP); 
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        } 
    });
    plc_client.readHoldingRegister(register+20, 2, function(resp){
      var pilotP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5: 
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  Pilot Pressure::  '+pilotP);
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        }  
    });
    plc_client.readHoldingRegister(register+30, 2, function(resp){
      var lel1P = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5: 
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  LELSensor 1 Level::  '+lel1P);
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        }   
    });
    plc_client.readHoldingRegister(register+40, 2, function(resp){
      var lel2P = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5: 
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  LELSensor 2 Level::  '+lel2P); 
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        }   
    });
    plc_client.readHoldingRegister(register+50, 2, function(resp){
      var o2P = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      switch (spireID){
            case 1: 
            case 2: 
            case 3: 
            case 4: 
            case 5:
            case 6: fireLog.fireEventLog('FireSpire- '+spireID+ '  Oxygen Level::  '+o2P); 
                    break;
            default:
                fireLog.fireEventLog("Not Found");
        }   
    });
}

function readValveStatus(register){
    plc_client.readHoldingRegister(register,6,function(resp){
      if (resp != undefined && resp != null){
        var spire1Status = resp.register[0];  //
        var spire2Status = resp.register[1];  //
        var spire3Status = resp.register[2];  //
        var spire4Status = resp.register[3];  //
        var spire5Status = resp.register[4];  //
        var spire6Status = resp.register[5];  //

        fireLog.fireEventLog('FireSpire-1 ValveStatus::  '+spire1Status);  
        fireLog.fireEventLog('FireSpire-2 ValveStatus::  '+spire2Status);  
        fireLog.fireEventLog('FireSpire-3 ValveStatus::  '+spire3Status);  
        fireLog.fireEventLog('FireSpire-4 ValveStatus::  '+spire4Status);  
        fireLog.fireEventLog('FireSpire-5 ValveStatus::  '+spire5Status);  
        fireLog.fireEventLog('FireSpire-6 ValveStatus::  '+spire6Status);  
           
        parseValveStatus(spire1Status,1);  
        parseValveStatus(spire2Status,2); 
        parseValveStatus(spire3Status,3); 
        parseValveStatus(spire4Status,4); 
        parseValveStatus(spire5Status,5); 
        parseValveStatus(spire6Status,6);
      }      
    });
}

function readN2FlowData(register){
    plc_client.readHoldingRegister(register,6,function(resp){
      if (resp != undefined && resp != null){
        var f1n2Status = resp.register[0];  //
        var f2n2Status = resp.register[1];  //
        var f3n2Status = resp.register[2];  //
        var f4n2Status = resp.register[3];  //
        var f5n2Status = resp.register[4];  //
        var f6n2Status = resp.register[5];  //

        fireLog.fireEventLog('FireSpire-1 N2Flow::  '+f1n2Status);  
        fireLog.fireEventLog('FireSpire-2 N2Flow::  '+f2n2Status);  
        fireLog.fireEventLog('FireSpire-3 N2Flow::  '+f3n2Status);  
        fireLog.fireEventLog('FireSpire-4 N2Flow::  '+f4n2Status);  
        fireLog.fireEventLog('FireSpire-5 N2Flow::  '+f5n2Status);  
        fireLog.fireEventLog('FireSpire-6 N2Flow::  '+f6n2Status);  
      }      
    });
}

function readAlarmStatus(register){
    plc_client.readHoldingRegister(register,6,function(resp){
      if (resp != undefined && resp != null){
        var alarm1Status = resp.register[0];  //
        var alarm2Status = resp.register[1];  //
        var alarm3Status = resp.register[2];  //
        var alarm4Status = resp.register[3];  //
        var alarm5Status = resp.register[4];  //
        var alarm6Status = resp.register[5];  //

        fireLog.fireEventLog('FireSpire-1 AlarmStatus::  '+alarm1Status); 
        fireLog.fireEventLog('FireSpire-2 AlarmStatus::  '+alarm2Status); 
        fireLog.fireEventLog('FireSpire-3 AlarmStatus::  '+alarm3Status); 
        fireLog.fireEventLog('FireSpire-4 AlarmStatus::  '+alarm4Status); 
        fireLog.fireEventLog('FireSpire-5 AlarmStatus::  '+alarm5Status); 
        fireLog.fireEventLog('FireSpire-6 AlarmStatus::  '+alarm6Status); 

        parseAlarmStatus(alarm1Status,1);
        parseAlarmStatus(alarm2Status,2);
        parseAlarmStatus(alarm3Status,3);
        parseAlarmStatus(alarm4Status,4);
        parseAlarmStatus(alarm5Status,5);
        parseAlarmStatus(alarm6Status,6);
      }      
    });
}

function parseValveStatus(registerValue,spireID){
    var bit0 = nthBit(registerValue,0);
    var bit1 = nthBit(registerValue,1);
    var bit2 = nthBit(registerValue,2);
    var bit3 = nthBit(registerValue,3);
    var bit4 = nthBit(registerValue,4);
    var bit5 = nthBit(registerValue,5);
    var bit6 = nthBit(registerValue,6);
    var bit7 = nthBit(registerValue,7);
    var bit8 = nthBit(registerValue,8);
    var bit9 = nthBit(registerValue,9);
    var bit10 = nthBit(registerValue,10);
    var bit11 = nthBit(registerValue,11);
    var bit12 = nthBit(registerValue,12);
    var bit13 = nthBit(registerValue,13);
    var bit14 = nthBit(registerValue,14);
    var bit15 = nthBit(registerValue,15);


    fireLog.fireEventLog('KV- '+spireID+'101  Position:  '+bit0); 
    fireLog.fireEventLog('KV- '+spireID+'102  Position:  '+bit1);
    fireLog.fireEventLog('KV- '+spireID+'103  Position:  '+bit2);
    fireLog.fireEventLog('KV- '+spireID+'104  Position:  '+bit3);
    fireLog.fireEventLog('KV- '+spireID+'105  Position:  '+bit4);
    fireLog.fireEventLog('KV- '+spireID+'106  Position:  '+bit5);
    fireLog.fireEventLog('KV- '+spireID+'107  Position:  '+bit6);
    fireLog.fireEventLog('KV- '+spireID+'108  Position:  '+bit7);
    fireLog.fireEventLog('YV- '+spireID+'101  Position:  '+bit8);
    fireLog.fireEventLog('KV- '+spireID+'109  Position:  '+bit9);
    fireLog.fireEventLog('KV- '+spireID+'110  Position:  '+bit9);
    fireLog.fireEventLog('KV- '+spireID+'115  Position:  '+bit9);
    fireLog.fireEventLog('KV- '+spireID+'111  Position:  '+bit10);
    fireLog.fireEventLog('KV- '+spireID+'116  Position:  '+bit11);
    fireLog.fireEventLog('KV- '+spireID+'114  Position:  '+bit12);
    fireLog.fireEventLog('KV- '+spireID+'117  Position:  '+bit13);
    fireLog.fireEventLog('KV- '+spireID+'112  Position:  '+bit14);
    fireLog.fireEventLog('KV- '+spireID+'113  Position:  '+bit14);

}

function parseAlarmStatus(registerValue,spireID){
    var bit0 = nthBit(registerValue,0);
    var bit1 = nthBit(registerValue,1);
    var bit2 = nthBit(registerValue,2);
    var bit3 = nthBit(registerValue,3);
    var bit4 = nthBit(registerValue,4);
    var bit5 = nthBit(registerValue,5);
    var bit6 = nthBit(registerValue,6);
    var bit7 = nthBit(registerValue,7);
    var bit8 = nthBit(registerValue,8);
    var bit9 = nthBit(registerValue,9);
    var bit10 = nthBit(registerValue,10);
    var bit11 = nthBit(registerValue,11);
    var bit12 = nthBit(registerValue,12);
    var bit13 = nthBit(registerValue,13);
    var bit14 = nthBit(registerValue,14);
    var bit15 = nthBit(registerValue,15);


    fireLog.fireEventLog('FireSpire- '+spireID+'  FireEnabled:  '+bit0); 
    fireLog.fireEventLog('FireSpire- '+spireID+'  Call For Ignition:  '+bit1);
    fireLog.fireEventLog('FireSpire- '+spireID+'  Flame Detected:  '+bit2);
    fireLog.fireEventLog('FireSpire- '+spireID+'  Moisture Alarm:  '+bit3);
    fireLog.fireEventLog('FireSpire- '+spireID+'  Burner Faulted:  '+bit4);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 102 Alarm:  '+bit5);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 102 Warning:  '+bit6);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 102 Fault:  '+bit7);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 101 Alarm:  '+bit8);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 101 Warning:  '+bit9);
    fireLog.fireEventLog('FireSpire- '+spireID+'  LEL 101 Fault:  '+bit10);
    fireLog.fireEventLog('FireSpire- '+spireID+'  MixTank Pressure High:  '+bit11);
    fireLog.fireEventLog('FireSpire- '+spireID+'  H2Tank Pressure High:  '+bit12);
    fireLog.fireEventLog('FireSpire- '+spireID+'  Estop:  '+bit13);
    fireLog.fireEventLog('FireSpire- '+spireID+'  O2 Alarm:  '+bit14);
    fireLog.fireEventLog('FireSpire- '+spireID+'  Air Flow:  '+bit15);

}

function back2Real(low, high){
  var fpnum=low|(high<<16);
  var negative=(fpnum>>31)&1;
  var exponent=(fpnum>>23)&0xFF;
  var mantissa=(fpnum&0x7FFFFF);
  if(exponent==255){
   if(mantissa!==0)return Number.NaN;
   return (negative) ? Number.NEGATIVE_INFINITY :
         Number.POSITIVE_INFINITY;
  }
  if(exponent===0)exponent++;
  else mantissa|=0x800000;
  exponent-=127;
  var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
  if(negative)ret=-ret;
  return ret;
}

function nthBit(n,b){

    var currentBit = 1 << b;

    if (currentBit & n){
        return 1;
    }

    return 0;
}

module.exports=fireLogger;