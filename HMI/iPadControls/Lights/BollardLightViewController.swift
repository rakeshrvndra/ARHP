//
//  BollardLightViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 2/1/22.
//  Copyright © 2022 WET. All rights reserved.
//

import UIKit

class BollardLightViewController: UIViewController {

    @IBOutlet weak var handSwitch: UISwitch!
    @IBOutlet weak var autoHandIcon: UIImageView!
    @IBOutlet weak var handModeView: UIView!
    @IBOutlet weak var autoHandBtn: UIButton!
    @IBOutlet weak var hoaStatusLbl: UILabel!
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    var autoHandStatus = 0
    var lightState = 0
    private var centralSystem = CentralSystem()
    
    override func viewWillAppear(_ animated: Bool) {
        //Add notification observer to get system stat
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        self.navigationItem.title = "FACILITY LIGHTS"
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
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
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func readLightsAutoHandMode(){
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FACILITY_AUTO_HAND_PLC_REGISTER.register), completion: { (success, response) in
            
            guard success == true else { return }
            self.autoHandStatus = Int(truncating: response![0] as! NSNumber)
            if self.autoHandStatus == 1{
                self.autoHandIcon.rotate360Degrees(animate: false)
                self.autoHandIcon.image = #imageLiteral(resourceName: "handMode")
                self.handModeView.isHidden = false
            } else {
                self.autoHandIcon.rotate360Degrees(animate: true)
                self.autoHandIcon.image = #imageLiteral(resourceName: "autoMode")
                self.handModeView.isHidden = true
            }
        })
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FACILITY_LIGHTS_STATUS.register), completion: { (success, response) in
            
            guard success == true else { return }
            
            self.lightState = Int(truncating: response![0] as! NSNumber)
            
            if self.lightState == 1{
                self.autoHandBtn.setImage(#imageLiteral(resourceName: "lights_on"), for: .normal)
                self.handSwitch.isOn = true
            } else {
                self.autoHandBtn.setImage(#imageLiteral(resourceName: "lights"), for: .normal)
                self.handSwitch.isOn = false
            }
        })
        CENTRAL_SYSTEM?.readRegister(length: 1, startingRegister: Int32(FACILITY_LIGHTS_HOA_STATUS.register), completion: { (success, response) in
            
            guard success == true else { return }
            let hoaStatus = Int(truncating: response![0] as! NSNumber)
            
            if hoaStatus == 0{
               self.hoaStatusLbl.text = "AUTO MODE"
            } else if hoaStatus == 1{
               self.hoaStatusLbl.text = "HAND MODE OFF"
            } else if hoaStatus == 2{
               self.hoaStatusLbl.text = "HAND MODE ON"
            }
        })
        autoHandIcon.rotate360Degrees(animate: true)
    }
    @IBAction func turnOnOfffSwitch(_ sender: UISwitch) {
        if self.lightState == 0{
            CENTRAL_SYSTEM?.writeBit(bit: FACILITY_LIGHTS_ON_OFF_WRITE_REGISTERS.register, value: 1)
        } else {
            CENTRAL_SYSTEM?.writeBit(bit: FACILITY_LIGHTS_ON_OFF_WRITE_REGISTERS.register, value: 0)
        }
    }
    
    @IBAction func toggleAutoHandMode(_ sender: UIButton) {
        if self.autoHandStatus == 1{
            CENTRAL_SYSTEM?.writeBit(bit: FACILITY_AUTO_HAND_PLC_REGISTER.register, value: 0)
        } else {
            CENTRAL_SYSTEM?.writeBit(bit: FACILITY_AUTO_HAND_PLC_REGISTER.register, value: 1)
        }
    }
}
