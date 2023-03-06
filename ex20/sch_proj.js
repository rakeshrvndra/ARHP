function projSchWrapper(){

    //console.log("Cascade Pump Schedule script triggered");

    var moment = new Date();
    var current_day = moment.getDay();      //0-6
    var current_hour = moment.getHours();   //0-23
    var current_min = moment.getMinutes();  //0-59
    var current_time = (current_hour*100)+current_min;
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

    var projSchData = projSch;
    var on_time = projSchData[(3*day_ID)+1];
    var off_time = projSchData[(3*day_ID)+2];

    if ((current_time > 600)&&(off_time <= 600)){
        off_time = 2400;
    }
    else if ((current_time <= 600)&&(off_time <=600)){
        if (on_time >= 600){
            on_time = 0;
        }
    }
    else{
        //So nothing
    }

    if ((current_time >= on_time)&&(current_time < off_time)){
        //watchDog.eventLog('sch onn');
        //turn ON
        plc_client.readCoils(8005,1,function(resp){
            if(resp.coils[0]==0){
                if ((sendOnce==1) && (cmdFlag==0)){
                   sendOnce=0;
                   sendMirrorUp();
                }
            }    
        });
    }
    else{
        // watchDog.eventLog('sch off');
        //turn OFF
        plc_client.readCoils(8005,1,function(resp){
            if(resp.coils[0]==0){
                if ((sendOnce==1) && (cmdFlag==0)){
                   sendOnce=1;
                   sendMirrorDown();
                }
            }    
        });
    }
}

function sendMirrorDown(){
    cmdFlag=1;
    watchDog.eventLog('Wall1 --> Executed 1st Cmd: PRJ-301');
    projCmd(15,"10.0.6.129",0);
    setTimeout(function(){
        watchDog.eventLog('Wall1 --> Executed 2nd Cmd: PRJ-302');
        projCmd(16,"10.0.6.131",0);
        setTimeout(function(){
            watchDog.eventLog('Wall1 --> Executed 3rd Cmd: PRJ-303');
            projCmd(17,"10.0.6.133",0);
            setTimeout(function(){
                watchDog.eventLog('Wall1 --> Executed 4th Cmd: PRJ-304');
                projCmd(18,"10.0.6.135",0);
                setTimeout(function(){
                    watchDog.eventLog('Wall1 --> Executed 5th Cmd: PRJ-205');
                    projCmd(12,"10.0.6.123",0);
                    setTimeout(function(){
                        watchDog.eventLog('Wall1 --> Executed 6th Cmd: PRJ-206');
                        projCmd(13,"10.0.6.125",0);
                        setTimeout(function(){
                            watchDog.eventLog('Wall1 --> Executed 7th Cmd: PRJ-207');
                            projCmd(14,"10.0.6.127",0);
                            setTimeout(function(){
                                watchDog.eventLog('Wall2 --> Executed 1st Cmd: PRJ-101');
                                projCmd(1,"10.0.6.101",0);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall2 --> Executed 2nd Cmd: PRJ-102');
                                    projCmd(2,"10.0.6.103",0);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall2 --> Executed 3rd Cmd: PRJ-103');
                                        projCmd(3,"10.0.6.105",0);
                                        setTimeout(function(){
                                            watchDog.eventLog('Wall2 --> Executed 4th Cmd: PRJ-104');
                                            projCmd(4,"10.0.6.107",0);
                                            setTimeout(function(){
                                                watchDog.eventLog('Wall2 --> Executed 5th Cmd: PRJ-305');
                                                projCmd(19,"10.0.6.137",0);
                                                setTimeout(function(){
                                                    watchDog.eventLog('Wall2 --> Executed 6th Cmd: PRJ-306');
                                                    projCmd(20,"10.0.6.139",0);
                                                    setTimeout(function(){
                                                        watchDog.eventLog('Wall2 --> Executed 7th Cmd: PRJ-307');
                                                        projCmd(21,"10.0.6.141",0);
                                                        setTimeout(function(){
                                                           watchDog.eventLog('Wall3 --> Executed 1st Cmd: PRJ-201');
                                                           projCmd(8,"10.0.6.115",0);
                                                           setTimeout(function(){
                                                                watchDog.eventLog('Wall3 --> Executed 2nd Cmd: PRJ-202');
                                                                projCmd(9,"10.0.6.117",0);
                                                                setTimeout(function(){
                                                                    watchDog.eventLog('Wall3 --> Executed 3rd Cmd: PRJ-203');
                                                                    projCmd(10,"10.0.6.119",0);
                                                                    setTimeout(function(){
                                                                        watchDog.eventLog('Wall3 --> Executed 4th Cmd: PRJ-204');
                                                                        projCmd(11,"10.0.6.121",0);
                                                                        setTimeout(function(){
                                                                            watchDog.eventLog('Wall3 --> Executed 5th Cmd: PRJ-105');
                                                                            projCmd(5,"10.0.6.109",0);
                                                                            setTimeout(function(){
                                                                                watchDog.eventLog('Wall3 --> Executed 6th Cmd: PRJ-106');
                                                                                projCmd(6,"10.0.6.111",0);
                                                                                setTimeout(function(){
                                                                                    watchDog.eventLog('Wall3 --> Executed 7th Cmd: PRJ-107');
                                                                                    projCmd(7,"10.0.6.113",0);
                                                                                    cmdFlag=0;
                                                                                },75000);
                                                                            },75000);
                                                                        },75000);
                                                                    },75000);
                                                                },75000);
                                                            },75000);  
                                                        },75000);
                                                    },75000);
                                                },75000);
                                            },75000);
                                        },75000);
                                    },75000);
                                },75000);  
                            },75000);
                        },75000);
                    },75000);
                },75000);
            },75000);
        },75000);
    },75000);  
}


