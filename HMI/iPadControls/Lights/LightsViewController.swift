//
//  LightsViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class LightsViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var lightIconButton: UIButton!
    @IBOutlet weak var handModeIcon: UIImageView!
    @IBOutlet weak var autoModeIcon: UIImageView!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var lightsHOAStatus: UILabel!
    @IBOutlet weak var lightLbl: UILabel!
    @IBOutlet weak var lightFault: UIImageView!
    private var centralSystem = CentralSystem()
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var numberOfLightsOn = 0
    private var inHandMode = false
    private var lightState = 0
    private var autoHandStats = 0
    private var schOnStatus = 0
    private var waterLevelBelowLLFault = [Int]()
    private var individualLightStatus = 0
    var lightType = 0
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        self.navigationItem.title = "BASIN LIGHTS"
        self.lightLbl.text = "LCP - 101"
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        numberOfLightsOn = 0
    }
    
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection, serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            
            readLightsAutoHandMode()
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLbl.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLbl.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    
    

    @IBAction func lightsIconButtonPressed(_ sender: UIButton) {
        //In Auto Mode
        if autoHandStats == 0 {
            //Switch to Manual Mode
            CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 1)
        } else if autoHandStats == 1 {
            //In Manual Mode
            //Switch to Auto Mode
            CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 0)
        }
    }
    
    
    private func lightInAutoMode() {
        autoModeIcon.isHidden = false
        autoModeIcon.rotate360Degrees(animate: true)
        handModeIcon.isHidden = true
        inHandMode = false
        schedulerContainerView.isHidden = false
    }
    
    private func lightInManualMode() {
        autoModeIcon.isHidden = true
        handModeIcon.isHidden = false
        inHandMode = true
        schedulerContainerView.isHidden = true
    }
    
    
    private func readLightsAutoHandMode() {
        CENTRAL_SYSTEM?.readBits(length: 5, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
            
            guard success == true else { return }
            let autoHandStatus = Int(truncating: response![0] as! NSNumber)
            let lightFaultVal = Int(truncating: response![4] as! NSNumber)
            self.autoHandStats = autoHandStatus
            if autoHandStatus == 1 {
                self.lightInManualMode()
            } else if autoHandStatus == 0 {
                self.lightInAutoMode()
            }
            if lightFaultVal == 1{
                self.lightFault.isHidden = false
            } else if lightFaultVal == 0{
                self.lightFault.isHidden = true
            }
            
        })
        CENTRAL_SYSTEM!.readRegister(length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER.register), completion:{ (success, response) in
            
            guard success == true else { return }
                
            self.schOnStatus = Int(truncating: response![0] as! NSNumber)
            if self.schOnStatus == 0 {
               self.lightsHOAStatus.text = "LIGHTS AUTO"
            } else if self.schOnStatus == 1 {
               self.lightsHOAStatus.text = "LIGHTS MANUAL OFF"
            } else if self.schOnStatus == 2{
               self.lightsHOAStatus.text = "LIGHTS MANUAL ON"
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(LIGHTS_STATUS.register), completion: { (success, response) in
            
            guard success == true else { return }
            
            self.lightState = Int(truncating: response![0] as! NSNumber)
            let lightButton = self.view.viewWithTag(1) as? UIButton
            if self.inHandMode {
              if self.lightState == 1 {
                  lightButton?.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                  self.individualLightStatus = 1
              } else {
                  lightButton?.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                  self.individualLightStatus = 0
              }
            }
             if self.lightState == 1 {
               self.lightIconButton.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
             } else {
               self.lightIconButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
             }
            
        })
    }
    //MARK: - Turn On/Off Lights Manually
    
    
    @IBAction func turnLightOnOff(_ sender: UIButton) {
        //NOTE: Each button tag subtracted by one, will point to the corresponding PLC register in the array for that light
            let lightRegister = LIGHTS_ON_OFF_WRITE_REGISTERS[sender.tag - 1]
            
            if individualLightStatus == 0 {
                CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 1)
                
                
            } else if individualLightStatus == 1 {
                
                CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 0)
                
            }
    }
    
}
