//
//  windSettingsViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 1/29/17.
//  Copyright © 2017 WET. All rights reserved.
//

import UIKit

class windSettingsViewController: UIViewController{
    
    //No Connection View
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionLbl: UILabel!
    
    @IBOutlet weak var abortOnDelay: UITextField!
    @IBOutlet weak var abortOffDelay: UITextField!
    @IBOutlet weak var lowOnDelay: UITextField!
    @IBOutlet weak var lowOffDelay: UITextField!
    @IBOutlet weak var highOnDelay: UITextField!
    @IBOutlet weak var highOffDelay: UITextField!

    private var centralSystem = CentralSystem()
    //Object References

    let logger = Logger()

    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/

    override func viewDidLoad(){

        super.viewDidLoad()

    }

    /***************************************************************************
     * Function :  viewDidAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/

    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        loadCurrentSetpointsFromPLC()
        constructSaveButton()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    /***************************************************************************
     * Function :  constructSaveButton
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/

    private func constructSaveButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "SAVE", style: .plain, target: self, action: #selector(saveSetpoints))
        
    }

    /***************************************************************************
     * Function :  loadCurrentSetpointsFromPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/

    private func loadCurrentSetpointsFromPLC(){
        
        CENTRAL_SYSTEM!.readRegister(length: 6, startingRegister: Int32(WIND_TIMER_PLC_ADDRESSES), completion:{ (success, response) in
            
            guard success == true else { return }
                
            let abortOn = Int(truncating: response![0] as! NSNumber)
            let abortOff = Int(truncating: response![1] as! NSNumber)
            
            let highOn = Int(truncating: response![2] as! NSNumber)
            let highOff = Int(truncating: response![3] as! NSNumber)
            
            let lowOn = Int(truncating: response![4] as! NSNumber)
            let lowOff = Int(truncating: response![5] as! NSNumber)
            
            self.abortOnDelay.text = "\(abortOn)"
            self.abortOffDelay.text = "\(abortOff)"
            
            self.highOnDelay.text = "\(highOn)"
            self.highOffDelay.text = "\(highOff)"
            
            self.lowOnDelay.text = "\(lowOn)"
            self.lowOffDelay.text = "\(lowOff)"
            
            
        })
        
    }


    @objc func checkSystemStat(){
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
         
            
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    

    /***************************************************************************
     * Function :  plcConsaveSetpointsnecting
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc private func saveSetpoints(){
        
        self.saveSetpointsToPLC()
        
    }

    /***************************************************************************
     * Function :  saveSetpointsToPLC
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/

    private func saveSetpointsToPLC(){
        
        let abortOn = Int(self.abortOnDelay.text!)
        let abortOff = Int(self.abortOffDelay.text!)
        
        let highOn = Int(self.highOnDelay.text!)
        let highOff = Int(self.highOffDelay.text!)
        
        let lowOn = Int(self.lowOnDelay.text!)
        let lowOff = Int(self.lowOffDelay.text!)
        
        //Checkpoints to make sure Setpoint Input Is Not Empty
        
        guard abortOn != nil && abortOff != nil && highOn != nil && highOff != nil && lowOn != nil && lowOff != nil else{
            return
        }
        
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES, value: abortOn!)
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES+1, value: abortOff!)
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES+2, value: highOn!)
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES+3, value: highOff!)
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES+4, value: lowOn!)
        CENTRAL_SYSTEM?.writeRegister(register: WIND_TIMER_PLC_ADDRESSES+5, value: lowOff!)

    }


}