function sendMirrorUp(){
    cmdFlag=1;
    watchDog.eventLog('Wall1 --> Executed 1st Cmd: PRJ-301');
    projCmd(15,"10.0.6.129",1);
    setTimeout(function(){
        watchDog.eventLog('Wall1 --> Executed 2nd Cmd: PRJ-302');
        projCmd(16,"10.0.6.131",1);
        setTimeout(function(){
            watchDog.eventLog('Wall1 --> Executed 3rd Cmd: PRJ-303');
            projCmd(17,"10.0.6.133",1);
            setTimeout(function(){
                watchDog.eventLog('Wall1 --> Executed 4th Cmd: PRJ-304');
                projCmd(18,"10.0.6.135",1);
                setTimeout(function(){
                    watchDog.eventLog('Wall1 --> Executed 5th Cmd: PRJ-205');
                    projCmd(12,"10.0.6.123",1);
                    setTimeout(function(){
                        watchDog.eventLog('Wall1 --> Executed 6th Cmd: PRJ-206');
                        projCmd(13,"10.0.6.125",1);
                        setTimeout(function(){
                            watchDog.eventLog('Wall1 --> Executed 7th Cmd: PRJ-207');
                            projCmd(14,"10.0.6.127",1);
                            setTimeout(function(){
                                watchDog.eventLog('Wall2 --> Executed 1st Cmd: PRJ-101');
                                projCmd(1,"10.0.6.101",1);
                                setTimeout(function(){
                                    watchDog.eventLog('Wall2 --> Executed 2nd Cmd: PRJ-102');
                                    projCmd(2,"10.0.6.103",1);
                                    setTimeout(function(){
                                        watchDog.eventLog('Wall2 --> Executed 3rd Cmd: PRJ-103');
                                        projCmd(3,"10.0.6.105",1);
                                        setTimeout(function(){
                                            watchDog.eventLog('Wall2 --> Executed 4th Cmd: PRJ-104');
                                            projCmd(4,"10.0.6.107",1);
                                            setTimeout(function(){
                                                watchDog.eventLog('Wall2 --> Executed 5th Cmd: PRJ-305');
                                                projCmd(19,"10.0.6.137",1);
                                                setTimeout(function(){
                                                    watchDog.eventLog('Wall2 --> Executed 6th Cmd: PRJ-306');
                                                    projCmd(20,"10.0.6.139",1);
                                                    setTimeout(function(){
                                                        watchDog.eventLog('Wall2 --> Executed 7th Cmd: PRJ-307');
                                                        projCmd(21,"10.0.6.141",1);
                                                        setTimeout(function(){
                                                           watchDog.eventLog('Wall3 --> Executed 1st Cmd: PRJ-201');
                                                           projCmd(8,"10.0.6.115",1);
                                                           setTimeout(function(){
                                                                watchDog.eventLog('Wall3 --> Executed 2nd Cmd: PRJ-202');
                                                                projCmd(9,"10.0.6.117",1);
                                                                setTimeout(function(){
                                                                    watchDog.eventLog('Wall3 --> Executed 3rd Cmd: PRJ-203');
                                                                    projCmd(10,"10.0.6.119",1);
                                                                    setTimeout(function(){
                                                                        watchDog.eventLog('Wall3 --> Executed 4th Cmd: PRJ-204');
                                                                        projCmd(11,"10.0.6.121",1);
                                                                        setTimeout(function(){
                                                                            watchDog.eventLog('Wall3 --> Executed 5th Cmd: PRJ-105');
                                                                            projCmd(5,"10.0.6.109",1);
                                                                            setTimeout(function(){
                                                                                watchDog.eventLog('Wall3 --> Executed 6th Cmd: PRJ-106');
                                                                                projCmd(6,"10.0.6.111",1);
                                                                                setTimeout(function(){
                                                                                    watchDog.eventLog('Wall3 --> Executed 7th Cmd: PRJ-107');
                                                                                    projCmd(7,"10.0.6.113",1);
                                                                                    cmdFlag=0;
                                                                                },75000);
                                                                            },75000);
                                                                        },75000);
                                                                    },75000);
                                                                },75000);
                                                            },75000);  
                                                        },75000);
                                                    },75000);
                                                },75000);
                                            },75000);
                                        },75000);
                                    },75000);
                                },75000);  
                            },75000);
                        },75000);
                    },75000);
                },75000);
            },75000);
        },75000);
    },75000);  
}

