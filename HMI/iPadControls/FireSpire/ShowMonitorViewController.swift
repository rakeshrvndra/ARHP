//
//  ShowMonitorViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 10/12/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class ShowMonitorViewController: UIViewController {

    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrLbl: UILabel!
    private var centralSystem = CentralSystem()
    @IBOutlet weak var valveOpenBtn: UIButton!
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
            readFireStats()
        self.navigationItem.title = "FIRE SPIRE SHOW MONITOR"
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
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(KVx108_VALVE_OPENCMD), completion:{ (success, response) in
            
            guard success == true else { return }
            
           let fireCmd = Int(truncating: response![0] as! NSNumber)
            
            if fireCmd == 0{
                self.valveOpenBtn.isEnabled = true
            }
        })
        for index in 0...5 {
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(ZS1ALARMSTATUS+index), completion:{ (success, response) in
                
               guard success == true else { return }
               let valveState = Int(truncating: response![0] as! NSNumber)
               let base_2_binary = String(valveState, radix: 2)
               let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
               let arr = Bit_16.map { String($0) }
                
               let o2Alarm = self.view.viewWithTag(109+index) as? UIImageView
               let burnerFault = self.view.viewWithTag(3+(index*6)) as? UIImageView
               let flameDetected = self.view.viewWithTag(2+(index*6)) as? UIImageView
               let callforIgn = self.view.viewWithTag(4+(index*6)) as? UIImageView
               let lel1alarm = self.view.viewWithTag(43+(index*6)) as? UIImageView
               let lel1warning = self.view.viewWithTag(44+(index*6)) as? UIImageView
               let lel1fault = self.view.viewWithTag(45+(index*6)) as? UIImageView
               let lel2alarm = self.view.viewWithTag(46+(index*6)) as? UIImageView
               let lel2warning = self.view.viewWithTag(47+(index*6)) as? UIImageView
               let lel2fault = self.view.viewWithTag(48+(index*6)) as? UIImageView
                
               arr[1] == "1" ? ( o2Alarm?.image = #imageLiteral(resourceName: "red")) : (o2Alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[5] == "1" ? ( lel1fault?.image = #imageLiteral(resourceName: "red")) : (lel1fault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[6] == "1" ? ( lel1warning?.image = #imageLiteral(resourceName: "red")) : (lel1warning?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[7] == "1" ? ( lel1alarm?.image = #imageLiteral(resourceName: "red")) : (lel1alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[8] == "1" ? ( lel2fault?.image = #imageLiteral(resourceName: "red")) : (lel2fault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[9] == "1" ? ( lel2warning?.image = #imageLiteral(resourceName: "red")) : (lel2warning?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[10] == "1" ? ( lel2alarm?.image = #imageLiteral(resourceName: "red")) : (lel2alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[11] == "1" ? ( burnerFault?.image = #imageLiteral(resourceName: "red")) : (burnerFault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[13] == "1" ? ( flameDetected?.image = #imageLiteral(resourceName: "green")) : (flameDetected?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[14] == "1" ? ( callforIgn?.image = #imageLiteral(resourceName: "green")) : (callforIgn?.image = #imageLiteral(resourceName: "blank_icon_on"))
            })
            
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1102_SCALEDVAL + (index*60)), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                let mixTankPressure = self.view.viewWithTag(5+(index*6)) as? UILabel
                mixTankPressure!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1103_SCALEDVAL + (index*60)), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                let h2TankPressure = self.view.viewWithTag(6+(index*6)) as? UILabel
                h2TankPressure!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1104_SCALEDVAL + (index*60)), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                let pilotPressure = self.view.viewWithTag(37+index) as? UILabel
                pilotPressure!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(LEL1_SCALEDVAL + (index*60)), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                let lel1 = self.view.viewWithTag(79+index) as? UILabel
                lel1!.text =  String(format: "%.1f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(LEL2_SCALEDVAL + (index*60)), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                let lel2 = self.view.viewWithTag(85+index) as? UILabel
                lel2!.text =  String(format: "%.1f", value)
            })
       }
        CENTRAL_SYSTEM?.readRegister(length: 6, startingRegister: Int32(ZSN2FLOW), completion:{ (success, response) in
            
           guard success == true else { return }
           let f1n2State = Int(truncating: response![0] as! NSNumber)
           let f2n2State = Int(truncating: response![1] as! NSNumber)
           let f3n2State = Int(truncating: response![2] as! NSNumber)
           let f4n2State = Int(truncating: response![3] as! NSNumber)
           let f5n2State = Int(truncating: response![4] as! NSNumber)
           let f6n2State = Int(truncating: response![5] as! NSNumber)
            
           let f1n2Img = self.view.viewWithTag(1) as? UIImageView
           let f2n2Img = self.view.viewWithTag(7) as? UIImageView
           let f3n2Img = self.view.viewWithTag(13) as? UIImageView
           let f4n2Img = self.view.viewWithTag(19) as? UIImageView
           let f5n2Img = self.view.viewWithTag(25) as? UIImageView
           let f6n2Img = self.view.viewWithTag(31) as? UIImageView
            if f1n2State == 0{
                f1n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f1n2State == 1{
                f1n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f1n2State == 2{
                f1n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f1n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
            if f2n2State == 0{
                f2n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f2n2State == 1{
                f2n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f2n2State == 2{
                f2n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f2n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
            if f3n2State == 0{
                f3n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f3n2State == 1{
                f3n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f3n2State == 2{
                f3n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f3n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
            if f4n2State == 0{
                f4n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f4n2State == 1{
                f4n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f4n2State == 2{
                f4n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f4n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
            if f5n2State == 0{
                f5n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f5n2State == 1{
                f5n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f5n2State == 2{
                f5n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f5n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
            if f6n2State == 0{
                f6n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
            } else if f6n2State == 1{
                f6n2Img?.image = #imageLiteral(resourceName: "green")
            } else if f6n2State == 2{
                f6n2Img?.image = #imageLiteral(resourceName: "red")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    f6n2Img?.image = #imageLiteral(resourceName: "blank_icon_on")
                }
            }
        })
    }
    func pad(string : String, toSize: Int) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }

    @IBAction func sendValveOpenCmd(_ sender: UIButton) {
       CENTRAL_SYSTEM?.writeBit(bit: KVx108_VALVE_OPENCMD, value: 1)
        self.valveOpenBtn.isEnabled = false
    }
}
