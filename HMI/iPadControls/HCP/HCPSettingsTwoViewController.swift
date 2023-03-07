//
//  HCPSettingsTwoViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/15/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class HCPSettingsTwoViewController: UIViewController {

    @IBOutlet weak var purgePressSP: UITextField!
    @IBOutlet weak var inletPressSP: UITextField!
    @IBOutlet weak var loopPressSP: UITextField!
    @IBOutlet weak var thresholdSP: UITextField!
    @IBOutlet weak var tempBlwL: UITextField!
    @IBOutlet weak var tempabvH: UITextField!
    @IBOutlet weak var airSupBlwL: UITextField!
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
        self.navigationItem.title = "HCP SETTINGS - 2"
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
            
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(PURGE_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.purgePressSP.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(INLET_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.inletPressSP.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(LOOP_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.loopPressSP.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(THRESHOLD_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.thresholdSP.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(TEMPBLWL_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tempBlwL.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(TEMPABVH_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.tempabvH.text =  String(format: "%.0f", value)
                 })
                 CENTRAL_SYSTEM?.readRealRegister(register: Int(AIRSUPPLYBLWL_PRESSURESP), length: 2, completion: { (success, response) in
                     guard success == true else { return }
                     let value = Float(response)!
                     self.airSupBlwL.text =  String(format: "%.0f", value)
                 })
         }
         
         private func saveSetpointsToPLC(){
         
             let purgeSP = Float(self.purgePressSP.text!)
             let inletSP = Float(self.inletPressSP.text!)
             let loopSP = Float(self.loopPressSP.text!)
             let threshSP = Float(self.thresholdSP.text!)
             let tempBlwLSP = Float(self.tempBlwL.text!)
             let tempabvHSP = Float(self.tempabvH.text!)
             let airSupBlwLSP = Float(self.airSupBlwL.text!)
            
             guard purgeSP != nil && inletSP != nil && loopSP != nil && threshSP != nil && tempBlwLSP != nil && tempabvHSP != nil && airSupBlwLSP != nil else{
                 return
             }
             
             CENTRAL_SYSTEM?.writeRealValue(register: PURGE_PRESSURESP, value: purgeSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: INLET_PRESSURESP, value: inletSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: LOOP_PRESSURESP, value: loopSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: THRESHOLD_PRESSURESP, value: threshSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: TEMPBLWL_PRESSURESP, value: tempBlwLSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: TEMPABVH_PRESSURESP, value: tempabvHSP!)
             CENTRAL_SYSTEM?.writeRealValue(register: AIRSUPPLYBLWL_PRESSURESP, value: airSupBlwLSP!)
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
