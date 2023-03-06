var moment = new Date();

//===============  Required Modules HELLO RAK

var http = require("http");
var sys = require("sys");
var querystring = require("querystring");
var url = require("url");
var os = require("os");
var util = require("util");

//===============  Scripts

var download_files = require("./Includes/download_files");
var logger = require("./Includes/logger");

var triggerScripts = require("./trigScripts.js");

fs = require("fs");
jsModbus = require("./Includes/jsModbus");
watchDog = require("./Includes/watchDog");
fireLog = require("./Includes/fireLog");
watchLog = require("./Includes/watchLog");

//emailReq = require("./emailClient.js");
projCmd = require("./projInterface.js");
projReq = require("./projData.js");
vfdCode = require("./vfdFaultcode.js");
alphaconverter = require("./Includes/alphaconverter");
//===============  Global Parameters

homeD = __dirname;       //Location of the main scripts
proj = 'EX20';    //display this on WatchDog. Also extracted from the folder name on the server    
timerCount = [0,0,0,0,0,0,0,0,0,0];
sysStatus = [];          //Array that is displayed on Read ErrorLog - old
devStatus = [];          //Array is used to compare with sysStatus to determine change in status
playStatus = [];         //Array that is displayed on Read ErrorLog - new
manPlaying = 0;          //TimeKeeper records if SPM is playing from Manual Mode. 0 = not playing 1 = playing
showPlayingBit=0;
manIndex = 0;            //Denotes which show is being played currently by the playlist in manual mode.
playing=0;               //1 = SPM is currently playing show
show=0;                  //The show that is currently loaded in the SPM
showType=0;              //The showType that is currently loaded in the SPM
moment1=new Date();      //The date object used as reference for show times
deflate=0;               //stringfied time object used by iPad to display show time remaining
showTime_remaining=0;    //used to display show time remaining in seconds (for server use, BMS, etc)
nxtShow=0;               //The next show in queue
nxtTime=0;               //The next show time in queue
updNxt=1;                //When the nxt's need to be updated. Updates alphabuffer when set to 1
newDay=0;                //A new day and enables the system to update and prepare for the new day
m7Bit = 0;
spmTempData = 0;
spmPLCData = 0;
serviceRequired = 0;
cmdFlag=0;
mirrorPos = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

dayMode=0;
dayModeStatus=0;
spmRATMode = 0;      //read RAT mode status from SPM and display it on iPad
showStopper=0;           //cumilative status of the showStopper bits read from the PLC.

tempflameSp1=0;
tempflameSp2=0;
tempflameSp3=0;
tempflameSp4=0;
tempflameSp5=0;
tempflameSp6=0;

animValvePos = [];

vfd1_faultCode = [];
vfd2_faultCode = [];
vfd3_faultCode = [];

jumpToStep_auto=0;       //auto mode case 
jumpToStep_manual=0;     //man mode case
autoTimeout=0;           //timekeeper code to reset jumpToStep variables   
currentShow=0;           //variable used in timekeeper to update the global variable show

NOEConnected=false;
NOE_Heartbeat=0;   

PLCConnected=false;      //Server - PLC Modbus connection status 
PLC_Heartbeat=0;         //Counter used to check Modbus connection with the PLC 

PLC_702Heartbeat=0;         //Counter used to check Modbus connection with the PLC 
PLC_704Heartbeat=0;         //Counter used to check Modbus connection with the PLC 

SPMConnected=false;      //Server - SPM Modbus connection status
SPM_Heartbeat=0;         //Counter used to check Modbus connection with the SPM 

BMSConnected=false;      //Server - BMS Modbus connection status 
BMS_Heartbeat=0;         //Counter used to check Modbus connection with the BMS

timeLastCmnd = 0;
sendOnce=1;
//TimeKeeper records for which time last show-open command was sent to SPM, scheduler/manual
//has to be updated by the iPad when time is synced 


idleState_Counter = 0;   //used to play show0 when no show is playing
show0_endShow = 1;      // flag used to play show0 at the end
windHi = 0;
windLo = 0;
windNo = 0;


//===============  Time Sync related variable
//from PLC
time_dayofWeek = 0;

time_Seconds = 0;
time_Minutes = 0;
time_Hour = 0;

time_Date = 0;
time_Month = 0;
time_Century = 0;
//into the server
mainTime = new Date();
serverTime = 0;

//Filler Show related variables
fillerShow_enable = 0;   //enable/disble button on the ipad
fillerShow_ok = 0;       //will be set based on the start time and end time

//===============  User Changeable Parameters

autoMan = 0;                //0 = scheduler 1 = manual
deadMan = 0;                //1 = enabledeadMan 0 = disableDeadman 
manPlay = 0;                //0 = user wants to stop show, SPM transforms to segment 0
manFocus = 1;            //Denotes what playlist is in focus on user's iPad. betaBuffer is generated using this variable

// ===============  Water Quality
wq1_Live = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
wq2_Live = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
wq3_Live = {"orp" : [], "ph" : [], "tds" :[], "br" : [], "date" : []};
sysData  = {"data" : [], "date" : []};
scanStatus = {"done":true , "progress": {"numShows": 0, "currentShow": 0, "numTestShows": 0, "currentTestShow":0}};
prj= {"temp": [], "date" : " "};
// sysiPadData  = {"data" : [], "date" : []};
//================ Misc

//Initiate alphabuffer
runOnceOnly = 1; //timeSync.js

//Filtration Pump Status used in BW code
filtrationPump_Status = 1; //1 - pump fault, 0 - good

//==================== Modbus Connection

//currentDate = new Date();
//plc_ip = 10.27.173.230 // Change these ip address when you deploy at site
//spm_ip = 10.27.173.201

bemop_client = jsModbus.createTCPClient(502,'10.0.4.234',function(err){
    if(err)
    {
        watchDog.eventLog('BEM106 Modbus Connection Failed ');
    }
    else
    {  
        watchDog.eventLog('BEM106 Modbus Connection Success ');
    }
});

plc_client = jsModbus.createTCPClient(502,'10.0.4.230',function(err){
    if(err){
        watchDog.eventLog('PLC Modbus Connection Failed');
        PLCConnected=false;
    }
    else{  
        watchDog.eventLog('PLC Modbus Connection Successful');
        PLCConnected=true;
    }
});

noe_client = jsModbus.createTCPClient(502,'10.0.4.231',function(err){
    if(err){
        watchDog.eventLog('NOE Modbus Connection Failed');
        NOEConnected=false;
    }
    else{  
        watchDog.eventLog('NOE Modbus Connection Successful');
        NOEConnected=true;
    }
});

spm_client = jsModbus.createTCPClient(502,'10.0.4.201',function(err){
    if(err){
        watchDog.eventLog('SPM Modbus Connection Failed');
        SPMConnected=false; 
    }
    else{
        watchDog.eventLog('SPM Modbus Connection Successful');
        SPMConnected=true;
    }
});

//==================== User File Directories

//Global Persistent Data
prjTempData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/temperatureData.txt','utf-8'));
shows=riskyParse(fs.readFileSync(__dirname+'/UserFiles/shows.txt','utf-8'),'shows','showsBkp',1);
tmpshows=riskyParse(fs.readFileSync(__dirname+'/UserFiles/shows.txt','utf-8'),'shows','showsBkp',1);
playlists=riskyParse(fs.readFileSync(__dirname+'/UserFiles/playlists.txt','utf-8'),'playlists','playlistsBkp',1);
alphabufferData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/alphabuffer.txt','utf-8'),'alphabuffer','alphabufferBkp',1);
betabufferData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/betabuffer.txt','utf-8'),'betabuffer','betabufferBkp',1);
fillerShowSch = riskyParse(fs.readFileSync(__dirname+'/UserFiles/fillerShowSch.txt','utf-8'),'fillerShowSch','fillerShowSchBkp',1);
fillerShow=riskyParse(fs.readFileSync(__dirname+'/UserFiles/fillerShow.txt','utf-8'),'fillerShow','fillerShowBkp',1);
schedules=[];

