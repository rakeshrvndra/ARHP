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
    private var centralSystem = CentralSystem()
    private let logger = Logger()
    private let httpComm = HTTPComm()
    private var numberOfLightsOn = 0
    private var inHandMode = false
    private var lightState = 0
    private var autoHandStats = 0
    private var waterLevelBelowLLFault = [Int]()
    private var individualLightStatus = 0
    var lightType = 0
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        if lightType == 100{
            self.navigationItem.title = "RUNNEL LIGHTS"
            self.lightLbl.text = "LCP - 401"
        } else if lightType == 200 {
            self.navigationItem.title = "PIXIE LIGHTS"
            self.lightLbl.text = "DAYMODE"
        }
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
        if lightType == 100{
            if autoHandStats == 0 {
                //Switch to Manual Mode
                CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 1)
            } else if autoHandStats == 1 {
                //In Manual Mode
                //Switch to Auto Mode
                CENTRAL_SYSTEM?.writeBit(bit: LIGHTS_AUTO_HAND_PLC_REGISTER.register, value: 0)
            }
        } else if lightType == 200 {
            if autoHandStats == 0 {
                //Switch to Manual Mode
                CENTRAL_SYSTEM?.writeBit(bit: PIXIE_AUTO_HAND_PLC_REGISTER.register, value: 1)
            } else if autoHandStats == 1 {
                //In Manual Mode
                //Switch to Auto Mode
                CENTRAL_SYSTEM?.writeBit(bit: PIXIE_AUTO_HAND_PLC_REGISTER.register, value: 0)
            }
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
        if lightType == 100{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(LIGHTS_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
                
                guard success == true else { return }
                let autoHandStatus = Int(truncating: response![0] as! NSNumber)
                
                self.autoHandStats = autoHandStatus
                
                if autoHandStatus == 1 {
                    self.lightInManualMode()
                } else if autoHandStatus == 0 {
                    self.lightInAutoMode()
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
            CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(LIGHTS_HOA_STATUS.register), completion: { (success, response) in
                
                guard success == true else { return }
                let hoaStatus = Int(truncating: response![0] as! NSNumber)
                
                if hoaStatus == 0{
                   self.lightsHOAStatus.text = "AUTO MODE"
                } else if hoaStatus == 1{
                   self.lightsHOAStatus.text = "HAND MODE OFF"
                } else if hoaStatus == 2{
                   self.lightsHOAStatus.text = "HAND MODE ON"
                }
            })
        } else if lightType == 200 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(PIXIE_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
                
                guard success == true else { return }
                let autoHandStatus = Int(truncating: response![0] as! NSNumber)
                
                self.autoHandStats = autoHandStatus
                
                if autoHandStatus == 1 {
                    self.lightInManualMode()
                } else if autoHandStatus == 0 {
                    self.lightInAutoMode()
                }
            })
            self.httpComm.httpGetResponseFromPath(url: STATUS_LOG_FTP_PATH){ (response) in
            
            guard response != nil else { return }
            
            guard let responseArray = response as? [Any] else { return }
            if !responseArray.isEmpty{
                let responseDictionary = responseArray[0] as? NSDictionary
                    if responseDictionary != nil{
                        if let dayMode = responseDictionary!["DayMode Status"] as? Int {
                            self.lightState = dayMode
                            let lightButton = self.view.viewWithTag(1) as? UIButton
                            if self.inHandMode {
                              if self.lightState == 0 {
                                  lightButton?.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                                  self.individualLightStatus = 1
                              } else {
                                  lightButton?.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                                  self.individualLightStatus = 0
                              }
                            }
                            if self.lightState == 0 {
                              self.lightIconButton.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                            } else {
                              self.lightIconButton.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                            }
                        }
                    }
                }
            }
            
            self.lightsHOAStatus.text = ""
        }
        
    }
    //MARK: - Turn On/Off Lights Manually
    
    
    @IBAction func turnLightOnOff(_ sender: UIButton) {
        //NOTE: Each button tag subtracted by one, will point to the corresponding PLC register in the array for that light
        if lightType == 100{
            let lightRegister = LIGHTS_ON_OFF_WRITE_REGISTERS[sender.tag - 1]
            
            if individualLightStatus == 0 {
                CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 1)
                
                
            } else if individualLightStatus == 1 {
                
                CENTRAL_SYSTEM?.writeBit(bit: lightRegister, value: 0)
                
            }
        } else if lightType == 200 {
           if individualLightStatus == 0 {
              let strUrl = DISABLE_DAY_MODE_CMD
              self.httpComm.httpGetResponseFromPath(url: strUrl) { (response) in
                  
              }
           } else if individualLightStatus == 1 {
               let strUrl = SET_DAY_MODE_CMD
               self.httpComm.httpGetResponseFromPath(url: strUrl) { (response) in
                   
               }
           }
        }
        
    }
    
}
