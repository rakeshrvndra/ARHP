//
//  FogViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//


import UIKit


class HCPViewController: UIViewController{
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrLbl: UILabel!
    @IBOutlet weak var pt1Lbl: UILabel!
    
    private var httpComm = HTTPComm()
    private let logger = Logger()
    private var centralSystem = CentralSystem()
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
    }

    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        readSaltFillStats()
         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func checkSystemStat(){
            
            let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
            
            if plcConnection == CONNECTION_STATE_CONNECTED{
                
                //Change the connection stat indicator
                noConnectionView.alpha = 0
                readHCPStatus()
                readSaltFillStats()
                noConnectionView.isUserInteractionEnabled = false
                //Check if the pumps or on auto mode or hand mode
                
                logger.logData(data: "PUMP: CONNECTION SUCCESS")
                
            }  else {
                noConnectionView.alpha = 1
                if plcConnection == CONNECTION_STATE_FAILED {
                    noConnectionErrLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTING {
                    noConnectionErrLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                    noConnectionErrLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
                }
            }
            
        }
    
    func readHCPStatus (){
            let sysReady = self.view.viewWithTag(13) as? UIImageView
            let sysFill = self.view.viewWithTag(14) as? UIImageView
            let sysPurge = self.view.viewWithTag(15) as? UIImageView
            let sysOff = self.view.viewWithTag(16) as? UIImageView
            let sysVent = self.view.viewWithTag(17) as? UIImageView
            let estop = self.view.viewWithTag(18) as? UIImageView
            let lel1 = self.view.viewWithTag(19) as? UIImageView
            let lel2 = self.view.viewWithTag(20) as? UIImageView
            let lel3 = self.view.viewWithTag(21) as? UIImageView
            let o2 = self.view.viewWithTag(22) as? UIImageView
            let tt1 = self.view.viewWithTag(23) as? UIImageView
            let tt2 = self.view.viewWithTag(24) as? UIImageView
            let pt1 = self.view.viewWithTag(25) as? UIImageView
        
            let kv1 = self.view.viewWithTag(26) as? UIImageView
            let kv2 = self.view.viewWithTag(27) as? UIImageView
            let kv3 = self.view.viewWithTag(28) as? UIImageView
            let kv4 = self.view.viewWithTag(29) as? UIImageView
            let kv5 = self.view.viewWithTag(30) as? UIImageView
            
            CENTRAL_SYSTEM!.readRegister(length: 1, startingRegister: Int32(HCP_SYSSTATUS), completion:{ (success, response) in
                
                guard success == true else { return }
                    
                let value = Int(truncating: response![0] as! NSNumber)
                let base_2_binary = String(value, radix: 2)
                let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
                let arr = Bit_16.map { String($0) }
                
                arr[15] == "1" ? ( sysReady?.image = #imageLiteral(resourceName: "green")) : (sysReady?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[14] == "1" ? ( sysFill?.image = #imageLiteral(resourceName: "green")) : (sysFill?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[13] == "1" ? ( sysPurge?.image = #imageLiteral(resourceName: "green")) : (sysPurge?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[12] == "1" ? ( sysOff?.image = #imageLiteral(resourceName: "green")) : (sysOff?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[11] == "1" ? ( sysVent?.image = #imageLiteral(resourceName: "green")) : (sysVent?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[9] == "1" ? ( estop?.image = #imageLiteral(resourceName: "red")) : (estop?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[8] == "1" ? ( lel1?.image = #imageLiteral(resourceName: "red")) : (lel1?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[7] == "1" ? ( lel2?.image = #imageLiteral(resourceName: "red")) : (lel2?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[6] == "1" ? ( lel3?.image = #imageLiteral(resourceName: "red")) : (lel3?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[5] == "1" ? ( o2?.image = #imageLiteral(resourceName: "red")) : (o2?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[4] == "1" ? ( tt1?.image = #imageLiteral(resourceName: "red")) : (tt1?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[3] == "1" ? ( tt2?.image = #imageLiteral(resourceName: "red")) : (tt2?.image = #imageLiteral(resourceName: "blank_icon_on"))
                arr[2] == "1" ? ( pt1?.image = #imageLiteral(resourceName: "red")) : (pt1?.image = #imageLiteral(resourceName: "blank_icon_on"))
                
            })
        CENTRAL_SYSTEM?.readBits(length: 5, startingRegister: Int32(HCP_VALVE1STATUS), completion: { (success, response) in
            
            guard success == true else { return }
            
            let v1 = Int(truncating: response![0] as! NSNumber)
            let v2 = Int(truncating: response![1] as! NSNumber)
            let v3 = Int(truncating: response![2] as! NSNumber)
            let v4 = Int(truncating: response![3] as! NSNumber)
            let v5 = Int(truncating: response![4] as! NSNumber)
            
            v1 == 1 ? ( kv1?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv1?.image = #imageLiteral(resourceName: "valve-white"))
            v2 == 1 ? ( kv2?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv2?.image = #imageLiteral(resourceName: "valve-white"))
            v3 == 1 ? ( kv3?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv3?.image = #imageLiteral(resourceName: "valve-white"))
            v4 == 1 ? ( kv4?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv4?.image = #imageLiteral(resourceName: "valve-white"))
            v5 == 1 ? ( kv5?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv5?.image = #imageLiteral(resourceName: "valve-white"))
        })
    }
    
    func pad(string : String, toSize: Int) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }
    
    func readSaltFillStats (){
            let pt1 = self.view.viewWithTag(12) as? UILabel
            let pt2 = self.view.viewWithTag(2) as? UILabel
            let pt3 = self.view.viewWithTag(3) as? UILabel
            let tt1 = self.view.viewWithTag(4) as? UILabel
            let tt2 = self.view.viewWithTag(5) as? UILabel
            
            let fpt1 = self.view.viewWithTag(6) as? UILabel
            let fpt2 = self.view.viewWithTag(7) as? UILabel
            let fpt3 = self.view.viewWithTag(8) as? UILabel
            let fpt4 = self.view.viewWithTag(9) as? UILabel
            let fpt5 = self.view.viewWithTag(10) as? UILabel
            let fpt6 = self.view.viewWithTag(11) as? UILabel
        
            let lel1 = self.view.viewWithTag(32) as? UILabel
            let o2 = self.view.viewWithTag(33) as? UILabel
        
            
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT1_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt1?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT2_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt2?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt3?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT1_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                tt1?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT2_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                tt2?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE1PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt1?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE2PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt2?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE3PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt3?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE4PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt4?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE5PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt5?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRE6PT3_SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                fpt6?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCP_LELSCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                lel1?.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(HCP_O2SCALEDVAL), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                o2?.text =  String(format: "%.1f", value)
            })
    }
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @IBAction func showAlerSettings(_ sender: UIButton) {
        self.addAlertAction(button: sender)
    }
    
}