for(var f=1;f<5;f++){
    schedules.push(riskyParse(fs.readFileSync(__dirname+'/UserFiles/schedule'+f+'.txt','utf-8'),'schedule'+f,'schedule'+f+'Bkp',1));
}

timetable=riskyParse(fs.readFileSync(__dirname+'/UserFiles/timetable.txt','utf-8'),'timetable','timetableBkp',1);
lights=riskyParse(fs.readFileSync(__dirname+'/UserFiles/lights.txt','utf-8'),'lights','lightsBkp',1);

filterSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/filterSch.txt','utf-8'),'filterSch','filterSchBkp',1);
projSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/projSch.txt','utf-8'),'projSch','projSchBkp',1);
runnelSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/runnelSch.txt','utf-8'),'runnelSch','runnelSchBkp',1);
runnelLightSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/runnelLightSch.txt','utf-8'),'runnelLightSch','runnelLightSchBkp',1);
displayPumpSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/displayPumpSch.txt','utf-8'),'displayPumpSch','displayPumpSchBkp',1);
surgeSch=riskyParse(fs.readFileSync(__dirname+'/UserFiles/surgeSch.txt','utf-8'),'surgeSch','surgeSchBkp',1);
windScalingData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/windScalingData.txt','utf-8'),'windScalingData','windScalingDataBkp',1);

fillerShowSch = riskyParse(fs.readFileSync(__dirname+'/UserFiles/fillerShowSch.txt','utf-8'),'fillerShowSch','fillerShowSchBkp',1);
fillerShow=riskyParse(fs.readFileSync(__dirname+'/UserFiles/fillerShow.txt','utf-8'),'fillerShow','fillerShowBkp',1);
bwData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/backwash.txt','utf-8'),'backwash','backwashBkp',1);
bw2Data=riskyParse(fs.readFileSync(__dirname+'/UserFiles/backwashTwo.txt','utf-8'),'backwashTwo','backwashTwoBkp',1);
bw3Data=riskyParse(fs.readFileSync(__dirname+'/UserFiles/backwashThree.txt','utf-8'),'backwashThree','backwashThreeBkp',1);
bwData.SchBWStatus = 0;
bw2Data.SchBWStatus = 0;
bw3Data.SchBWStatus = 0;

purgeData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/purgeSch.txt','utf-8'),'purgeSch','purgeSchBkp',1);

playMode_init = riskyParse(fs.readFileSync(__dirname+'/UserFiles/playMode.txt','utf-8'),'playMode','playModeBkp',1);

if (playMode_init.autoMan !== undefined){
    autoMan = playMode_init.autoMan; // user changeable. 0=scheduler 1=manual
}
else{
    autoMan = 1;
}

//Read in the project name from /etc/hostname
proj = fs.readFileSync('/etc/hostname','utf-8').replace(/(\r\n|\n|\r)/gm,"");

//Initialize the next show and next time
var future = alphaconverter.seer(moment.getHours()*10000 + moment.getMinutes()*100 + moment.getSeconds(),0);
nxtShow=future[1];
nxtTime=future[0];

//==================== HTTP Server

//Create server and start listening for HTTP requests

http.createServer(onRequest).listen(8080);

//Define callback function for http.createServer

