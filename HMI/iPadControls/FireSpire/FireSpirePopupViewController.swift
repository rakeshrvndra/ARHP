//
//  FireSpirePopupViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/20/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class FireSpirePopupViewController: UIViewController {
    var fireNumber = 0
    private var centralSystem = CentralSystem()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
          NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    
    @objc func checkSystemStat(){
        readAlarms()
    }
    
    func readAlarms(){
        let offset = (fireNumber - 1)
        
        let burnerFault = self.view.viewWithTag(2) as? UIImageView
        let lel1alarm = self.view.viewWithTag(3) as? UIImageView
        let lel1warning = self.view.viewWithTag(4) as? UIImageView
        let lel1fault = self.view.viewWithTag(5) as? UIImageView
        let lel2alarm = self.view.viewWithTag(6) as? UIImageView
        let lel2warning = self.view.viewWithTag(7) as? UIImageView
        let lel2fault = self.view.viewWithTag(8) as? UIImageView
        let psh2 = self.view.viewWithTag(9) as? UIImageView
        let psh1 = self.view.viewWithTag(10) as? UIImageView
        let estop = self.view.viewWithTag(11) as? UIImageView
        let moisture = self.view.viewWithTag(12) as? UIImageView
        let o2Alarm = self.view.viewWithTag(13) as? UIImageView
        let highwind = self.view.viewWithTag(14) as? UIImageView
        
        switch fireNumber {
        case 1...6:
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(ZS1ALARMSTATUS + offset), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let valveState = Int(truncating: response![0] as! NSNumber)
               let base_2_binary = String(valveState, radix: 2)
               let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
               let arr = Bit_16.map { String($0) }
               
               arr[1] == "1" ? ( o2Alarm?.image = #imageLiteral(resourceName: "red")) : (o2Alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[2] == "1" ? ( estop?.image = #imageLiteral(resourceName: "red")) : (estop?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[3] == "0" ? ( psh1?.image = #imageLiteral(resourceName: "red")) : (psh1?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[4] == "0" ? ( psh2?.image = #imageLiteral(resourceName: "red")) : (psh2?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[5] == "1" ? ( lel1fault?.image = #imageLiteral(resourceName: "red")) : (lel1fault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[6] == "1" ? ( lel1warning?.image = #imageLiteral(resourceName: "red")) : (lel1warning?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[7] == "1" ? ( lel1alarm?.image = #imageLiteral(resourceName: "red")) : (lel1alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[8] == "1" ? ( lel2fault?.image = #imageLiteral(resourceName: "red")) : (lel2fault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[9] == "1" ? ( lel2warning?.image = #imageLiteral(resourceName: "red")) : (lel2warning?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[10] == "1" ? ( lel2alarm?.image = #imageLiteral(resourceName: "red")) : (lel2alarm?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[11] == "1" ? ( burnerFault?.image = #imageLiteral(resourceName: "red")) : (burnerFault?.image = #imageLiteral(resourceName: "blank_icon_on"))
               arr[12] == "1" ? ( moisture?.image = #imageLiteral(resourceName: "red")) : (moisture?.image = #imageLiteral(resourceName: "blank_icon_on"))
               
            })
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(ZS2ALARMSTATUS + offset), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let valveState = Int(truncating: response![0] as! NSNumber)
               let base_2_binary = String(valveState, radix: 2)
               let Bit_16:String = self.pad(string: base_2_binary, toSize: 16)
               let arr = Bit_16.map { String($0) }
               
               arr[15] == "1" ? (highwind?.image = #imageLiteral(resourceName: "red")) : (highwind?.image = #imageLiteral(resourceName: "blank_icon_on"))
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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
