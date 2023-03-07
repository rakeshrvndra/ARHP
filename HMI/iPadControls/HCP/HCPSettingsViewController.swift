//
//  HCPSettingsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/15/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class HCPSettingsViewController: UIViewController {

    @IBOutlet weak var pt1scaledMaxVal: UITextField!
    @IBOutlet weak var pt1scaledMinVal: UITextField!
    @IBOutlet weak var pt2scaledMaxVal: UITextField!
    @IBOutlet weak var pt2scaledMinVal: UITextField!
    @IBOutlet weak var pt3scaledMaxVal: UITextField!
    @IBOutlet weak var pt3scaledMinVal: UITextField!
    @IBOutlet weak var lel1scaledMaxVal: UITextField!
    @IBOutlet weak var lel1scaledMinVal: UITextField!
    @IBOutlet weak var tt1scaledMaxVal: UITextField!
    @IBOutlet weak var tt1scaledMinVal: UITextField!
    @IBOutlet weak var tt2scaledMaxVal: UITextField!
    @IBOutlet weak var tt2scaledMinVal: UITextField!
    @IBOutlet weak var o2scaledMaxVal: UITextField!
    @IBOutlet weak var o2scaledMinVal: UITextField!
    private var centralSystem = CentralSystem()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        constructSaveButton()
        self.navigationItem.title = "HCP SETTINGS - 1"
        readHCPStats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }
            
    @objc func checkSystemStat(){
        readHCPStats()
    }
    
    @objc private func saveSetpoints(){
        
        self.saveSetpointsToPLC()
        
    }

    func readHCPStats (){
            
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT1_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt1scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT1_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt1scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT2_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt2scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT2_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt2scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT3_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt3scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPPT3_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.pt3scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT1_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tt1scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT1_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tt1scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT2_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tt2scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPTT2_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tt2scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPO2_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.o2scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPO2_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.o2scaledMinVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPLEL_SCALEDMAX), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.lel1scaledMaxVal.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(HCPLEL_SCALEDMIN), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.lel1scaledMinVal.text =  String(format: "%.0f", value)
                 })
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
             let o2scalMax = Float(self.o2scaledMaxVal.text!)
             let o2scalMin = Float(self.o2scaledMinVal.text!)
             let tt1scalMax = Float(self.tt1scaledMaxVal.text!)
             let tt1scalMin = Float(self.tt1scaledMinVal.text!)
             let tt2scalMax = Float(self.tt2scaledMaxVal.text!)
             let tt2scalMin = Float(self.tt2scaledMinVal.text!)
            
             guard pt1scalMax != nil && pt1scalMin != nil && pt2scalMax != nil && pt2scalMin != nil && pt3scalMax != nil && pt3scalMin != nil && lel1scalMax != nil && lel1scalMin != nil && tt1scalMax != nil && tt1scalMin != nil && o2scalMax != nil && o2scalMin != nil && tt2scalMax != nil && tt2scalMin != nil  else{
                 return
             }
             
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT1_SCALEDMAX, value: pt1scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT1_SCALEDMIN, value: pt1scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT2_SCALEDMAX, value: pt2scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT2_SCALEDMIN, value: pt2scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT3_SCALEDMAX, value: pt3scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPPT3_SCALEDMIN, value: pt3scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPLEL_SCALEDMAX, value: lel1scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPLEL_SCALEDMIN, value: lel1scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPO2_SCALEDMAX, value: o2scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPO2_SCALEDMIN, value: o2scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPTT1_SCALEDMAX, value: tt1scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPTT1_SCALEDMIN, value: tt1scalMin!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPTT2_SCALEDMAX, value: tt2scalMax!)
             CENTRAL_SYSTEM?.writeRealValue(register: HCPTT2_SCALEDMIN, value: tt2scalMin!)
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                 self.readHCPStats()
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
