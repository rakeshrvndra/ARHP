function dmsWrapper(){

var jsModbus = require("./Includes/jsModbus"),
    util = require('util');


var readCoilRegHandler = function (centralId, firstCoil, numCoils) {
  // console.log('Read Req firstCoil ' + firstCoil + ' numCoils ' + numCoils + ' centralId ' + centralId);
  // return [coils.slice(firstCoil, numCoils)];
  console.log('Read Req firstCoil  ' + firstCoil + ' numCoils ' + numCoils + ' centralId ' + centralId);
  var resp = [];
  for (var i = firstCoil; i < firstCoil+numCoils; i += 1) {
     switch (i){
      //Test Data
      // case 1:
      //     resp[i-1] = true;
      //     console.log('1');
      //     break;
      // case 2:
      //     resp[i-1] = true;
      //     console.log('2');
      //     break;
      // case 3:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 4:
      //     resp[i-1] = true;
      //     console.log('1');
      //     break;
      // case 5:
      //     resp[i-1] = true;
      //     console.log('2');
      //     break;
      // case 6:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 7:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 8:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 9:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 10:
      //     resp[i-1] = true;
      //     console.log('1');
      //     break;
      // case 11:
      //     resp[i-1] = true;
      //     console.log('1');
      //     break;
      // case 12:
      //     resp[i-1] = true;
      //     console.log('2');
      //     break;
      // case 13:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;
      // case 14:
      //     resp[i-1] = true;
      //     console.log('1');
      //     break;
      // case 15:
      //     resp[i-1] = true;
      //     console.log('2');
      //     break;
      // case 16:
      //     resp[i-1] = true;
      //     console.log('3');
      //     break;


     // BMS Data (DTRS - Arise) 
         
      case 1:
          resp[i-1] = arisebmscoildata[0];
          console.log('arisebmscoildata[0] '+ arisebmscoildata[0] );
          break;
      case 2:
          resp[i-1] = arisebmscoildata[1];
          console.log('arisebmscoildata[1] '+ arisebmscoildata[1] );
          break;
      case 3:
          resp[i-1] = arisebmscoildata[2];
          console.log('arisebmscoildata[2] '+ arisebmscoildata[2] );
          break;
      case 4:
          resp[i-1] = arisebmscoildata[3];
          console.log('arisebmscoildata[3] '+ arisebmscoildata[3] );
          break;
      case 5:
          resp[i-1] = arisebmscoildata[4];
          console.log('arisebmscoildata[4] '+ arisebmscoildata[4] );
          break;
      case 6:
          resp[i-1] = arisebmscoildata[5];
          console.log('arisebmscoildata[5] '+ arisebmscoildata[5] );
          break;
      case 7:
          resp[i-1] = arisebmscoildata[6];
          console.log('arisebmscoildata[6] '+ arisebmscoildata[6] );
          break;
      case 8:
          resp[i-1] = arisebmscoildata[7];
          console.log('arisebmscoildata[7] '+ arisebmscoildata[7] );
          break;
      case 9:
          resp[i-1] = arisebmscoildata[8];
          console.log('arisebmscoildata[8] '+ arisebmscoildata[8] );
          break;
      case 10:
          resp[i-1] = arisebmscoildata[9];
          console.log('arisebmscoildata[9] '+ arisebmscoildata[9] );
          break;

      case 11:
          resp[i-1] = arisebmscoildata[10];
          console.log('arisebmscoildata[10] '+ arisebmscoildata[10] );
          break;
      case 12:
          resp[i-1] = arisebmscoildata[11];
          console.log('arisebmscoildata[11] '+ arisebmscoildata[11] );
          break;
      case 13:
          resp[i-1] = arisebmscoildata[12];
          console.log('arisebmscoildata[12] '+ arisebmscoildata[12] );
          break;
      case 14:
          resp[i-1] = arisebmscoildata[13];
          console.log('arisebmscoildata[13] '+ arisebmscoildata[13] );
          break;
      case 15:
          resp[i-1] = arisebmscoildata[14];
          console.log('arisebmscoildata[14] '+ arisebmscoildata[14] );
          break;
      case 16:
          resp[i-1] = arisebmscoildata[15];
          console.log('arisebmscoildata[15] '+ arisebmscoildata[15] );
          break;
      case 17:
          resp[i-1] = arisebmscoildata[16];
          console.log('arisebmscoildata[16] '+ arisebmscoildata[16] );
          break;
      case 18:
          resp[i-1] = arisebmscoildata[17];
          console.log('arisebmscoildata[17] '+ arisebmscoildata[17] );
          break;
      case 19:
          resp[i-1] = arisebmscoildata[18];
          console.log('arisebmscoildata[18] '+ arisebmscoildata[18] );
          break;
      case 20:
          resp[i-1] = arisebmscoildata[19];
          console.log('arisebmscoildata[19] '+ arisebmscoildata[19] );
          break;

      case 21:
          resp[i-1] = arisebmscoildata[20];
          console.log('arisebmscoildata[20] '+ arisebmscoildata[20] );
          break;
      case 22:
          resp[i-1] = arisebmscoildata[21];
          console.log('arisebmscoildata[21] '+ arisebmscoildata[21] );
          break;
      case 23:
          resp[i-1] = arisebmscoildata[22];
          console.log('arisebmscoildata[22] '+ arisebmscoildata[22] );
          break;
      case 24:
          resp[i-1] = arisebmscoildata[23];
          console.log('arisebmscoildata[23] '+ arisebmscoildata[23] );
          break;
      case 25:
          resp[i-1] = arisebmscoildata[24];
          console.log('arisebmscoildata[24] '+ arisebmscoildata[24] );
          break;
      case 26:
          resp[i-1] = arisebmscoildata[25];
          console.log('arisebmscoildata[25] '+ arisebmscoildata[25] );
          break;
      case 27:
          resp[i-1] = arisebmscoildata[26];
          console.log('arisebmscoildata[26] '+ arisebmscoildata[26] );
          break;
      case 28:
          resp[i-1] = arisebmscoildata[27];
          console.log('arisebmscoildata[27] '+ arisebmscoildata[27] );
          break;
      case 29:
          resp[i-1] = arisebmscoildata[28];
          console.log('arisebmscoildata[28] '+ arisebmscoildata[28] );
          break;
      case 30:
          resp[i-1] = arisebmscoildata[29];
          console.log('arisebmscoildata[29] '+ arisebmscoildata[29] );
          break;

      case 31:
          resp[i-1] = arisebmscoildata[30];
          console.log('arisebmscoildata[30] '+ arisebmscoildata[30] );
          break;
      case 32:
          resp[i-1] = arisebmscoildata[31];
          console.log('arisebmscoildata[31] '+ arisebmscoildata[31] );
          break;
      case 33:
          resp[i-1] = arisebmscoildata[32];
          console.log('arisebmscoildata[32] '+ arisebmscoildata[32] );
          break;
      case 34:
          resp[i-1] = arisebmscoildata[33];
          console.log('arisebmscoildata[33] '+ arisebmscoildata[33] );
          break;
      case 35:
          resp[i-1] = arisebmscoildata[34];
          console.log('arisebmscoildata[34] '+ arisebmscoildata[34] );
          break;
      case 36:
          resp[i-1] = arisebmscoildata[35];
          console.log('arisebmscoildata[35] '+ arisebmscoildata[35] );
          break;
      case 37:
          resp[i-1] = arisebmscoildata[36];
          console.log('arisebmscoildata[36] '+ arisebmscoildata[36] );
          break;
      case 38:
          resp[i-1] = arisebmscoildata[37];
          console.log('arisebmscoildata[37] '+ arisebmscoildata[37] );
          break;
      case 39:
          resp[i-1] = arisebmscoildata[38];
          console.log('arisebmscoildata[38] '+ arisebmscoildata[38] );
          break;
      case 40:
          resp[i-1] = arisebmscoildata[39];
          console.log('arisebmscoildata[39] '+ arisebmscoildata[39] );
          break;
     

     case 41:
          resp[i-1] = arisebmscoildata[40];
          console.log('arisebmscoildata[40] '+ arisebmscoildata[40] );
          break;
      case 42:
          resp[i-1] = arisebmscoildata[41];
          console.log('arisebmscoildata[41] '+ arisebmscoildata[41] );
          break;
      case 43:
          resp[i-1] = arisebmscoildata[42];
          console.log('arisebmscoildata[42] '+ arisebmscoildata[42] );
          break;
      case 44:
          resp[i-1] = arisebmscoildata[43];
          console.log('arisebmscoildata[43] '+ arisebmscoildata[43] );
          break;
      case 45:
          resp[i-1] = arisebmscoildata[44];
          console.log('arisebmscoildata[44] '+ arisebmscoildata[44] );
          break;
      case 46:
          resp[i-1] = arisebmscoildata[45];
          console.log('arisebmscoildata[45] '+ arisebmscoildata[45] );
          break;
      case 47:
          resp[i-1] = arisebmscoildata[46];
          console.log('arisebmscoildata[46] '+ arisebmscoildata[46] );
          break;
      case 48:
          resp[i-1] = arisebmscoildata[47];
          console.log('arisebmscoildata[47] '+ arisebmscoildata[47] );
          break;
      case 49:
          resp[i-1] = arisebmscoildata[48];
          console.log('arisebmscoildata[48] '+ arisebmscoildata[48] );
          break;
      case 50:
          resp[i-1] = arisebmscoildata[49];
          console.log('arisebmscoildata[49] '+ arisebmscoildata[49] );
          break;

      case 51:
          resp[i-1] = arisebmscoildata[50];
          console.log('arisebmscoildata[50] '+ arisebmscoildata[50] );
          break;
      case 52:
          resp[i-1] = arisebmscoildata[51];
          console.log('arisebmscoildata[51] '+ arisebmscoildata[51] );
          break;
      case 53:
          resp[i-1] = arisebmscoildata[52];
          console.log('arisebmscoildata[52] '+ arisebmscoildata[52] );
          break;
      case 54:
          resp[i-1] = arisebmscoildata[53];
          console.log('arisebmscoildata[53] '+ arisebmscoildata[53] );
          break;
      case 55:
          resp[i-1] = arisebmscoildata[54];
          console.log('arisebmscoildata[54] '+ arisebmscoildata[54] );
          break;
      case 56:
          resp[i-1] = arisebmscoildata[55];
          console.log('arisebmscoildata[55] '+ arisebmscoildata[55] );
          break;
      case 57:
          resp[i-1] = arisebmscoildata[56];
          console.log('arisebmscoildata[56] '+ arisebmscoildata[56] );
          break;
      case 58:
          resp[i-1] = arisebmscoildata[57];
          console.log('arisebmscoildata[57] '+ arisebmscoildata[57] );
          break;
      case 59:
          resp[i-1] = arisebmscoildata[58];
          console.log('arisebmscoildata[58] '+ arisebmscoildata[58] );
          break;
      case 60:
          resp[i-1] = arisebmscoildata[59];
          console.log('arisebmscoildata[59] '+ arisebmscoildata[59] );
          break;


      case 61:
          resp[i-1] = arisebmscoildata[60];
          console.log('arisebmscoildata[60] '+ arisebmscoildata[60] );
          break;
      case 62:
          resp[i-1] = arisebmscoildata[61];
          console.log('arisebmscoildata[61] '+ arisebmscoildata[61] );
          break;
      case 63:
          resp[i-1] = arisebmscoildata[62];
          console.log('arisebmscoildata[62] '+ arisebmscoildata[62] );
          break;
      case 64:
          resp[i-1] = arisebmscoildata[63];
          console.log('arisebmscoildata[63] '+ arisebmscoildata[63] );
          break;
      case 65:
          resp[i-1] = arisebmscoildata[64];
          console.log('arisebmscoildata[64] '+ arisebmscoildata[64] );
          break;
      case 66:
          resp[i-1] = arisebmscoildata[65];
          console.log('arisebmscoildata[65] '+ arisebmscoildata[65] );
          break;
      case 67:
          resp[i-1] = arisebmscoildata[66];
          console.log('arisebmscoildata[66] '+ arisebmscoildata[66] );
          break;
      case 68:
          resp[i-1] = arisebmscoildata[67];
          console.log('arisebmscoildata[67] '+ arisebmscoildata[67] );
          break;
      case 69:
          resp[i-1] = arisebmscoildata[68];
          console.log('arisebmscoildata[68] '+ arisebmscoildata[68] );
          break;
      case 70:
          resp[i-1] = arisebmscoildata[69];
          console.log('arisebmscoildata[69] '+ arisebmscoildata[69] );
          break;


      case 71:
          resp[i-1] = arisebmscoildata[70];
          console.log('arisebmscoildata[70] '+ arisebmscoildata[70] );
          break;
      case 72:
          resp[i-1] = arisebmscoildata[71];
          console.log('arisebmscoildata[71] '+ arisebmscoildata[71] );
          break;
      case 73:
          resp[i-1] = arisebmscoildata[72];
          console.log('arisebmscoildata[72] '+ arisebmscoildata[72] );
          break;
      case 74:
          resp[i-1] = arisebmscoildata[73];
          console.log('arisebmscoildata[73] '+ arisebmscoildata[73] );
          break;
      case 75:
          resp[i-1] = arisebmscoildata[74];
          console.log('arisebmscoildata[74] '+ arisebmscoildata[74] );
          break;
      case 76:
          resp[i-1] = arisebmscoildata[75];
          console.log('arisebmscoildata[75] '+ arisebmscoildata[75] );
          break;
      case 77:
          resp[i-1] = arisebmscoildata[76];
          console.log('arisebmscoildata[76] '+ arisebmscoildata[76] );
          break;
      case 78:
          resp[i-1] = arisebmscoildata[77];
          console.log('arisebmscoildata[77] '+ arisebmscoildata[77] );
          break;
      case 79:
          resp[i-1] = arisebmscoildata[78];
          console.log('arisebmscoildata[78] '+ arisebmscoildata[78] );
          break;
      case 80:
          resp[i-1] = arisebmscoildata[79];
          console.log('arisebmscoildata[79] '+ arisebmscoildata[79] );
          break;

      case 81:
          resp[i-1] = arisebmscoildata[80];
          console.log('arisebmscoildata[80] '+ arisebmscoildata[80] );
          break;
      case 82:
          resp[i-1] = arisebmscoildata[81];
          console.log('arisebmscoildata[81] '+ arisebmscoildata[81] );
          break;
      case 83:
          resp[i-1] = arisebmscoildata[82];
          console.log('arisebmscoildata[82] '+ arisebmscoildata[82] );
          break;
      case 84:
          resp[i-1] = arisebmscoildata[83];
          console.log('arisebmscoildata[83] '+ arisebmscoildata[83] );
          break;
      case 85:
          resp[i-1] = arisebmscoildata[84];
          console.log('arisebmscoildata[84] '+ arisebmscoildata[84] );
          break;
      case 86:
          resp[i-1] = arisebmscoildata[85];
          console.log('arisebmscoildata[85] '+ arisebmscoildata[85] );
          break;
      case 87:
          resp[i-1] = arisebmscoildata[86];
          console.log('arisebmscoildata[86] '+ arisebmscoildata[86] );
          break;
      case 88:
          resp[i-1] = arisebmscoildata[87];
          console.log('arisebmscoildata[87] '+ arisebmscoildata[87] );
          break;

     }
  }

  return [resp];
}

jsModbus.createTCPServer(502, '10.44.0.160', function (err, server) {
				
    if (err) {
        console.log(err);
        return;
    } else {
    	console.log(`Server started on`, +server);
    }
    
    server.addHandler(1, readCoilRegHandler);
});

}
module.exports=dmsWrapper;