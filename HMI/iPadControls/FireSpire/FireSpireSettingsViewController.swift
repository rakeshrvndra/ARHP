//
//  FireSpireSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/15/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class FireSpireSettingsViewController: UIViewController {
    
    @IBOutlet weak var pt1scaledMaxName: UILabel!
    @IBOutlet weak var pt1scaledMinName: UILabel!
    @IBOutlet weak var pt2scaledMaxName: UILabel!
    @IBOutlet weak var pt2scaledMinName: UILabel!
    @IBOutlet weak var pt3scaledMaxName: UILabel!
    @IBOutlet weak var pt3scaledMinName: UILabel!
    @IBOutlet weak var lel1scaledMaxName: UILabel!
    @IBOutlet weak var lel1scaledMinName: UILabel!
    @IBOutlet weak var lel2scaledMaxName: UILabel!
    @IBOutlet weak var lel2scaledMinName: UILabel!
    @IBOutlet weak var o2scaledMaxName: UILabel!
    @IBOutlet weak var o2scaledMinName: UILabel!
    
    @IBOutlet weak var hideTimersView: UIView!
    @IBOutlet weak var pt1scaledMaxVal: UITextField!
    @IBOutlet weak var pt1scaledMinVal: UITextField!
    @IBOutlet weak var pt2scaledMaxVal: UITextField!
    @IBOutlet weak var pt2scaledMinVal: UITextField!
    @IBOutlet weak var pt3scaledMaxVal: UITextField!
    @IBOutlet weak var pt3scaledMinVal: UITextField!
    @IBOutlet weak var lel1scaledMaxVal: UITextField!
    @IBOutlet weak var lel1scaledMinVal: UITextField!
    @IBOutlet weak var lel2scaledMaxVal: UITextField!
    @IBOutlet weak var lel2scaledMinVal: UITextField!
    @IBOutlet weak var o2scaledMaxVal: UITextField!
    @IBOutlet weak var o2scaledMinVal: UITextField!
    
    var fireSpireNumber = 0
    private var centralSystem =                     CentralSystem()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           NotificationCenter.default.removeObserver(self)
       }
       
       private func constructSaveButton(){
           
           navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
           
       }
       
       @objc private func saveSetpoints(){
           
           self.saveSetpointsToPLC()
           
       }
    
       override func viewWillAppear(_ animated: Bool) {
               centralSystem.getNetworkParameters()
               centralSystem.connect()
               CENTRAL_SYSTEM = centralSystem
            constructSaveButton()
       //         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        self.lel1scaledMaxVal.isHidden = false
        self.lel1scaledMinVal.isHidden = false
        self.lel2scaledMaxVal.isHidden = false
               switch fireSpireNumber {
               case 1...6:self.pt1scaledMaxName.text = "PT\(fireSpireNumber)102 SCALED VALUE MAX (PSI)"
                           self.pt1scaledMinName.text = "PT\(fireSpireNumber)102 SCALED VALUE MIN (PSI)"
                           self.pt2scaledMaxName.text = "PT\(fireSpireNumber)103 SCALED VALUE MAX (PSI)"
                           self.pt2scaledMinName.text = "PT\(fireSpireNumber)103 SCALED VALUE MIN (PSI)"
                           self.pt3scaledMaxName.text = "PT\(fireSpireNumber)104 SCALED VALUE MAX (PSI)"
                           self.pt3scaledMinName.text = "PT\(fireSpireNumber)104 SCALED VALUE MIN (PSI)"
                           self.lel1scaledMaxName.text = "LEL\(fireSpireNumber)101 SCALED VALUE MAX (%)"
                           self.lel1scaledMinName.text = "LEL\(fireSpireNumber)101 SCALED VALUE MIN (%)"
                           self.lel2scaledMaxName.text = "LEL\(fireSpireNumber)102 SCALED VALUE MAX (%)"
                           self.lel2scaledMinName.text = "LEL\(fireSpireNumber)102 SCALED VALUE MIN (%)"
                           self.o2scaledMaxName.text = "O2\(fireSpireNumber)101 SCALED VALUE MAX (%)"
                           self.o2scaledMinName.text = "O2\(fireSpireNumber)101 SCALED VALUE MIN (%)"
                           self.navigationItem.title = "ZS - 40\(fireSpireNumber) SETTINGS"
                           self.hideTimersView.isHidden = true
                case 7:    self.hideTimersView.frame = CGRect(x: 74, y:273 , width: 923, height: 400)
                           self.lel1scaledMaxVal.isHidden = true
                           self.lel1scaledMinVal.isHidden = true
                           self.lel2scaledMaxVal.isHidden = true
                           self.pt1scaledMaxName.text = "TYPE 1 FIRE H2 SP (PSI)"
                           self.pt1scaledMinName.text = "TYPE 2 FIRE H2 SP (PSI)"
                           self.pt2scaledMaxName.text = "TYPE 3 FIRE H2 SP (PSI)"
                           self.pt2scaledMinName.text = ""
                           self.pt3scaledMaxName.text = ""
                           self.pt3scaledMinName.text = ""
                           self.lel1scaledMaxName.text = ""
                           self.lel1scaledMinName.text = ""
                           self.lel2scaledMaxName.text = ""
                           self.lel2scaledMinName.text = ""
                           self.o2scaledMaxName.text = ""
                           self.o2scaledMinName.text = ""
                           self.navigationItem.title = "FIRE SHOT CONFIGURATION SETTINGS"
                           self.hideTimersView.isHidden = false
                case 8:
                           self.pt1scaledMaxName.text = "N2 PURGE ON SP (PSI)"
                           self.pt1scaledMinName.text = "N2 PURGE OFF SP (PSI)"
                           self.pt2scaledMaxName.text = "ANIMATION VALVE DELAY TIMER (msec)"
                           self.pt2scaledMinName.text = "SALT DELAY TIMER (msec)"
                           self.pt3scaledMaxName.text = ""
                           self.pt3scaledMinName.text = ""
                           self.lel1scaledMaxName.text = "FILL DELAY TIMER (sec)"
                           self.lel1scaledMinName.text = "PURGE DELAY TIMER (sec)"
                           self.lel2scaledMaxName.text = "RESET DELAY TIMER (sec)"
                           self.lel2scaledMinName.text = "PILOT RETRIES"
                           self.o2scaledMaxName.text = ""
                           self.o2scaledMinName.text = ""
                           self.navigationItem.title = "FIRE TIMERS SETTINGS"
                           self.hideTimersView.isHidden = false
               default:
                   print("Wrong Tag: SaltFill")
               }
               readSaltFillStats()
           }
           
           
           @objc func checkSystemStat(){
               readSaltFillStats()
           }

   func readSaltFillStats (){
            let offset = (fireSpireNumber - 1)*60
            switch fireSpireNumber {
            case 1...6:
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt1scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT1_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt1scaledMinVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT2_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt2scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT2_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt2scaledMinVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT3_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt3scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIREPT3_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.pt3scaledMinVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRELEL1_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.lel1scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRELEL1_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.lel1scaledMinVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRELEL2_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.lel2scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(FIRELEL2_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.lel2scaledMinVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(O2_SCALEDMAX + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.o2scaledMaxVal.text =  String(format: "%.0f", value)
                })
                CENTRAL_SYSTEM?.readRealRegister(register: Int(O2_SCALEDMIN + offset), length: 2, completion: { (success, response) in
                    guard success == true else { return }
                    let value = Float(response)!
                    self.o2scaledMinVal.text =  String(format: "%.0f", value)
                })
            
        case 7:
            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE1FIRESHOT_H2), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                self.pt1scaledMaxVal.text =  String(format: "%.0f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE2FIRESHOT_H2), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                self.pt1scaledMinVal.text =  String(format: "%.0f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE3FIRESHOT_H2), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                self.pt2scaledMaxVal.text =  String(format: "%.0f", value)
            })
