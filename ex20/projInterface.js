//*********Notes from Jeremy on Expo Projectors/Mirrors and Lift control*****************

// Expo lifts control and mirrors control

// wall 1 mirrors/lifts -> turns up PRJ 301, 302 ,303, 304,205, 206, 207…..
// wall 2 mirrors/lifts -> turns up PRJ 101, 102 ,103, 104,305, 306, 307…..
// wall 3 mirrors/lifts -> turns up PRJ 201, 202 ,203, 204,105, 106, 107…..

// PRJ-101 -> BEM106(10.0.6.101) and BEM108(10.0.6.102)
// -
// -
// -
// -
// -
// PRJ-107 -> BEM106(10.0.6.113) and BEM108(10.0.6.114)
// PRJ-201 -> BEM106(10.0.6.115) and BEM108(10.0.6.116)
// -
// -
// -
// -
// -
// PRJ-207 -> BEM106(10.0.6.127) and BEM108(10.0.6.128)
// PRJ-301 -> BEM106(10.0.6.129) and BEM108(10.0.6.130)
// -
// -
// -
// -
// -
// PRJ-307 -> BEM106(10.0.6.141) and BEM108(10.0.6.142)

// Command 1 -> Mirror up / IR lift up / Power ON
// Command 0 -> Mirror down / IR lift down / Power OFF
// BEM106 is Output module (Relay ON/OFF commands are sent)
// CH 1-6 -> Power 
// CH 7     -> Mirror Lift
// CH 8     -> IR lift

// BEM108 is Input module
// CH 1 -> Mirror position 

// Checkpoints: 
// Lift/Mirror Controls 
// 1. Mirror UP       ->  Power ON  ->  IR Lift UP
// 2. IR Lift DOWN ->  Power OFF ->  Mirror DOWN

// If Mirror is DOWN, IR Lift must be 0    
// 1. BEM106 CH 7 send command 1
// 2. wait for BEM108 CH 1 to change state from 0 to 1
// 3. Once BEM108 CH 1 is 1 wait for t=5 seconds  
// 4. then BEM106 CH 8 send command 1 for IR lift

// IR Lift and Power go Together (either both are 0 / 1)

function projWrapper(prjID,IP1,cmdControl){
    if(cmdControl==1){
       upControl(prjID,IP1);
    } else {
       dwnControl(prjID,IP1);
    }  
}

function upControl(prjID,IP1){
    sendCommandsToMirror(prjID,IP1,1);
    watchDog.eventLog('Command: 1 Sent');
    setTimeout(function(){
        watchDog.eventLog('Verifying Commands Sent Earlier to Mirror');
         verifyCommandSent(prjID,IP1);
    },60000);
}

function dwnControl(prjID,IP1){
    setTimeout(function(){
        sendCommandsToLift(prjID,IP1,0);
        watchDog.eventLog('Command: 0 Sent');
        watchDog.eventLog('Executing Proj Commands on Projector ID::   '+prjID+ '   Sending Command ::  Power OFF');
        projReq.sendPacketToProjectors(3,prjID);      //power off Projector
        setTimeout(function(){
            watchDog.eventLog('Executing Proj Commands on Projector ID::   '+prjID+'   Sending Command ::  Power Status');
            projReq.sendPacketToProjectors(1,prjID);  //check status of Projector
        },1000);
        setTimeout(function(){
            sendCommandsToMirror(prjID,IP1,0);
        },30000);
    },3000);
    
}

function sendCommandsToMirror(prjID,IP1,commandInput){
    bemop_client.destroy();
    bemop_client=null;
    bemop_client = jsModbus.createTCPClient(502,IP1,function(err){
        if(err)
        {
            watchDog.eventLog('BEM106 Modbus Connection Failed '+IP1);
        }
        else
        {  
            watchDog.eventLog('BEM106 Modbus Connection Success '+IP1);
        }
    });
    var cmd = commandInput;
    if (cmd == 1){
        bemop_client.writeSingleCoil(6,1,function(resp){
            watchDog.eventLog('Wrte 1');
            bemop_client.readCoils(0,8,function(resp){
                watchDog.eventLog('Op value 1 is  '+resp.coils[0]);
                watchDog.eventLog('Op value 2 is  '+resp.coils[1]);
                watchDog.eventLog('Op value 3 is  '+resp.coils[2]);
                watchDog.eventLog('Op value 4 is  '+resp.coils[3]);
                watchDog.eventLog('Op value 5 is  '+resp.coils[4]);
                watchDog.eventLog('Op value 6 is  '+resp.coils[5]);
                watchDog.eventLog('Op value 7 is  '+resp.coils[6]);
                watchDog.eventLog('Op value 8 is  '+resp.coils[7]);
                if(resp.coils[0]==1){
                    cmdSend=1;
                }
            });
        });
        
    } else {
        bemop_client.writeSingleCoil(6,0,function(resp){});  
        watchDog.eventLog('Wrte 0'); 
    }
}

function verifyCommandSent(prjID,IP1){
    bemop_client.readCoils(0,8,function(resp){
        if(resp.coils[6]==1){
            watchDog.eventLog('Op value is  '+resp.coils[6]);
            verifyCommandRecd(prjID,IP1);
        } else {
            watchDog.eventLog('Op value is  '+resp.coils[6]);
            watchDog.eventLog('Failed To Write Command');
        }
    }); 
}

function verifyCommandRecd(prjID,IP1){
     var res = 0;
     res = mirrorPos[prjID-1];
     watchDog.eventLog("Input value is   "+res);
     if (res==1){
        setTimeout(function(){
            watchDog.eventLog('Sending commands to Lift');
            sendCommandsToLift(prjID,IP1,1);
        },10000);
     }
}

function sendCommandsToLift(prjID,IP1,commandInput){
    var ip = IP1;
    bemop_client.destroy();
    bemop_client=null;
    bemop_client = jsModbus.createTCPClient(502,ip,function(err){
        if(err)
        {
            watchDog.eventLog('BEM106 Modbus Connection Failed '+ip);
        }
        else
        {  
            watchDog.eventLog('BEM106 Modbus Connection Success '+ip);
        }
    });
    var cmd = commandInput;
    if (cmd == 1){
        watchDog.eventLog('Wrte 1');
        bemop_client.writeSingleCoil(0,1,function(resp){});
        bemop_client.writeSingleCoil(1,1,function(resp){});
        bemop_client.writeSingleCoil(2,1,function(resp){});
        bemop_client.writeSingleCoil(3,1,function(resp){});
        bemop_client.writeSingleCoil(4,1,function(resp){});
        bemop_client.writeSingleCoil(5,1,function(resp){});
        bemop_client.writeSingleCoil(7,1,function(resp){}); 
    } else {
        watchDog.eventLog('Wrte 0');
        bemop_client.writeSingleCoil(0,0,function(resp){});
        bemop_client.writeSingleCoil(1,0,function(resp){});
        bemop_client.writeSingleCoil(2,0,function(resp){});
        bemop_client.writeSingleCoil(3,0,function(resp){});
        bemop_client.writeSingleCoil(4,0,function(resp){});
        bemop_client.writeSingleCoil(5,0,function(resp){});
        bemop_client.writeSingleCoil(7,0,function(resp){}); 
    }
}
module.exports = projWrapper;