function onRequest(request, response){
    
    var auth = request.headers['authorization'];
    
    if(!auth) {
    
        response.statusCode = 401;
        response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
        response.end('<html><body>Forbidden</body></html>');
    
    }

    else if(auth){

        var tmp = auth.split(' ');
        var buf = new Buffer(tmp[1], 'base64');
        var plain_auth = buf.toString();
        var creds = plain_auth.split(':');
        var username = creds[0];
        var password = creds[1];

        if((username === 'wet_act') && (password === 'A3139gg1121')){

            var query = url.parse(request.url).query;
            var path = url.parse(request.url).pathname;

            if (path === '/sendMirrCmd'){
                //[10.0.4.236,1]
                cmdFlag=1;
                response.writeHead(200,{"Content-Type": "text"});
                query = decodeURIComponent(query);
                query = JSON.parse(query);
                var pjIP = "";
                switch (query[0]){
                    case 1: pjIP = "10.0.6.101";
                            break;
                    case 2: pjIP = "10.0.6.103";
                            break;
                    case 3: pjIP = "10.0.6.105";
                            break;
                    case 4: pjIP = "10.0.6.107";
                            break;
                    case 5: pjIP = "10.0.6.109";
                            break;
                    case 6: pjIP = "10.0.6.111";
                            break;
                    case 7: pjIP = "10.0.6.113";
                            break;
                    case 8: pjIP = "10.0.6.115";
                            break;
                    case 9: pjIP = "10.0.6.117";
                            break;
                    case 10: pjIP = "10.0.6.119";
                            break;
                    case 11: pjIP = "10.0.6.121";
                            break;
                    case 12: pjIP = "10.0.6.123";
                            break;
                    case 13: pjIP = "10.0.6.125";
                            break;
                    case 14: pjIP = "10.0.6.127";
                            break;
                    case 15: pjIP = "10.0.6.129";
                            break;
                    case 16: pjIP = "10.0.6.131";
                            break;
                    case 17: pjIP = "10.0.6.133";
                            break;
                    case 18: pjIP = "10.0.6.135";
                            break;
                    case 19: pjIP = "10.0.6.137";
                            break;
                    case 20: pjIP = "10.0.6.139";
                            break;
                    case 21: pjIP = "10.0.6.141";
                            break;
                    default:
                        watchDog.eventLog("Cmd Not Found");
                }
                projCmd(query[0],pjIP,query[1]);
                watchDog.eventLog('Executing Proj Commands on Projector ID::  '+query[0]+'   @ BEM106 Projector IP ::  '+pjIP+'    with Command ::  '+query[1]);
                response.end(JSON.stringify({"started": true}));  
                setTimeout(function(){
                    cmdFlag=0;
                },75000); 
            }else if (path === '/sendWall5Cmd'){
                cmdFlag=1;
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify({"started": true}));  
                watchDog.eventLog('Wall1 --> Executed 1st Cmd: PRJ-301');
                projCmd(1,"10.0.4.236",query);
                setTimeout(function(){
                    watchDog.eventLog('Wall1 --> Executed 2nd Cmd: PRJ-302');
                    projCmd(2,"10.0.4.236",query-1);
                    setTimeout(function(){
                        watchDog.eventLog('Wall1 --> Executed 3rd Cmd: PRJ-303');
                        projCmd(3,"10.0.4.236",query);
                        setTimeout(function(){
                            watchDog.eventLog('Wall1 --> Executed 4th Cmd: PRJ-304');
                            projCmd(4,"10.0.4.236",query-1);
                            setTimeout(function(){
                                watchDog.eventLog('Wall1 --> Executed 5th Cmd: PRJ-205');
                                projCmd(5,"10.0.4.236",query);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall1 --> Executed 6th Cmd: PRJ-206');
                                    projCmd(6,"10.0.4.236",query-1);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall1 --> Executed 7th Cmd: PRJ-207');
                                        projCmd(7,"10.0.4.236",query);
                                        cmdFlag=0;
                                    },75000);
                                },75000);
                            },75000);
                        },75000);
                    },75000);
                },75000);  
            }else if (path === '/sendWall1Cmd'){
                cmdFlag=1;
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify({"started": true}));  
                watchDog.eventLog('Wall1 --> Executed 1st Cmd: PRJ-301');
                projCmd(15,"10.0.6.129",query);
                setTimeout(function(){
                    watchDog.eventLog('Wall1 --> Executed 2nd Cmd: PRJ-302');
                    projCmd(16,"10.0.6.131",query);
                    setTimeout(function(){
                        watchDog.eventLog('Wall1 --> Executed 3rd Cmd: PRJ-303');
                        projCmd(17,"10.0.6.133",query);
                        setTimeout(function(){
                            watchDog.eventLog('Wall1 --> Executed 4th Cmd: PRJ-304');
                            projCmd(18,"10.0.6.135",query);
                            setTimeout(function(){
                                watchDog.eventLog('Wall1 --> Executed 5th Cmd: PRJ-205');
                                projCmd(12,"10.0.6.123",query);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall1 --> Executed 6th Cmd: PRJ-206');
                                    projCmd(13,"10.0.6.125",query);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall1 --> Executed 7th Cmd: PRJ-207');
                                        projCmd(14,"10.0.6.127",query);
                                         cmdFlag=0;
                                    },75000);
                                },75000);
                            },75000);
                        },75000);
                    },75000);
                },75000);  
            }else if (path === '/sendWall2Cmd'){
                cmdFlag=1;
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify({"started": true}));  
                watchDog.eventLog('Wall2 --> Executed 1st Cmd: PRJ-101');
                projCmd(1,"10.0.6.101",query);
                setTimeout(function(){
                    watchDog.eventLog('Wall2 --> Executed 2nd Cmd: PRJ-102');
                    projCmd(2,"10.0.6.103",query);
                    setTimeout(function(){
                        watchDog.eventLog('Wall2 --> Executed 3rd Cmd: PRJ-103');
                        projCmd(3,"10.0.6.105",query);
                        setTimeout(function(){
                            watchDog.eventLog('Wall2 --> Executed 4th Cmd: PRJ-104');
                            projCmd(4,"10.0.6.107",query);
                            setTimeout(function(){
                                watchDog.eventLog('Wall2 --> Executed 5th Cmd: PRJ-305');
                                projCmd(19,"10.0.6.137",query);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall2 --> Executed 6th Cmd: PRJ-306');
                                    projCmd(20,"10.0.6.139",query);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall2 --> Executed 7th Cmd: PRJ-307');
                                        projCmd(21,"10.0.6.141",query);
                                        cmdFlag=0;
                                    },75000);
                                },75000);
                            },75000);
                        },75000);
                    },75000);
                },75000);  
            }else if (path === '/sendWall3Cmd'){
                cmdFlag=1;
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify({"started": true}));  
                watchDog.eventLog('Wall3 --> Executed 1st Cmd: PRJ-201');
                projCmd(8,"10.0.6.115",query);
                setTimeout(function(){
                    watchDog.eventLog('Wall3 --> Executed 2nd Cmd: PRJ-202');
                    projCmd(9,"10.0.6.117",query);
                    setTimeout(function(){
                        watchDog.eventLog('Wall3 --> Executed 3rd Cmd: PRJ-203');
                        projCmd(10,"10.0.6.119",query);
                        setTimeout(function(){
                            watchDog.eventLog('Wall3 --> Executed 4th Cmd: PRJ-204');
                            projCmd(11,"10.0.6.121",query);
                            setTimeout(function(){
                                watchDog.eventLog('Wall3 --> Executed 5th Cmd: PRJ-105');
                                projCmd(5,"10.0.6.109",query);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall3 --> Executed 6th Cmd: PRJ-106');
                                    projCmd(6,"10.0.6.111",query);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall3 --> Executed 7th Cmd: PRJ-107');
                                        projCmd(7,"10.0.6.113",query);
                                        cmdFlag=0;
                                    },75000);
                                },75000);
                            },75000);
                        },75000);
                    },75000);
                },75000);  
            }else if (path === '/sendProjLogCmds'){
                //projReq.sendPacketToProjectors(1,1);
                response.writeHead(200,{"Content-Type": "text"});
                query = decodeURIComponent(query);
                query = JSON.parse(query);
                projReq.sendPacketToProjectors(query[0],query[1]);
                watchDog.eventLog('Executing Proj Commands on Projector ID::  '+query[1]+'   Sending Command ::  '+query[0]);
                // for(var i = 1; i < 22; i++){
                //       projReq.sendPacketToProjectors(1,i);
                // }
                // setTimeout(function(){
                //     //watchDog.eventLog("Prj Data is :: "+JSON.stringify(prj));
                //    fs.writeFileSync(__dirname+'/UserFiles/temperatureData.txt',JSON.stringify(prj),'utf-8');
                // },20000);
                response.end(JSON.stringify("Done"));
            
            }else if (path === '/readStatusLog'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(sysStatus)); 
            
            }else if (path === '/readServerTime'){
                var serverTime = new Date();
                var sendTime = (serverTime.getFullYear()+'-'+(serverTime.getMonth()+1))+'-'+ serverTime.getDate()+' '+ serverTime.getHours()+':' + (serverTime.getMinutes()<10?'0':'') + serverTime.getMinutes()+':'+ (serverTime.getSeconds()<10?'0':'')+serverTime.getSeconds();
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(sendTime));
                
            }else if (path === '/readCascadePumpSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(cascadePumpSch));
            
            }else if (path === '/writeCascadePumpSch'){
                // Write Microshooter Basin Pump Scheduler
                response.writeHead(200,{"Content-Type": "text"});
                setCSSch(query);
                response.end(JSON.stringify(cascadePumpSch));

            }else if (path === '/readSurgePumpSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(surgeSch));
            
            }else if (path === '/writeSurgePumpSch'){
                // Write Microshooter Basin Pump Scheduler
                response.writeHead(200,{"Content-Type": "text"});
                setSurgeSch(query);
                response.end(JSON.stringify(surgeSch));

            }else if (path === '/readRunnelPumpSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(runnelSch));
            
            }else if (path === '/writeRunnelPumpSch'){
                // Write Microshooter Basin Pump Scheduler
                response.writeHead(200,{"Content-Type": "text"});
                setRunnelSch(query);
                response.end(JSON.stringify(runnelSch));

            }else if (path === '/readDisplayPumpSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(displayPumpSch));
            
            }else if (path === '/writeDisplayPumpSch'){
                // Write Microshooter Basin Pump Scheduler
                response.writeHead(200,{"Content-Type": "text"});
                setDispSch(query);
                response.end(JSON.stringify(displayPumpSch));

            }else if (path === '/setDayMode'){
            
                response.writeHead(200,{"Content-Type": "text"});
                dayMode = query;
                //This will set the dayMode bit'4' on the SPM 
                watchDog.eventLog('dayMode set to  ' +dayMode);
                if (dayMode == 1){
                     spm_client.writeSingleRegister(1002,16,function(resp){});
                } else {
                     spm_client.writeSingleRegister(1002,0,function(resp){});
                }
            }else if (path === '/readplayStatus'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(playStatus));

            }else if (path === '/setTimeLastCmnd'){
            
                timeLastCmnd = 0;
                response.writeHead(200,{"Content-Type": "text"});
                watchDog.eventLog('Time Synced from iPad');

            }else if (path === '/readFillerShow'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(fillerShow));
            
            }else if (path === '/writeFillerShow'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setfillerShow(query);
                response.end(JSON.stringify(fillerShow));

            }else if (path === '/readFillerShowSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(fillerShowSch));
            
            }else if (path === '/writeFillerShowSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setFillerShowSch(query);
                response.end(JSON.stringify(fillerShowSch));

            }else if (path === '/readPrjSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(projSch));
            
            }else if (path === '/writePrjSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setProj(query);
                response.end(JSON.stringify(projSch));
            
            }else if (path === '/readRunnelLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(runnelLightSch));
            
            }else if (path === '/writeRunnelLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setPixieSch(query);
                response.end(JSON.stringify(runnelLightSch));
            
            }else if (path === '/readPrjTempData'){
            
                response.writeHead(200,{"Content-Type": "text"});
                prjTempData=riskyParse(fs.readFileSync(__dirname+'/UserFiles/temperatureData.txt','utf-8'));
                response.end(JSON.stringify(prjTempData));
            
            }else if (path === '/readLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(lights));
            
            }else if (path === '/writeLights'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setLights(query);
                response.end(JSON.stringify(lights));
            
            }else if (path === '/readFilterSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(filterSch));
            
            }else if (path === '/writeFilterSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                setFilterPump(query);
                response.end(JSON.stringify(filterSch));
            
            }else if (path === '/WQ1_Live'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(wq1_Live));   

            }else if (path === '/WQ2_Live'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(wq2_Live));   

            }else if (path === '/WQ3_Live'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(wq3_Live));   

            }else if (path === '/readPurgeSch'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(purgeData));

            }else if (path === '/writePurgeSch'){
            
                //watchDog.eventLog('BW Query from ipad');
                response.writeHead(200,{"Content-Type": "text"});
                setPurge(query);
                response.end(JSON.stringify(purgeData));    

            }else if (path === '/readBW'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(bwData));

            }else if (path === '/writeBW'){
            
                //watchDog.eventLog('BW Query from ipad');
                response.writeHead(200,{"Content-Type": "text"});
                setBW(query);
                response.end(JSON.stringify(bwData));    

            }else if (path === '/readBW2'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(bw2Data));

            }else if (path === '/writeBW2'){
            
                //watchDog.eventLog('BW Query from ipad');
                response.writeHead(200,{"Content-Type": "text"});
                setB2W(query);
                response.end(JSON.stringify(bw2Data));    

            }else if (path === '/readBW3'){
            
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(bw3Data));

            }else if (path === '/writeBW3'){
            
                //watchDog.eventLog('BW Query from ipad');
                response.writeHead(200,{"Content-Type": "text"});
                setB3W(query);
                response.end(JSON.stringify(bw3Data));    

            }else if (path === '/readScheduler'){

                var z = parseInt(query, 10);
                
                if(z<5){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify(schedules[z-1]));
                }

                z=null;
            
            }else if (path === '/writeScheduler1'){

                setScheduler1(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler2'){

                setScheduler2(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler3'){

                setScheduler3(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/writeScheduler4'){

                setScheduler4(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/readShows'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(shows));

            }else if (path === '/writeShows'){

                setShows(query);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(shows));

            }else if (path === '/readPlaylists'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(playlists));

            }else if (path === '/writePlaylists'){

                setPlaylists(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end('[]');
                },query);

            }else if (path === '/readTimeTable'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(timetable));

            }else if (path === '/writeTimeTable'){

                setTimeTable(query);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(timetable));

            }else if (path === '/readalphabuffer'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(alphabufferData[1]));
            
            }else if (path === '/readbetabuffer'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(betabufferData));

            }else if (path === '/autoMan'){
                response.writeHead(200,{"Content-Type": "text"});

                    if(query){
                        query = decodeURIComponent(query);
                        query = JSON.parse(query);
                        manFocus = query.focus;

                        if(query.state && autoMan !== query.state){
                            autoMan = query.state;
                            watchDog.eventLog("PLAYLIST PUT IN MANUAL MODE");
                        }
                        else if(!query.state && autoMan !== query.state){
                            autoMan = query.state;
                            watchDog.eventLog("PLAYLIST PUT IN AUTO MODE");
                            updNxt=1;
                        }
                    }     
                response.end(JSON.stringify([autoMan,manFocus]));

            }else if (path === '/autoManPlay'){
                response.writeHead(200,{"Content-Type": "text"});
                if(query){

                    if(playlists[manFocus-1].duration>0){

                        manPlay=parseInt(query, 10);
                        watchDog.eventLog("Set autoManPlay: " + manPlay);
                    }
                }

                response.end(JSON.stringify([manPlay]));

            }else if (path === '/startShowScanner'){
                scanStatus.done = false;
                startShowScanner();
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify({"started": true}));   
            }else if (path === '/showScannerStatus'){
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify([scanStatus]));
            }else if (path === '/createBkps'){

                var success = createBkps(['shows','playlists','schedule1','schedule2','schedule3','schedule4','timetable','lights']);
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(success));
                success = null;

            }else if (path === '/readWindScalingData'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(windScalingData));

            }else if (path === '/writeWindScalingData'){

                response.writeHead(200,{"Content-Type": "text"});
                setWindScalingData(query);
                response.end(JSON.stringify(windScalingData));

            }else if (path === '/saveSettings'){

                parsedData = querystring.parse(query);
                saveSettings(parsedData);
                response.writeHead(200,{"Content-Type": "text"});
                response.end('[]');

            }else if (path === '/loadSettings'){

                loadSettings(function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                }, query);

            }else if(path === '/logsToFTP'){

                logsToFTP(function(error,stdout,stderr){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(JSON.stringify([error,stdout,stderr]));
                });

            }else if (path === '/reboot'){

                response.writeHead(200,{"Content-Type": "text"});
                response.end('Rebooting Server. Please go to /os in about 1 minute.');
                var exec = require("child_process").exec;
                exec('reboot');

            }else if (path === '/clearLogClient'){

                response.writeHead(200,{"Content-Type": "text/html"});
                var newDate = new Date();
                var timeStamp = (newDate.getFullYear() 
                    + '-' + (newDate.getMonth()+1)) 
                    + '-' + newDate.getDate() 
                    + ' ' + newDate.getHours() 
                    + ':' + (newDate.getMinutes()<10?'0':'') + newDate.getMinutes() 
                    + ':' + (newDate.getSeconds()<10?'0':'') + newDate.getSeconds();
                fs.writeFileSync(__dirname+'/UserFiles/systemLog.txt','{"data":"LOG CLEARED","date":"'+timeStamp +'"}\n','utf-8');
                response.end(JSON.stringify("success"));

            }else if (path === '/clearLog'){

                response.writeHead(200,{"Content-Type": "text/html"});
                response.end('<br><input type=\'button\' onclick=\"location.href=\'/readLog\';\" value=\'Read Log\' /><input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Debug\' /><br><br>Logs have been cleared.');
                fs.writeFileSync(__dirname+'/UserFiles/logFile.txt','Start Log','utf-8');

            }else if (path === '/clearWetNodeError'){

                response.writeHead(200,{"Content-Type": "text/html"});
                response.end('[]');
                fs.writeFileSync('/etc/wetNode.error','wetNode.error\n','utf-8');

            }else if (path === '/readLog'){

                getLog(query,function(err,data){

                    data = data.replace(/[\"]/g, "'").replace(/\n/g, "??");
                    response.writeHead(200,{"Content-Type": "text"});
                    response.write("<br><input type=\'button\' onclick=\"location.href=\'/clearLog\';\" value=\'Clear Log\' /><input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Debug\' /><br><br><script type='text/javascript'>var str = \"<p>"+ data +"</p>\"; var res = str.split('??').reverse().join('</p><p>'); document.write(res);</script>");
                    response.end();

                });

            }else if (path === '/readLogClient'){
                sysDataLog=fs.readFileSync(__dirname+'/UserFiles/systemLog.txt','utf-8');
                response.writeHead(200,{"Content-Type": "text"});
                response.end(JSON.stringify(sysDataLog));
            }else if (path === '/readPrjLog'){
                projDataLog=fs.readFileSync(__dirname+'/UserFiles/projData.txt','utf-8');
                projDataLog = projDataLog.replace(/[\"]/g, "'").replace(/\n/g, "??");
                response.writeHead(200,{"Content-Type": "text"});
                response.write("<script type='text/javascript'>var str = \"<p>"+ projDataLog +"</p>\"; var res = str.split('??').reverse().join('</p><p>'); document.write(res);</script>");
                response.end();
            }else if (path === '/readWetNodeError'){

                getWetNodeError(query,function(err,data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                });

            }else if ((path === '/os') || (path === '/debug')){
                var current_time = new Date();
                response.writeHead(200,{"Content-Type": "text/html"});
                response.write(

                    '<strong>' + proj.toUpperCase() + '</strong>' + '<input type=\'button\' onclick=\"location.href=\'/debug\';\" value=\'Refresh\' /><br>'+
                    current_time + '<br><br>' +

                    '<br><strong>' + (autoMan === 1 ? 'Manual/Hand </strong>Mode' : 'Auto/Schedule </strong>Mode') +
                    '<br>' + (playing === 1 ? 'Playing: ' : 'Last Played: ') +  (show < shows.length ? shows[show].name : 'Must Show Scan! Show ' + show + ' is not in show.txt')+
                    '<br>' + 'Last Time: ' + (deflate === 'nothing' ? '---' : deflate) +
                    '<br>' + 'Next Time: ' + (nxtTime === 0 ? '---' : nxtTime) + 
                    '<br>' + 'Next Show: ' + (nxtShow === 0 ? '---' : nxtShow) + 
                    '<br>' +
                    '<br>' + 'Show Stopping Condition: ' + showStopper +
                    '<br>' + 'RATMODE Status: ' + Boolean(spmRATMode) +
                    '<br>' +
                    '<br>PLC-MB? <strong>'+PLCConnected+'</strong>' + '<input type=\'button\' onclick=\"location.href=\'/plcTest\';\" value=\'PLC Test\' />'+
                    '<br>SPM-MB? <strong>'+spm_client.isConnected()+'</strong>'+
                    '<br>NOE-MB? <strong>'+NOEConnected+'</strong>'+
                    '<br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/startShowScanner\';\" value=\'ScanSPMShows\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/showScannerStatus\';\" value=\'ScanStatus\' /><br>' +

                    '<br><input type=\'button\' onclick=\"location.href=\'/readShows\';\" value=\'Shows\' /><br>' +

                    '<br><input type=\'button\' onclick=\"location.href=\'/readPlaylists\';\" value=\'Playlists\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readScheduler?1\';\" value=\'Schedule 1\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?2\';\" value=\'Schedule 2\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?3\';\" value=\'Schedule 3\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/readScheduler?4\';\" value=\'Schedule 4\' /><br>' +

                    '<br><input type=\'button\' onclick=\"location.href=\'/readLog\';\" value=\'Read Log\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readStatusLog\';\" value=\'Read StatusLog\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/readLogClient\';\" value=\'Read DeviceStatus\' />' +
                    '<input type=\'button\' onclick=\"location.href=\'/clearLogClient\';\" value=\'Clear DeviceLogs\' /><br>' +
                    '<br><input type=\'button\' onclick=\"location.href=\'/userfilesIndex?W3trocks!\';\" value=\'Download System Files\' /><br>' +

                    '<br><br><input type=\'button\' onclick=\"location.href=\'/reboot\';\" value=\'REBOOT\' /><br>');
                    response.end();

            }else if (path === '/mbReadMW'){

                mbReadMW(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbReadM'){

                mbReadM(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbReadReal'){

                mbReadReal(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteMW'){

                query = querystring.parse(query);

                mbWriteMW(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteM'){

                query = querystring.parse(query);

                mbWriteM(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            } else if (path === '/mbWriteReal'){

                query = querystring.parse(query);

                mbWriteReal(function(data){
                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(data);
                },query);

            }else if (path === '/plcTest'){

                fs.readFile(__dirname+'/plcTest.html','utf-8',function(err,data){

                    if(err){throw err;}
                    var dataString = data.toString();

                    response.writeHead(200,{"Content-Type": "text/html"});
                    response.end(dataString);

                });

            }else if (path === '/mbReadSPM'){

                mbReadSPM(function(data){
                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);
                },query);

            }else if (path === '/mbWriteSPM'){

                query = querystring.parse(query);

                mbWriteSPM(function(data){

                    response.writeHead(200,{"Content-Type": "text"});
                    response.end(data);

                },query);
            
            }else if (path === '/userfilesIndex'){

                if(query === "W3trocks!"){
                    
                    download_files.indexOfFiles(response);
                
                }else{
                    
                    response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
                    response.statusCode = 403;
                    response.end('<html><body>Forbidden</body></html>');
                
                }
            
            }else if (path === '/userfiles'){

                download_files.downloadingFile(response, query);
            
            }else if (path === '/login'){

                response.writeHead(200,{"Content-Type":"text/html"});
                response.write("<script type='text/javascript'>var g = sessionStorage.getItem('WET');window.location.href='./userfilesIndex?'+g;</script>");
            
            }else{

                wants = 'unknown request'+" "+path+" "+query;
                response.end(wants);

            }
        }

        else if((username === proj) && (password === proj)){

            var query = url.parse(request.url).query;
            var path = url.parse(request.url).pathname;

            if (path === '/systemStatus'){
                response.writeHead(200,{"Content-Type": "text/html"});
                response.write(

                    '<strong>' + proj.toUpperCase() + '</strong>' + '<input type=\'button\' onclick=\"location.href=\'/systemStatus\';\" value=\'Refresh\' /><br>'+
                    moment + '<br><br>' +

                    '<br><strong>' + (autoMan === 1 ? 'Manual/Hand </strong>Mode' : 'Auto/Schedule </strong>Mode') +
                    '<br>' + (playing === 1 ? 'Playing: ' : 'Last Played: ') +  (show < shows.length ? shows[show].name : 'Must Show Scan! Show ' + show + ' is not in show.txt')+
                    '<br>' + 'Last Time: ' + (deflate === 'nothing' ? '---' : deflate) +
                    '<br>' + 'Next Time: ' + (nxtTime === 0 ? '---' : nxtTime) + 
                    '<br>' + 'Next Show: ' + (nxtShow === 0 ? '---' : nxtShow) + 
                    '<br>' +
                    '<br>' + 'Show Stopping Condition: ' + showStopper +
                    '<br>' +
                    '<br>PLC-MB? <strong>'+plc_client.isConnected()+'</strong>' +
                    '<br>SPM-MB? <strong>'+spm_client.isConnected()+'</strong>'+
                    '<br><input type=\'button\' onclick=\"location.href=\'/readLog_2\';\" value=\'Read Log\' /><br>' +
                    '<br>');

                    response.end();

            }
            else if (path === '/readLog_2'){

                getLog(query,function(err,data){

                    data = data.replace(/[\"]/g, "'").replace(/\n/g, "??");
                    response.writeHead(200,{"Content-Type": "text"});
                    response.write("<br><br><br><script type='text/javascript'>var str = \"<p>"+ data +"</p>\"; var res = str.split('??').reverse().join('</p><p>'); document.write(res);</script>");
                    response.end();

                });

            }
            else{
                wants = 'unknown request'+" "+path+" "+query;
                response.end(wants);
            }

        }

    }

    else{

        response.setHeader('WWW-Authenticate', 'Basic realm="Secure Area"');
        response.statusCode = 403;
        response.end('<html><body>Forbidden</body></html>');

    }
}

//==================== converts 2 INT values into Rela and vice versa

function back2Real(low, high){

    var fpnum=low|(high<<16);
    var negative=(fpnum>>31)&1;
    var exponent=(fpnum>>23)&0xFF;
    var mantissa=(fpnum&0x7FFFFF);
    
    if(exponent==255){
     
        if(mantissa!==0)return Number.NaN;
        return (negative) ? Number.NEGATIVE_INFINITY :Number.POSITIVE_INFINITY;
    
    }
    
    if(exponent===0)exponent++;
    else mantissa|=0x800000;
    
    exponent-=127;
    var ret=(mantissa*1.0/0x800000)*Math.pow(2,exponent);
    
    if(negative)ret=-ret;
    return ret;
}

function real2Back(value){

    if(isNaN(value))return [0,0xFFC0];
    if(value==Number.POSITIVE_INFINITY || value>=3.402824e38)
      return [0,0x7F80];
    if(value==Number.NEGATIVE_INFINITY || value<=-3.402824e38)
      return [0,0xFF80];

    var negative=(value<0);
    var p,x,mantissa;
    value=Math.abs(value);
  
    if(value==2.0)return [0,0x4000];
  
    else if(value>2.0){
     
        //Positive exponent
        for(var i=128;i<255;i++){
     
            p=Math.pow(2,i+1-127);
     
            if(value<p){
     
                x = Math.pow(2,i-127);
                mantissa = Math.round((value*1.0/x)*8388608);
                mantissa&=0x7FFFFF;
                value = mantissa|(i<<23);
     
                if(negative)value|=(1<<31);
     
                return [value&0xFFFF,(value>>16)&0xFFFF];
            }
        }
        
        //return infinity
        return negative ? [0,0xFF80] : [0,0x7F80];
    
    }else{

        for(var i=127;i>0;i--){
     
            //Negative exponent
            p = Math.pow(2,i-127);
        
            if(value>p){

                x = p;
                mantissa = Math.round(value*8388608.0/x);
                mantissa&=0x7FFFFF;
                value = mantissa|(i<<23);
                if(negative)value|=(1<<31);
                return [value&0xFFFF,(value>>16)&0xFFFF];

            }

        }

        //Subnormal

        x = Math.pow(2,i-126);
        mantissa = Math.round((value*8388608.0/x));
     
        if(mantissa>0x7FFFFF)mantissa=0x800000;
        value = mantissa;
     
        if(negative)value|=(1<<31);
        return [value&0xFFFF,(value>>16)&0xFFFF];
    }
}

//==================== Modbus Functions

function mbReadM(pasd,query){

    plc_client.readCoils(parseInt(query, 10),1,function(resp){

        resp = "<strong>Reading " + resp.coils[0] + "</strong> at <em>%M</em> " + query;
        pasd(resp);

    });
}

function mbReadMW(pasd,query){

    plc_client.readHoldingRegister(parseInt(query, 10),1,function(resp){

        resp = "<strong>Reading " + resp.register[0] + "</strong> at <em>%MW INT</em> " + query;
        pasd(resp);

    });
}

function mbReadReal(pasd,query){

    plc_client.readHoldingRegister(parseInt(query, 10),2,function(resp){

        resp = "<strong>Reading " + back2Real(resp.register[0], resp.register[1]) + "</strong> at <em>%MW Real</em> " + query;
        pasd(resp);

    });
}

function mbWriteM(pasd,query){

    plc_client.writeSingleCoil(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){

        resp = "<strong>Wrote " + query.val + "</strong> to <em>%M</em> " + query.addr;
        pasd(resp);

    });
}

function mbWriteMW(pasd,query){

    plc_client.writeSingleRegister(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){

        resp = "<strong>Wrote " + query.val + "</strong> to <em>%MW INT</em> " + query.addr;
        pasd(resp);

    });
}

function mbWriteReal(pasd,query){

    var realNum = real2Back(query.val);

    plc_client.writeSingleRegister(parseInt(query.addr, 10), realNum[0],function(resp){

        plc_client.writeSingleRegister(parseInt(query.addr, 10) + 1, realNum[1],function(resp){

            resp = "<strong>Wrote " + query.val + "</strong> to <em>%MW Real</em> " + query.addr;
            pasd(resp);

        });
    });
}

function mbReadSPM(pasd,query){

    spm_client.readHoldingRegister(parseInt(query, 10),1,function(resp){
        pasd(JSON.stringify(resp));
    });
}

function mbWriteSPM(pasd,query){

    spm_client.writeSingleRegister(parseInt(query.addr, 10),parseInt(query.val, 10),function(resp){
        pasd(JSON.stringify(resp));
    });
}

//==================== Set User Files

function setLights(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setLights');

    if((buf !== 0) && (buf.length == lights.length)) {
        fs.writeFileSync(__dirname+'/UserFiles/lights.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/lightsBkp.txt',query,'utf-8');
        lights = buf;
    }
    else{
        watchDog.eventLog('Lights. Bad data. No donut for you.');
    }
}

function setProj(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setProj');

    if((buf !== 0) && (buf.length == projSch.length)) {
        fs.writeFileSync(__dirname+'/UserFiles/projSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/projSchBkp.txt',query,'utf-8');
        projSch = buf;
    }
    else{
        watchDog.eventLog('Lights. Bad data. No donut for you.');
    }
}

function setOarsmanLights(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setOarsmanLights');

    if((buf !== 0) && (buf.length == oarsmanlights.length)) {
        fs.writeFileSync(__dirname+'/UserFiles/oarsmanlights.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/oarsmanlightsBkp.txt',query,'utf-8');
        oarsmanlights = buf;
    }
    else{
        watchDog.eventLog('Lights. Bad data. No donut for you.');
    }
}

function setFillerShowSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setFillerShowSch');

    if((buf !== 0) && (buf.length == fillerShowSch.length)){
        fs.writeFileSync(__dirname+'/UserFiles/fillerShowSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/fillerShowSchBkp.txt',query,'utf-8');
        fillerShowSch = buf;
    }
    else{
        watchDog.eventLog('FillerShow Sch. Bad data. No donut for you.' +buf.length +' ' +fillerShow.length);
    }
}

function setRunnelSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setRunnelSch');

    if((buf !== 0) && (buf.length == runnelSch.length)) {
        fs.writeFileSync(__dirname+'/UserFiles/runnelSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/runnelSchBkp.txt',query,'utf-8');
        runnelSch = buf;
    }
    else{
        watchDog.eventLog('Lights. Bad data. No donut for you.');
    }
}

function setPixieSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setPixieSch');

    if((buf !== 0) && (buf.length == runnelLightSch.length)) {
        fs.writeFileSync(__dirname+'/UserFiles/runnelLightSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/runnelLightSchBkp.txt',query,'utf-8');
        runnelLightSch = buf;
    }
    else{
        watchDog.eventLog('Lights. Bad data. No donut for you.');
    }
}

function setSurgeSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setSurgeSch');

    if((buf !== 0) && (buf.length == surgeSch.length)){
        fs.writeFileSync(__dirname+'/UserFiles/surgeSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/surgeSchBkp.txt',query,'utf-8');
        surgeSch = buf;
    }
    else{
        watchDog.eventLog('Weir Sch. Bad data. No donut for you.');
    }
}

function setDispSch(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setDispSch');

    if((buf !== 0) && (buf.length == displayPumpSch.length)){
        fs.writeFileSync(__dirname+'/UserFiles/displayPumpSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/displayPumpSch.txt',query,'utf-8');
        displayPumpSch = buf;
    }
    else{
        watchDog.eventLog('LepaFrog Sch. Bad data. No donut for you.');
    }
}

function setFilterPump(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setFilterPump');

    if((buf !== 0) && (buf.length == filterSch.length)){
        fs.writeFileSync(__dirname+'/UserFiles/filterSch.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/filterSchBkp.txt',query,'utf-8');
        filterSch = buf;
    }
    else{
        watchDog.eventLog('Filter Sch. Bad data. No donut for you.');
    }
}

function setBW(query){

    //watchDog.eventLog('query 1st :' +query);
    query = decodeURIComponent(query);
    query = JSON.parse(query);
    //watchDog.eventLog('query 2nd :' +query);
    var tempBWdata = bwData;
    //watchDog.eventLog('query length :' +query.length +' :: ' +query[0] +' :: ' +query[1] +' :: ' +query[2]);

    if (query.length === 2){
        //tempBWdata.duration = query[0];
        tempBWdata.schDay = query[0];
        tempBWdata.schTime = query[1];
        //watchDog.eventLog('tempBWdata.schTime:' +tempBWdata.schTime);

        var buf = riskyParse(tempBWdata,'setBW');

        if(buf !== 0){
            fs.writeFileSync(__dirname+'/UserFiles/backwash.txt',tempBWdata,'utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/backwashBkp.txt',tempBWdata,'utf-8');
            bwData = buf;
        }
    }
    else{
        watchDog.eventLog('BW. Bad data. No donut for you.');
    }
}

function setB2W(query){

    //watchDog.eventLog('query 1st :' +query);
    query = decodeURIComponent(query);
    query = JSON.parse(query);
    //watchDog.eventLog('query 2nd :' +query);
    var tempBWdata = bw2Data;
    //watchDog.eventLog('query length :' +query.length +' :: ' +query[0] +' :: ' +query[1] +' :: ' +query[2]);

    if (query.length === 2){
        //tempBWdata.duration = query[0];
        tempBWdata.schDay = query[0];
        tempBWdata.schTime = query[1];
        //watchDog.eventLog('tempBWdata.schTime:' +tempBWdata.schTime);

        var buf = riskyParse(tempBWdata,'setB2W');

        if(buf !== 0){
            fs.writeFileSync(__dirname+'/UserFiles/backwashTwo.txt',tempBWdata,'utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/backwashTwoBkp.txt',tempBWdata,'utf-8');
            bw2Data = buf;
        }
    }
    else{
        watchDog.eventLog('BW2. Bad data. No donut for you.');
    }
}

function setB3W(query){

    //watchDog.eventLog('query 1st :' +query);
    query = decodeURIComponent(query);
    query = JSON.parse(query);
    //watchDog.eventLog('query 2nd :' +query);
    var tempBWdata = bw3Data;
    //watchDog.eventLog('query length :' +query.length +' :: ' +query[0] +' :: ' +query[1] +' :: ' +query[2]);

    if (query.length === 2){
        //tempBWdata.duration = query[0];
        tempBWdata.schDay = query[0];
        tempBWdata.schTime = query[1];
        //watchDog.eventLog('tempBWdata.schTime:' +tempBWdata.schTime);

        var buf = riskyParse(tempBWdata,'setB3W');

        if(buf !== 0){
            fs.writeFileSync(__dirname+'/UserFiles/backwashThree.txt',tempBWdata,'utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/backwashThreeBkp.txt',tempBWdata,'utf-8');
            bw3Data = buf;
        }
    }
    else{
        watchDog.eventLog('BW3. Bad data. No donut for you.');
    }
}

function setPurge(query){

    //watchDog.eventLog('query 1st :' +query);
    query = decodeURIComponent(query);
    query = JSON.parse(query);
    //watchDog.eventLog('query 2nd :' +query);
    var tempBWdata = purgeData;
    //watchDog.eventLog('query length :' +query.length +' :: ' +query[0] +' :: ' +query[1] +' :: ' +query[2]);

    if (query.length === 2){
        //tempBWdata.duration = query[0];
        tempBWdata.eodschTime = query[0];
        tempBWdata.bodschTime = query[1];
        //watchDog.eventLog('tempBWdata.schTime:' +tempBWdata.schTime);

        var buf = riskyParse(tempBWdata,'setPurge');

        if(buf !== 0){
            fs.writeFileSync(__dirname+'/UserFiles/purgeSch.txt',tempBWdata,'utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/purgeSchBkp.txt',tempBWdata,'utf-8');
            purgeData = buf;
        }
    }
    else{
        watchDog.eventLog('Purge. Bad data. No donut for you.');
    }
}

function setfillerShow(query){

    query = decodeURIComponent(query);
    var buf = riskyParse(query,'setfillerShow');
    //resp != undefined && resp != null
    //check array
    var arrayChecksOut = 0;
    if ((buf.FillerShow_Number != undefined) && (buf.FillerShow_Number != null) && (buf.FillerShow_Enable != undefined) && (buf.FillerShow_Enable != null)){
        arrayChecksOut = 1;
    }

    if((buf !== 0) && arrayChecksOut){
        fs.writeFileSync(__dirname+'/UserFiles/fillerShow.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/fillerShowBkp.txt',query,'utf-8');
        fillerShow = buf;
    }
    else{
        watchDog.eventLog('FillerShow. Bad data. No donut for you.');
    }
}

function setScheduler1(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler1');

    if((buf !== 0) && (buf.length == schedules[0].length)){

        fs.writeFileSync(__dirname+'/UserFiles/schedule1.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule1Bkp.txt',query,'utf-8');
        schedules[0] = buf;

        watchDog.eventLog('Schedule1 modified');
        alphaconverter.initiate(0);
        updNxt=1;

    }
    else{
        watchDog.eventLog('Sch1. Bad data. No donut for you.');
    }

    callback(null,JSON.stringify(schedules[0]));
}

function setScheduler2(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler2');

    if((buf !== 0) && (buf.length == schedules[1].length)){

        fs.writeFileSync(__dirname+'/UserFiles/schedule2.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule2Bkp.txt',query,'utf-8');
        schedules[1] = buf;

        watchDog.eventLog('Schedule2 modified');
        alphaconverter.initiate(0);
        updNxt=1;
    
    }
    else{
        watchDog.eventLog('Sch2. Bad data. No donut for you.');
    }

    callback(null,JSON.stringify(schedules[1]));
}

function setScheduler3(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler3');

    if((buf !== 0) && (buf.length == schedules[2].length)){

        fs.writeFileSync(__dirname+'/UserFiles/schedule3.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule3Bkp.txt',query,'utf-8');
        schedules[2] = buf;

        watchDog.eventLog('Schedule3 modified');
        alphaconverter.initiate(0);
        updNxt=1;

    }
    else{
        watchDog.eventLog('Sch3. Bad data. No donut for you.');
    }

    callback(null,JSON.stringify(schedules[2]));
}

function setScheduler4(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setScheduler4');

    if((buf !== 0) && (buf.length == schedules[2].length)){

        fs.writeFileSync(__dirname+'/UserFiles/schedule4.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/schedule4Bkp.txt',query,'utf-8');
        schedules[3] = buf;

        watchDog.eventLog('Schedule4 modified');
        alphaconverter.initiate(0);
        updNxt=1;

    }
    else{
        watchDog.eventLog('Sch4. Bad data. No donut for you.');
    }


    callback(null,JSON.stringify(schedules[3]));
}

function setShows(query){

    query=decodeURIComponent(query);
    var buf=riskyParse(query,'setShows');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/shows.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/showsBkp.txt',query,'utf-8');
        shows = buf;

    }
}

