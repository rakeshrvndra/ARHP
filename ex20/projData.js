    
    function projData()
    {

    }


    function sendPacketToProjectors(command,prjID)
    {

        var cmd = " ";
        var projectorIP = " ";

        switch (prjID){
            case 1: projectorIP = "10.0.6.201";
                    break;
            case 2: projectorIP = "10.0.6.202";
                    break;
            case 3: projectorIP = "10.0.6.203";
                    break;
            case 4: projectorIP = "10.0.6.204";
                    break;
            case 5: projectorIP = "10.0.6.205";
                    break;
            case 6: projectorIP = "10.0.6.206";
                    break;
            case 7: projectorIP = "10.0.6.207";
                    break;
            case 8: projectorIP = "10.0.6.208";
                    break;
            case 9: projectorIP = "10.0.6.209";
                    break;
            case 10: projectorIP = "10.0.6.210";
                    break;
            case 11: projectorIP = "10.0.6.211";
                    break;
            case 12: projectorIP = "10.0.6.212";
                    break;
            case 13: projectorIP = "10.0.6.213";
                    break;
            case 14: projectorIP = "10.0.6.214";
                    break;
            case 15: projectorIP = "10.0.6.215";
                    break;
            case 16: projectorIP = "10.0.6.216";
                    break;
            case 17: projectorIP = "10.0.6.217";
                    break;
            case 18: projectorIP = "10.0.6.218";
                    break;
            case 19: projectorIP = "10.0.6.219";
                    break;
            case 20: projectorIP = "10.0.6.220";
                    break;
            case 21: projectorIP = "10.0.6.221";
                    break;
            default:
                watchDog.eventLog("Cmd Not Found");
        }

        var prjClient = getConn(projectorIP,prjID,command);

        switch (command){
            case 1: cmd = "(PWR?)";break;  //power status
            case 2: cmd = "(PWR 1)";break; //power on
            case 3: cmd = "(PWR 0)";break; //power off
            case 4: cmd = "(SHU?)";break;  //shutter status
            case 5: cmd = "(SHU 0)";break; //shutter on
            case 6: cmd = "(SHU 1)";break; //shutter off
            case 7: cmd = "(SST+TEMP?2)";break; //temperature status
            default:
                watchDog.eventLog("Cmd Not Found");
        }
        //watchDog.eventLog("Executing command  ::  "+cmd+ "    on Projector ID  ::  "+prjID);
        prjClient.write(cmd);
        prjClient.end();
    }

    function getConn(hostIP,prjID,command)
    {

        var net = require('net');
        var moment = new Date();
        var zerosInFront;
        if ((moment.getMilliseconds() >= 10) && (moment.getMilliseconds() < 100)){
            zerosInFront = '0';
        }
        else if ((moment.getMilliseconds() >= 0) && (moment.getMilliseconds() < 10)){
            zerosInFront = '00';
        }
        else{
            zerosInFront = '';
        }
        var timeStamp = (moment.getFullYear() 
                    + '-' + (moment.getMonth()+1)) 
                    + '-' + moment.getDate() 
                    + ' ' + moment.getHours() 
                    + ':' + (moment.getMinutes()<10?'0':'') + moment.getMinutes() 
                    + ':' + (moment.getSeconds()<10?'0':'') + moment.getSeconds()
                    + ':'+ zerosInFront + moment.getMilliseconds();
        
        const ip = hostIP

        var option = 
        {
            host: ip,
            port: 3002
        }
        
        // Create TCP client.
        var client = net.createConnection(option, function () 
        {
            // console.log("Connection local address : " + client.localAddress + ":" + client.localPort);
            // console.log("Connection remote address : " + client.remoteAddress + ":" + client.remotePort);
        });

        client.on('data', function (data)
        {
            
            switch (command){
                case 1: 
                case 2:
                case 3:
                case 4:
                case 5:
                case 6: watchDog.eventLog("Server return data : " + data);
                        break;
                case 7: data+=" Projector:: ";
                        data+=prjID;
                        data+="  IP:: ";
                        data+=hostIP;
                        data+='\n';
                        console.log("Server return data : " + data + "from IP: " + client.remoteAddress);
                        const projStr = data;
                        const temp1 = projStr.split("000 ");
                        var temp2 = temp1[1].split(/[Â°C]/);
                        var result = temp2[0].replace( /^\D+/g, ''); 
                        prj["date"] = timeStamp;
                        //watchDog.eventLog("prj[date]   :: " +prj["date"]);
                        switch (prjID){
                            case 1: 
                            case 2: 
                            case 3:
                            case 4:
                            case 5:
                            case 6:
                            case 7:
                            case 8:
                            case 9:
                            case 10:
                            case 11: 
                            case 12: 
                            case 13:
                            case 14:
                            case 15:
                            case 16:
                            case 17:
                            case 18:
                            case 19:
                            case 20:
                            case 21: prj.temp[prjID-1] = result;
                                     //watchDog.eventLog("prj.temp[prjID-1] "+prj.temp[prjID-1]);
                                     if (result>29){
                                        watchDog.eventLog("WARNING::: Projector ::: "+prjID+ "     Reading Temperature::   "+parseInt(result)+ "°C");
                                        if (result>35){
                                            watchDog.eventLog("CRITICAL ALARM::: Projector ::: "+prjID+ "     Reading Temperature::   "+parseInt(result)+ "°C");
                                        }
                                     }
                                    break;
                            default:
                                watchDog.eventLog("Cmd Not Found");
                        }
                        //watchDog.eventLog("Server return data : " + data + "from IP: " +hostIP);
                        fs.appendFile(homeD+'/UserFiles/projData.txt',' '+timeStamp+' @ '+data,function(err){
                            if(err){throw err;}
                        });
                        break;
            default:
                watchDog.eventLog("Cmd Not Found");
            }
        });

        // When connection disconnected.
        client.on('end',function () 
        {
            //watchDog.eventLog("Client socket disconnect. ");
            console.log("Client socket disconnect. ");
            client.end();
            client.destroy();
        });

        client.on('timeout', function () 
        {
            //watchDog.eventLog("Client connection timeout. ");
        });

        client.on('error', function (err) 
        {
             console.log(err);
            //watchDog.eventLog(JSON.stringify(err));
        });

        return client;
    }

module.exports=projData;
module.exports.sendPacketToProjectors = sendPacketToProjectors;