function waterQualityWrapper(){

  //console.log("Water Quality script triggered");

  var date = new Date();
  var time = date.getFullYear() + "."+  ((date.getMonth() + 1) < 10 ? "0" :"") + (date.getMonth() + 1) + "." + (date.getDate() < 10 ? "0" : "") + date.getDate() + " " + (date.getHours() < 10 ? "0" : "") + date.getHours() + ":" + (date.getMinutes() < 10 ? "0" : "") + date.getMinutes() + ":" + (date.getSeconds() < 10 ? "0" : "") + date.getSeconds();

  var wq1PH;
  var wq1ORP;
  var wq1TDS;
  var wq1BR;

  var wq2PH;
  var wq2ORP;
  var wq2TDS;
  var wq2BR;

  // var api_key = 'f4908f6394b9437897cc3d37eb5175e5-87c34c41-8d22bcff';
  // var domain = 'mailgun.wetdesign.com';
  // var mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});

  if (PLCConnected){
    if ((date.getSeconds() === 1) || (date.getSeconds() === 11) || (date.getSeconds() === 21) || (date.getSeconds() === 31) || (date.getSeconds() === 41) || (date.getSeconds() === 51)) {
      plc_client.readHoldingRegister(300, 2, function(resp){

      wq1PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      plc_client.readHoldingRegister(310, 2, function(resp){
        wq1ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        plc_client.readHoldingRegister(320, 2, function(resp){
          wq1TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          plc_client.readCoils(328,1,function(resp){
            wq1BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (wq1_Live["ph"].length > 900) {
              wq1_Live["ph"].shift();
              wq1_Live["orp"].shift();
              wq1_Live["tds"].shift();
              wq1_Live["br"].shift();
              wq1_Live["date"].shift();
            }

            wq1_Live["ph"].push(wq1PH);
            wq1_Live["orp"].push(wq1ORP);
            wq1_Live["tds"].push(wq1TDS);
            wq1_Live["br"].push(wq1BR);
            wq1_Live["date"].push(time);

          }); 
        });
      });
    });

    plc_client.readHoldingRegister(340, 2, function(resp){

      wq2PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      plc_client.readHoldingRegister(350, 2, function(resp){
        wq2ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        plc_client.readHoldingRegister(360, 2, function(resp){
          wq2TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          plc_client.readCoils(368,1,function(resp){
            wq2BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (wq2_Live["ph"].length > 900) {
              wq2_Live["ph"].shift();
              wq2_Live["orp"].shift();
              wq2_Live["tds"].shift();
              wq2_Live["br"].shift();
              wq2_Live["date"].shift();
            }

            wq2_Live["ph"].push(wq2PH);
            wq2_Live["orp"].push(wq2ORP);
            wq2_Live["tds"].push(wq2TDS);
            wq2_Live["br"].push(wq2BR);
            wq2_Live["date"].push(time);

          }); 
        });
      });
    });

    plc_client.readHoldingRegister(380, 2, function(resp){

      wq3PH =  parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );
      
      plc_client.readHoldingRegister(390, 2, function(resp){
        wq3ORP = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

        plc_client.readHoldingRegister(400, 2, function(resp){
          wq3TDS = parseFloat( Number( parseFloat("" + back2Real(resp.register[0], resp.register[1]) + "").toFixed(1) ) );

          plc_client.readCoils(408,1,function(resp){
            wq3BR= (resp.coils[0]) ? 1 : 0;

            //"LIVE" data
            //sampling frequency is once every second
            //collect and display only 15 mins worth data
            if (wq3_Live["ph"].length > 900) {
              wq3_Live["ph"].shift();
              wq3_Live["orp"].shift();
              wq3_Live["tds"].shift();
              wq3_Live["br"].shift();
              wq3_Live["date"].shift();
            }

            wq3_Live["ph"].push(wq3PH);
            wq3_Live["orp"].push(wq3ORP);
            wq3_Live["tds"].push(wq3TDS);
            wq3_Live["br"].push(wq3BR);
            wq3_Live["date"].push(time);

          }); 
        });
      });
    });

    }
  } 

   // if (((date.getDate() === 1)||(date.getDate() === 4)||(date.getDate() === 7)||(date.getDate() === 10)||(date.getDate() === 13)||(date.getDate() === 16)||(date.getDate() === 19)||(date.getDate() === 22)||(date.getDate() === 25)||(date.getDate() === 28)) && (date.getHours() === 0) && (date.getMinutes() === 15) && (date.getSeconds() === 1) ){
        
   //      //const monthNames = ["December","January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November"];
   //      //const monthArray = ["January", "February", "March", "April", "May", "June","July", "August", "September", "October", "November", "December"];

   //      var message = "Please see the attached FireShow Logs";
   //      var category = "Fire Show Log Data";
   //      var text = "FireShow Log Maintanance";
   //      var timeStamp = (date.getFullYear() 
   //                      + '-' + (date.getMonth()+1)) 
   //                      + '-' + date.getDate() 
   //                      + ' ' + date.getHours() 
   //                      + ':' + (date.getMinutes()<10?'0':'') + date.getMinutes() 
   //                      + ':' + (date.getSeconds()<10?'0':'') + date.getSeconds();

   //      const path = require('path');
   //      var filepath = path.join(__dirname,'UserFiles','logFile.csv');

   //      var data = {
   //        from:  'Feature Alert <noreply@mailgun.wetdesign.com>',
   //        to: 'ex20@mailgun.wetdesign.com',
   //        bcc: 'featurealert@wetdesign.com',
   //        //to: 'rakesh.raveendra@wetdesign.com',
   //        subject: 'WET Event Alert for : EX20, Server Alert: ' +category,
   //        //text: ' Event :' +text+ ' Time :' +timeStamp+ ''+reason+ '' +message,
   //        html: '<html><body><dl><dt> Event : '+text+' </dt><br><dt> Time : '+timeStamp+'  </dt><br><dt>'+message+' </dt><br><br><dt>Thanks</dt><dt>WET</dt></dl></body></html>',
   //        attachment: filepath
   //      };
         
   //      mailgun.messages().send(data, function (error, body) {
   //          console.log(body);
   //          fs.writeFileSync(homeD+'/UserFiles/logFile.csv','EX20 :: FIRE SHOW LOG DATA','utf-8');
   //          fs.appendFileSync(homeD+'/UserFiles/logFile.csv','\n','utf-8');
   //      });
   //  }

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

function avg1min(totalArray){

  //watchDog.eventLog("totalArray: " +totalArray);
  //watchDog.eventLog("Array Length: " +totalArray.length);
  
  var avg = 0;
  if (totalArray.length > 60){
    for (var i=0; i <= 60 ; i++){
      avg += totalArray[i];
    }
    avg = avg/60;
  }
  else{
    for (var i=0; i <= (totalArray.length-1) ; i++){
      avg += totalArray[i];
    }
    avg = avg/(totalArray.length-1);
  }
  return avg;
}

}

module.exports=waterQualityWrapper;