function setPlaylists(callback,query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setPlaylists');
    var status=0;

    if(buf !== 0){

        var playlist = buf;
        watchDog.eventLog("Playlist[0] : " +playlist[0]);
        watchDog.eventLog("Playlist[1] : " +playlist[1]);
        status = alphaconverter.certify(playlist[0],playlist[1],playlist[2]);

        if(status === "OK"){

            watchDog.eventLog('SUCCESSFUL PLAYLIST MODIFICATION: '+query);
            alphaconverter.initiate(0);

            var nao = mainTime;
            nao = nao.getHours()*10000 + nao.getMinutes()*100 + nao.getSeconds();

            var future = alphaconverter.seer(nao,0);
            nxtShow=future[1];
            nxtTime=future[0];
            updNxt=0;
            future=null;
            nao=null;

        }

        manFocus = playlist[0];
    }

    status = (status !== 0) ? JSON.stringify(status):JSON.stringify([]);
    callback(null,status);
}

function setTimeTable(query){

    query = decodeURIComponent(query);
    var buf=riskyParse(query,'setTimetable');

    if(buf !== 0){

        //TODO: Try To Eliminate the Backup Files
        fs.writeFileSync(__dirname+'/UserFiles/timetable.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/timetableBkp.txt',query,'utf-8');

        timetable=buf;
        alphaconverter.initiate(0);

        var nao = mainTime;
        nao = nao.getHours()*10000 + nao.getMinutes()*100 + nao.getSeconds();

        var future = alphaconverter.seer(nao,0);
        nxtShow=future[1];
        nxtTime=future[0];
        updNxt=0;
        future=null;
        nao=null;
    }
}

