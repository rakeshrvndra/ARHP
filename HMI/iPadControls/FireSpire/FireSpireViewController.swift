//
//  FireSpireViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/20/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class FireSpireViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrLbl: UILabel!
    @IBOutlet weak var checkFaultsBtn: UIButton!
    
    @IBOutlet weak var fireDisbSwitch: UISwitch!
    @IBOutlet weak var fireDisbLbl: UILabel!
    @IBOutlet weak var abortBtn: UIButton!
    @IBOutlet weak var handCmdSwitch: UISwitch!
    @IBOutlet weak var pt2Name: UILabel!
    @IBOutlet weak var pt3Name: UILabel!
    @IBOutlet weak var pt4Name: UILabel!
    @IBOutlet weak var kv17Name: UILabel!
    
    @IBOutlet weak var yv1Name: UILabel!
    @IBOutlet weak var kv1Name: UILabel!
    @IBOutlet weak var kv4Name: UILabel!
    @IBOutlet weak var kv7Name: UILabel!
    @IBOutlet weak var kv8Name: UILabel!
    @IBOutlet weak var kv9Name: UILabel!
    @IBOutlet weak var kv10Name: UILabel!
    @IBOutlet weak var kv11Name: UILabel!
    @IBOutlet weak var kv12Name: UILabel!
    @IBOutlet weak var kv13Name: UILabel!
    @IBOutlet weak var kv14Name: UILabel!
    @IBOutlet weak var kv15Name: UILabel!
    @IBOutlet weak var kv16Name: UILabel!
    private var centralSystem = CentralSystem()
    var fireNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
            switch fireNumber {
            case 1...6: self.pt2Name.text = "PT\(fireNumber)102"
                        self.pt3Name.text = "PT\(fireNumber)103"
                        self.pt4Name.text = "PT\(fireNumber)104"
                        self.yv1Name.text = "YV\(fireNumber)101"
                        self.kv1Name.text = "KV\(fireNumber)101"
                        self.kv4Name.text = "KV\(fireNumber)104"
                        self.kv7Name.text = "KV\(fireNumber)107"
                        self.kv8Name.text = "KV\(fireNumber)108"
                        self.kv9Name.text = "KV\(fireNumber)109"
                        self.kv10Name.text = "KV\(fireNumber)110"
                        self.kv11Name.text = "KV\(fireNumber)111"
                        self.kv12Name.text = "KV\(fireNumber)112"
                        self.kv13Name.text = "KV\(fireNumber)113"
                        self.kv14Name.text = "KV\(fireNumber)114"
                        self.kv15Name.text = "KV\(fireNumber)115"
                        self.kv16Name.text = "KV\(fireNumber)116"
                        self.kv17Name.text = "KV\(fireNumber)117"
                        self.fireDisbLbl.text = "DISABLE FIRE ZS-40\(fireNumber)"
                        self.navigationItem.title = "ZS - 40\(fireNumber) FIRE SPIRE"
            default:
                print("Wrong Tag: FireStat")
            }
            readFireStats()
        }
        
        
        @objc func checkSystemStat(){
            let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
            
            if plcConnection == CONNECTION_STATE_CONNECTED{
                
                //Change the connection stat indicator
                noConnectionView.alpha = 0
                readFireStats()
                noConnectionView.isUserInteractionEnabled = false
                
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
    
    func readFireStats(){
        let offset = (fireNumber - 1)*60
        let pt2 = self.view.viewWithTag(2) as? UILabel
        let pt3 = self.view.viewWithTag(3) as? UILabel
        let pt4 = self.view.viewWithTag(4) as? UILabel
        
        let lel1 = self.view.viewWithTag(22) as? UILabel
        let lel2 = self.view.viewWithTag(23) as? UILabel
        let o2 = self.view.viewWithTag(24) as? UILabel
        
        let kv1 = self.view.viewWithTag(5) as? UIImageView
        let kv4 = self.view.viewWithTag(6) as? UIImageView
        let kv7 = self.view.viewWithTag(7) as? UIImageView
        let kv8 = self.view.viewWithTag(8) as? UIImageView
        let kv9 = self.view.viewWithTag(9) as? UIImageView
        let kv10 = self.view.viewWithTag(10) as? UIImageView
        let kv11 = self.view.viewWithTag(11) as? UIImageView
        let kv12 = self.view.viewWithTag(12) as? UIImageView
        let kv13 = self.view.viewWithTag(13) as? UIImageView
        let kv14 = self.view.viewWithTag(14) as? UIImageView
        let kv15 = self.view.viewWithTag(15) as? UIImageView
        let kv16 = self.view.viewWithTag(16) as? UIImageView
        let kv17 = self.view.viewWithTag(26) as? UIImageView
        let yv1 = self.view.viewWithTag(17) as? UIImageView
        
        let flameDetected = self.view.viewWithTag(18) as? UIImageView
        let fireEnabled = self.view.viewWithTag(19) as? UIImageView
        let callforIgn = self.view.viewWithTag(20) as? UIImageView
        let airFlow = self.view.viewWithTag(21) as? UIImageView
        
        switch fireNumber {
        case 1...6:
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1102_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt2!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1103_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt3!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1104_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                pt4!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(LEL1_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                lel1!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(LEL2_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                lel2!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(O2_SCALEDVAL + offset), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                o2!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(ZS1VALVESTATUS + fireNumber - 1), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let valveState = Int(truncating: response![0] as! NSNumber)
               let base_2_binary = String(valveState, radix: 2)
               let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
               let arr = Bit_16.map { String($0) }
               
               arr[1] == "1" ? ( kv12?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv12?.image = #imageLiteral(resourceName: "valve-white"))
               arr[1] == "1" ? ( kv13?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv13?.image = #imageLiteral(resourceName: "valve-white"))
               arr[2] == "1" ? ( kv17?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv17?.image = #imageLiteral(resourceName: "valve-white"))
               arr[3] == "1" ? ( kv14?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv14?.image = #imageLiteral(resourceName: "valve-white"))

               arr[4] == "1" ? ( kv16?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv16?.image = #imageLiteral(resourceName: "valve-white"))
               arr[5] == "1" ? ( kv11?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv11?.image = #imageLiteral(resourceName: "valve-white"))
                
               arr[6] == "1" ? ( kv15?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv15?.image = #imageLiteral(resourceName: "valve-white"))
               arr[6] == "1" ? ( kv10?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv10?.image = #imageLiteral(resourceName: "valve-white"))
               arr[6] == "1" ? ( kv9?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv9?.image = #imageLiteral(resourceName: "valve-white"))
               
               arr[7] == "1" ? ( yv1?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (yv1?.image = #imageLiteral(resourceName: "valve-white"))
               arr[8] == "1" ? ( kv8?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv8?.image = #imageLiteral(resourceName: "valve-white"))
               arr[9] == "1" ? ( kv7?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv7?.image = #imageLiteral(resourceName: "valve-white"))
               arr[12] == "1" ? ( kv4?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv4?.image = #imageLiteral(resourceName: "valve-white"))
               arr[15] == "1" ? ( kv1?.image = #imageLiteral(resourceName: "WOF-reg-green")) : (kv1?.image = #imageLiteral(resourceName: "valve-white"))
               
            })
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(ZS401HAND_CMD + fireNumber - 1), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let fireCmd = Int(truncating: response![0] as! NSNumber)
                
                if fireCmd == 1{
                    self.handCmdSwitch.isOn = true
                } else {
                    self.handCmdSwitch.isOn = false
                }
            })
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(ZS401FIREDISB_CMD + fireNumber - 1), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let fireDisb = Int(truncating: response![0] as! NSNumber)
                
                if fireDisb == 1{
                    self.fireDisbSwitch.isOn = true
                } else {
                    self.fireDisbSwitch.isOn = false
                }
            })
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(ZS1ALARMSTATUS + fireNumber - 1), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let valveState = Int(truncating: response![0] as! NSNumber)
               let base_2_binary = String(valveState, radix: 2)
               let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
               let arr = Bit_16.map { String($0) }
               
               arr[0] == "1" ? ( airFlow?.image = #imageLiteral(resourceName: "green")) : (airFlow?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[13] == "1" ? ( flameDetected?.image = #imageLiteral(resourceName: "green")) : (flameDetected?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[14] == "1" ? ( callforIgn?.image = #imageLiteral(resourceName: "green")) : (callforIgn?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[15] == "1" ? ( fireEnabled?.image = #imageLiteral(resourceName: "green")) : (fireEnabled?.image = #imageLiteral(resourceName: "blank_icon_on"))
                
               if arr[1] != "0" || arr[2] != "0" || arr[3] != "1" || arr[4] != "1" || arr[5] != "0" || arr[6] != "0" || arr[7] != "0" || arr[8] != "0" || arr[9] != "0" || arr[10] != "0" || arr[11] != "0" || arr[12] != "0"  {
                    self.checkFaultsBtn.setTitleColor(RED_COLOR, for: .normal)
               } else {
                    self.checkFaultsBtn.setTitleColor(DEFAULT_GRAY, for: .normal)
               }
            })
        default:
            print("wrong Tag")
        }
    }
    func pad(string : String, toSize: Int) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }
    func parseFireStats(){
        
    }
    
    @IBAction func sendFireCmd(_ sender: UISwitch) {
        if self.handCmdSwitch.isOn{
            addFireAlert(startregister:ZS401HAND_CMD +  fireNumber - 1)
        } else {
            CENTRAL_SYSTEM?.writeBit(bit: ZS401HAND_CMD + fireNumber - 1, value: 0)
        }
        
    }
    
    @IBAction func sendFireDisableCmd(_ sender: UISwitch) {
        if self.fireDisbSwitch.isOn{
            CENTRAL_SYSTEM?.writeBit(bit: ZS401FIREDISB_CMD + fireNumber - 1, value: 1)
        } else {
            CENTRAL_SYSTEM?.writeBit(bit: ZS401FIREDISB_CMD + fireNumber - 1, value: 0)
        }
    }
    @IBAction func sendAbortCmd(_ sender: UIButton) {
        CENTRAL_SYSTEM?.writeRegister(register: ABORT_FIRE, value: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            CENTRAL_SYSTEM?.writeRegister(register: ABORT_FIRE, value: 0)
        }
    }
    
    @IBAction func checkFaultButtonPressed(_ sender: UIButton) {
           let popoverContent = UIStoryboard(name: "firespire", bundle: nil).instantiateViewController(withIdentifier: "fireAlarmPopup") as! FireSpirePopupViewController
           let nav = UINavigationController(rootViewController: popoverContent)
           nav.modalPresentationStyle = .popover
           nav.isNavigationBarHidden = true
           let popover = nav.popoverPresentationController
           popoverContent.preferredContentSize = CGSize(width: 410, height: 480)
           popoverContent.fireNumber = fireNumber
           popover?.sourceView = sender
           self.present(nav, animated: true, completion: nil)
       }
}