//            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE1FIRESHOT_N2), length: 2, completion: { (success, response) in
//                guard success == true else { return }
//                let value = Float(response)!
//                self.lel1scaledMaxVal.text =  String(format: "%.0f", value)
//            })
//            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE2FIRESHOT_N2), length: 2, completion: { (success, response) in
//                guard success == true else { return }
//                let value = Float(response)!
//                self.lel1scaledMinVal.text =  String(format: "%.0f", value)
//            })
//            CENTRAL_SYSTEM?.readRealRegister(register: Int(TYPE3FIRESHOT_N2), length: 2, completion: { (success, response) in
//                guard success == true else { return }
//                let value = Float(response)!
//                self.lel2scaledMaxVal.text =  String(format: "%.0f", value)
//            })
        case 8:
            CENTRAL_SYSTEM?.readRealRegister(register: Int(N2PURGEON_SP), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                self.pt1scaledMaxVal.text =  String(format: "%.0f", value)
            })
            CENTRAL_SYSTEM?.readRealRegister(register: Int(N2PURGEOFF_SP), length: 2, completion: { (success, response) in
                guard success == true else { return }
                let value = Float(response)!
                self.pt1scaledMinVal.text =  String(format: "%.0f", value)
            })
            CENTRAL_SYSTEM?.readRegister(length: 6, startingRegister: Int32(ANIMVALVEOPEN_TIMER), completion:{ (success, response) in
                
                guard success == true else { return }
                
               let animTimer = Int(truncating: response![0] as! NSNumber)
               let saltTimer = Int(truncating: response![1] as! NSNumber)
               let fillTimer = Int(truncating: response![2] as! NSNumber)
               let purgeTimer = Int(truncating: response![3] as! NSNumber)
               let resetTimer = Int(truncating: response![4] as! NSNumber)
               let retiresTimer = Int(truncating: response![5] as! NSNumber)
                
                self.pt2scaledMaxVal.text!  = "\(animTimer)"
                self.pt2scaledMinVal.text!  = "\(saltTimer)"
                self.lel1scaledMaxVal.text! = "\(fillTimer)"
                self.lel1scaledMinVal.text! = "\(purgeTimer)"
                self.lel2scaledMaxVal.text! = "\(resetTimer)"
                self.lel2scaledMinVal.text! = "\(retiresTimer)"
            })
            default:
                print("wrong Tag")
            }
        }
        
        private func saveSetpointsToPLC(){
            let pt1scalMax = Float(self.pt1scaledMaxVal.text!)
            let pt1scalMin = Float(self.pt1scaledMinVal.text!)
            let pt2scalMax = Float(self.pt2scaledMaxVal.text!)
            let pt2scalMin = Float(self.pt2scaledMinVal.text!)
            let pt3scalMax = Float(self.pt3scaledMaxVal.text!)
            let pt3scalMin = Float(self.pt3scaledMinVal.text!)
            let lel1scalMax = Float(self.lel1scaledMaxVal.text!)
            let lel1scalMin = Float(self.lel1scaledMinVal.text!)
            let lel2scalMax = Float(self.lel2scaledMaxVal.text!)
            let lel2scalMin = Float(self.lel2scaledMinVal.text!)
            let o2scalMax = Float(self.o2scaledMaxVal.text!)
            let o2scalMin = Float(self.o2scaledMinVal.text!)
            
            if fireSpireNumber == 8 {
                guard pt1scalMax != nil && pt1scalMin != nil && pt2scalMax != nil && pt2scalMin != nil && lel1scalMax != nil && lel1scalMin != nil && lel2scalMax != nil && lel2scalMin != nil   else{
                    return
                }
            } else if fireSpireNumber == 7 {
                guard pt1scalMax != nil && pt1scalMin != nil && pt2scalMax != nil else{
                    return
                }
            } else {
                guard pt1scalMax != nil && pt1scalMin != nil && pt2scalMax != nil && pt2scalMin != nil && pt3scalMax != nil && pt3scalMin != nil && lel1scalMax != nil && lel1scalMin != nil && lel2scalMax != nil && lel2scalMin != nil && o2scalMax != nil && o2scalMin != nil  else{
                    return
                }
            }
            
            
            let offset = (fireSpireNumber - 1)*60
            
            switch fireSpireNumber {
            case 1...6: CENTRAL_SYSTEM?.writeRealValue(register: FIREPT1_SCALEDMAX + offset, value: pt1scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIREPT1_SCALEDMIN + offset, value: pt1scalMin!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIREPT2_SCALEDMAX + offset, value: pt2scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIREPT2_SCALEDMIN + offset, value: pt2scalMin!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIREPT3_SCALEDMAX + offset, value: pt3scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIREPT3_SCALEDMIN + offset, value: pt3scalMin!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIRELEL1_SCALEDMAX + offset, value: lel1scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIRELEL1_SCALEDMIN + offset, value: lel1scalMin!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIRELEL2_SCALEDMAX + offset, value: lel2scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: FIRELEL2_SCALEDMIN + offset, value: lel2scalMin!)
                        CENTRAL_SYSTEM?.writeRealValue(register: O2_SCALEDMAX + offset, value: o2scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: O2_SCALEDMIN + offset, value: o2scalMin!)
             case 7:    let value1 = pt1scalMax!
                        let value2 = pt1scalMin!
                        let value3 = pt2scalMax!
                        if value1 < 90.0{
                            CENTRAL_SYSTEM?.writeRealValue(register: TYPE1FIRESHOT_H2, value:      pt1scalMax!)
                        }
                        if value2 < 90.0{
                            CENTRAL_SYSTEM?.writeRealValue(register: TYPE2FIRESHOT_H2, value: pt1scalMin!)
                        }
                        if value3 < 90.0{
                            CENTRAL_SYSTEM?.writeRealValue(register: TYPE3FIRESHOT_H2, value: pt2scalMax!)
                        }
              case 8:   CENTRAL_SYSTEM?.writeRealValue(register: N2PURGEON_SP, value: pt1scalMax!)
                        CENTRAL_SYSTEM?.writeRealValue(register: N2PURGEOFF_SP, value: pt1scalMin!)
                        let value = Int(pt2scalMax!)
                        if value < 3000{
                            CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER, value: Int(pt2scalMax!))
                        }
                        CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER+1, value: Int(pt2scalMin!))
                        CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER+2, value: Int(lel1scalMax!))
                        CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER+3, value: Int(lel1scalMin!))
                        CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER+4, value: Int(lel2scalMax!))
                        CENTRAL_SYSTEM?.writeRegister(register: ANIMVALVEOPEN_TIMER+5, value: Int(lel2scalMin!))
            default:
                print("Wrong Tag: SaltFill")
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                self.readSaltFillStats()
            }
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