function getLog(query,callback){

    fs.readFile(__dirname+'/UserFiles/logFile.txt','utf-8',function(err,data){

        if(err){
            throw err;
        }

        var dataString = data.toString();
        callback(null,dataString);
    
    });
}

function getLogClient(query,callback){
    fs.readFile(__dirname+'/UserFiles/systemLog.txt','utf-8',function(err,data){
        if(err){throw err;}
        var dataString = data.toString();
        callback(null,dataString);
        }
    );
}

function getWetNodeError(query,callback){

    fs.readFile('/etc/wetNode.error','utf-8',function(err,data){

        if(err){
            throw err;
        }

        var dataString = data.toString();
        callback(null,dataString);
    
    });
}

//==================== Load/Save Settings

//Save the settings to User Files

function saveSettings(parsedData){
    watchDog.eventLog('Server hit with path /saveSettings with query: ');
    //fs.writeFileSync(__dirname+'/UserFiles/'+ parsedData.screen +'.txt',parsedData.settings,'utf-8');
}

//This function loads the settings from User Filers

function loadSettings(callback, query){
    watchDog.eventLog('Server hit with path /loadSettings with query: ' +query);
    // fs.readFile(__dirname+'/UserFiles/'+ query +'.txt','utf-8',function(err,data){

    //     if(err){
    //         throw err;
    //     }
        
    //     var dataString = data.toString();
    //     callback(null,dataString);

    // });
}