// function sendMirrorDown(){
//     cmdFlag=1;
//     watchDog.eventLog('Wall1 --> Executed 1st Cmd: PRJ-301');
//     projCmd(15,"10.0.6.236",1);
//     setTimeout(function(){
//         watchDog.eventLog('Wall1 --> Executed 2nd Cmd: PRJ-302');
//         projCmd(16,"10.0.4.236",0);
//         setTimeout(function(){
//             watchDog.eventLog('Wall1 --> Executed 3rd Cmd: PRJ-303');
//             projCmd(17,"10.0.4.236",1);
//             setTimeout(function(){
//                 watchDog.eventLog('Wall1 --> Executed 4th Cmd: PRJ-304');
//                 projCmd(18,"10.0.4.236",0);
//                 setTimeout(function(){
//                     watchDog.eventLog('Wall1 --> Executed 5th Cmd: PRJ-205');
//                     projCmd(12,"10.0.4.236",1);
//                     setTimeout(function(){
//                         watchDog.eventLog('Wall1 --> Executed 6th Cmd: PRJ-206');
//                         projCmd(13,"10.0.4.236",0);
//                         setTimeout(function(){
//                             watchDog.eventLog('Wall1 --> Executed 7th Cmd: PRJ-207');
//                             projCmd(14,"10.0.4.236",1);
//                             setTimeout(function(){
//                                 watchDog.eventLog('Wall2 --> Executed 1st Cmd: PRJ-101');
//                                 projCmd(1,"10.0.4.236",0);
//                                 setTimeout(function(){
//                                     watchDog.eventLog('Wall2 --> Executed 2nd Cmd: PRJ-102');
//                                     projCmd(2,"10.0.4.236",1);
//                                     setTimeout(function(){
//                                         watchDog.eventLog('Wall2 --> Executed 3rd Cmd: PRJ-103');
//                                         projCmd(3,"10.0.4.236",0);
//                                         setTimeout(function(){
//                                             watchDog.eventLog('Wall2 --> Executed 4th Cmd: PRJ-104');
//                                             projCmd(4,"10.0.4.236",1);
//                                             setTimeout(function(){
//                                                 watchDog.eventLog('Wall2 --> Executed 5th Cmd: PRJ-305');
//                                                 projCmd(19,"10.0.4.236",0);
//                                                 setTimeout(function(){
//                                                     watchDog.eventLog('Wall2 --> Executed 6th Cmd: PRJ-306');
//                                                     projCmd(20,"10.0.4.236",1);
//                                                     setTimeout(function(){
//                                                         watchDog.eventLog('Wall2 --> Executed 7th Cmd: PRJ-307');
//                                                         projCmd(21,"10.0.4.236",0);
//                                                         setTimeout(function(){
//                                                             watchDog.eventLog('Wall3 --> Executed 1st Cmd: PRJ-201');
//                                                             projCmd(8,"10.0.4.236",1);
//                                                             setTimeout(function(){
//                                                                 watchDog.eventLog('Wall3 --> Executed 2nd Cmd: PRJ-202');
//                                                                 projCmd(9,"10.0.4.236",0);
//                                                                 setTimeout(function(){
//                                                                     watchDog.eventLog('Wall3 --> Executed 3rd Cmd: PRJ-203');
//                                                                     projCmd(10,"10.0.4.236",1);
//                                                                     setTimeout(function(){
//                                                                         watchDog.eventLog('Wall3 --> Executed 4th Cmd: PRJ-204');
//                                                                         projCmd(11,"10.0.4.236",0);
//                                                                         setTimeout(function(){
//                                                                             watchDog.eventLog('Wall3 --> Executed 5th Cmd: PRJ-105');
//                                                                             projCmd(5,"10.0.4.236",1);
//                                                                             setTimeout(function(){
//                                                                                 watchDog.eventLog('Wall3 --> Executed 6th Cmd: PRJ-106');
//                                                                                 projCmd(6,"10.0.4.236",0);
//                                                                                 setTimeout(function(){
//                                                                                     watchDog.eventLog('Wall3 --> Executed 7th Cmd: PRJ-107');
//                                                                                     projCmd(7,"10.0.4.236",1);
//                                                                                     cmdFlag=0;
//                                                                                 },75000);
//                                                                             },75000); 
//                                                                         },75000);
//                                                                     },75000);
//                                                                 },75000);
//                                                             },75000);
//                                                         },75000);
//                                                     },75000);
//                                                 },75000);
//                                             },75000);
//                                         },75000);
//                                     },75000);
//                                 },75000);  
//                             },75000);
//                         },75000);
//                     },75000);
//                 },75000);
//             },75000);
//         },75000);
//     },75000);  
// }


module.exports = projSchWrapper;