function saltSchWrapper(){

    //console.log("Filter Pump Schedule script triggered");

    var moment = new Date();
    var current_day = moment.getDay();      //0-6
    var current_hour = moment.getHours();   //0-23
    var current_min = moment.getMinutes();  //0-59
    var current_time = (current_hour*100)+current_min;
    var secondNow = moment.getSeconds();
    var day_ID = 0;

    //6am + 1
    if (current_hour >= (6+1)){

        day_ID = current_day;
    
    }else{
        
        day_ID = current_day - 1;

        if (day_ID < 0){
            day_ID = 6;
        }
        
    }

    var eodtime = purgeData.eodschTime;
    var bodtime = purgeData.bodschTime;

    // watchDog.eventLog('secondNow '+secondNow);
    // watchDog.eventLog('eodtime '+eodtime);
    // watchDog.eventLog('current_time '+current_time);
    // watchDog.eventLog('bodtime '+bodtime);

    // if ((current_time == eodtime) && (secondNow < 3)){
    //     if (purgeData.canPurgeSeqRun == 1){
    //         watchDog.eventLog("Show Running: Unable to send Salt Cleaning Sch To PLC");
    //     } else {
    //         plc_client.writeSingleCoil(5230,1,function(resp){});
    //         watchDog.eventLog("EOD PurgeSch Cmd Sent to PLC");
    //     }
         
    // }
    // if ((current_time == eodtime)&& (secondNow > 3)){
    //      plc_client.writeSingleCoil(5230,0,function(resp){});
    // }

    // if ((current_time == bodtime)&& (secondNow < 3)){
    //     if (purgeData.canPurgeSeqRun == 1){
    //         watchDog.eventLog("Show Running: Unable to send Salt Priming Sch To PLC");
    //     } else {
    //        plc_client.writeSingleCoil(5231,1,function(resp){});
    //        watchDog.eventLog("BOD PurgeSch Cmd Sent to PLC ");
    //     }
    // }
    // if ((current_time == bodtime)&& (secondNow > 3)){
    //      plc_client.writeSingleCoil(5231,0,function(resp){});
    // }
    
}

module.exports = saltSchWrapper;