//==================== Data Parser
//also used in BW code. Duplicate changes there too.
function riskyParse(text,what,bkp,xsafe){

    var lamb=0;

    try{

        //First we want to make sure there are no extra qiated inside the text while parsing
        text = elminiateExtraQoutes(what,text);
        lamb = JSON.parse(text);

    }catch(e){

        watchDog.eventLog(what + ':Server Read Successful');
        watchDog.eventLog("Caught this :" +JSON.stringify(e));

    }finally{

        //Check if extra file safety check is desired
        //TODO: Check what is this used for and f we can eliminate it

        if(xsafe){

            if(riskyParse(fs.readFileSync(__dirname+'/UserFiles/'+bkp+'.txt','utf-8'),'xsafe '+what) !== 0){
                //Parsing of Bkp file was successfule, do nothing

            }else if(lamb !== 0){
                fs.writeFileSync(__dirname+'/UserFiles/'+bkp+'.txt',text,'utf-8');

            }
        }

        //Check if parsing to back-up on initial failure is not desired

        if(!bkp || (bkp && lamb !== 0)){
            
            lamb = (lamb === null) ? 0 : lamb;
            return lamb;
        
        }
        else{
            watchDog.eventLog(what+" file recovered and parsed to bkp");
            lamb = fs.readFileSync(__dirname+'/UserFiles/'+bkp+'.txt','utf-8');
            fs.writeFileSync(__dirname+'/UserFiles/'+what+'.txt',lamb,'utf-8');
            return riskyParse(lamb,what);
        }
    }
}

//This function eliminates any extra single quation from a text

function elminiateExtraQoutes(fileName,text){

    if (fileName == "schedule1" || fileName == "schedule2" || fileName == "schedule3" || fileName == "schedule4" || fileName == "setBW"){
        
        text = text.replace("'", '');
        text = text.replace("'", '');

    }

    return text;
}

//==================== Show Scanner

function startShowScanner(){
   var ss = require(homeD+'/Includes/showScanner.js');
   ss();
   watchDog.eventLog('Scan Shows from SPM');  
}

//TODO: Try to eliminiate this function

function createBkps(arr){

    for(var k=0; k<arr.length; k++){

        var buf = riskyParse(fs.readFileSync(__dirname+'/UserFiles/'+arr[k]+'.txt','utf-8'),'createBkp'+arr[k]);

        if(buf !== 0){

            fs.writeFileSync(__dirname+'/UserFiles/'+arr[k]+'Bkp.txt',JSON.stringify(buf),'utf-8');
            arr[k]+=1;

        }else if(buf === 0){
            arr[k]+=0;
        }

    }

    return arr;
}

//==================== Logs

function logsToFTP(callback){

    var exec = require("child_process").exec;

    exec('/etc/logMaint.sh',function(error,stdout,stderr){
        callback(error,stdout,stderr);
    });

}

//==================== Wind Scaling

function setWindScalingData(query){

    query=decodeURIComponent(query);
    var buf=riskyParse(query,'setWindScalingData');

    if(buf !== 0){

        fs.writeFileSync(__dirname+'/UserFiles/windScalingData.txt',query,'utf-8');
        fs.writeFileSync(__dirname+'/UserFiles/windScalingDataBkp.txt',query,'utf-8');
        windScalingData = buf;

    }
}

//==================== Scheduled Interrupts

//Timer Trial
setTimeout(function(){

    setInterval(function(){
            triggerScripts();
            //watchDog.eventLog('Trigger Scripts');
    },200); 

},500);

//==================== Main Script Loader Indicator

var ldate = (moment.getMonth()+1)*100+moment.getDate();

watchDog.eventLog('----------------------------------------------- ' + proj.toUpperCase() + ' MAIN SCRIPT STARTED');
watchDog.eventLog('----------------------------------------------- DATE '+ldate);