//
//  PumpSchedulerViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit


class PumpSchedulerViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView:       UIView!
    @IBOutlet weak var schedulerContainerView: UIView!
    @IBOutlet weak var noConnectionErrorLabel: UILabel!
    @IBOutlet weak var fillerShowEnabledDisbaledLbl: UILabel!
    @IBOutlet weak var noteSchedulerData: UILabel!
    @IBOutlet weak var enableDisView: UIView!
    @IBOutlet weak var scheduleSwitch: UISwitch!
    
 
    private var shows: [Any]? = nil
    private var fillerShowStatus: Int = 0
    var currentFillerShowState  = 0
    var currentFillerShowNumber = 0
    var specialShowNumber       = 0
    var showNumberRead          = 0
    var schedulerTag            = 0
    private let logger   = Logger()
    private let httpComm = HTTPComm()
    var list:[String] = []
 
    
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
     * Function :  didReceiveMemoryWarning
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func didReceiveMemoryWarning(){
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        if CENTRAL_SYSTEM == nil{
            
            CENTRAL_SYSTEM = CentralSystem()
            
            //Initialize the central system so we can establish all the system config
            CENTRAL_SYSTEM?.initialize()
            CENTRAL_SYSTEM?.connect()
            
        }
        readPumpEnStatus()
        if schedulerTag == 55{
            self.enableDisView.isHidden = true
        } else {
            self.enableDisView.isHidden = false
        }
        if schedulerTag == 11{
            readServerPath = READ_SURGE_SERVER_PATH
            writeServerPath = WRITE_SURGE_SERVER_PATH
            self.navigationItem.title = "SURGE PUMPS SCHEDULER"
            self.noteSchedulerData.text = "PUMP 101-106,201-206 AND 301-306 ARE CONTROLLED BY THIS SCHEDULER"
        } else if schedulerTag == 22{
            readServerPath = READ_FILTRATION_SERVER_PATH
            writeServerPath = WRITE_FILTRATION_SERVER_PATH
            self.navigationItem.title = "FILTRATION PUMPS SCHEDULER"
            self.noteSchedulerData.text = "PUMP-109,209 AND 309 ARE CONTROLLED BY THIS SCHEDULER"
        }else if schedulerTag == 33{
            readServerPath = READ_DISPLAY_SERVER_PATH
            writeServerPath = WRITE_DISPLAY_SERVER_PATH
            self.navigationItem.title = "DISPLAY PUMPS SCHEDULER"
            self.noteSchedulerData.text = "PUMP-107,207 AND 307 ARE CONTROLLED BY THIS SCHEDULER"
        } else if schedulerTag == 44{
            readServerPath = READ_RUNNEL_SERVER_PATH
            writeServerPath = WRITE_RUNNEL_SERVER_PATH
            self.navigationItem.title = "RUNNEL PUMPS SCHEDULER"
            self.noteSchedulerData.text = "PUMP-108,208 AND 308 ARE CONTROLLED BY THIS SCHEDULER"
        } else if schedulerTag == 55{
            readServerPath = READ_PRJ_SERVER_PATH
            writeServerPath = WRITE_PRJ_SERVER_PATH
            self.navigationItem.title = "PROJECTOR LIFTS SCHEDULER"
            self.noteSchedulerData.text = "WALL 1,2,3 PROJECTORS CONTROLLED BY THIS SCHEDULER"
        }
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(PumpSchedulerViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        self.list.removeAll()
        
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
            
            
        } else {
            noConnectionView.alpha = 1
            
            if plcConnection == CONNECTION_STATE_FAILED || serverConnection == CONNECTION_STATE_FAILED {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLabel.text = "PLC CONNECTION FAILED, SERVER GOOD"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLabel.text = "SERVER CONNECTION FAILED, PLC GOOD"
                } else {
                    noConnectionErrorLabel.text = "SERVER AND PLC CONNECTION FAILED"
                }
            }
            
            if plcConnection == CONNECTION_STATE_CONNECTING || serverConnection == CONNECTION_STATE_CONNECTING {
                if serverConnection == CONNECTION_STATE_CONNECTED {
                    noConnectionErrorLabel.text = "CONNECTING TO PLC, SERVER CONNECTED"
                } else if plcConnection == CONNECTION_STATE_CONNECTED{
                    noConnectionErrorLabel.text = "CONNECTING TO SERVER, PLC CONNECTED"
                } else {
                    noConnectionErrorLabel.text = "CONNECTING TO SERVER AND PLC.."
                }
            }
            
            if plcConnection == CONNECTION_STATE_POOR_CONNECTION && serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "SERVER AND PLC POOR CONNECTION"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            } else if serverConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLabel.text = "SERVER POOR CONNECTION, PLC CONNECTED"
            }
        }
    }
    
 
    @IBAction func toggleSwitchOnOff(_ sender: UISwitch) {
        if schedulerTag == 22{
            
            if scheduleSwitch.isOn{
                CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_PUMP_EN, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeBit(bit: FILTRATION_PUMP_EN, value: 0)
            }
           
        } else if schedulerTag == 11{
            if scheduleSwitch.isOn{
                CENTRAL_SYSTEM?.writeBit(bit: SURGE_PUMP_EN, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeBit(bit: SURGE_PUMP_EN, value: 0)
            }
        } else if schedulerTag == 33{
            if scheduleSwitch.isOn{
                CENTRAL_SYSTEM?.writeBit(bit: DISPLAY_PUMP_EN, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeBit(bit: DISPLAY_PUMP_EN, value: 0)
            }
        }else if schedulerTag == 44{
            if scheduleSwitch.isOn{
                CENTRAL_SYSTEM?.writeBit(bit: RUNNEL_PUMP_EN, value: 1)
            } else {
                CENTRAL_SYSTEM?.writeBit(bit: RUNNEL_PUMP_EN, value: 0)
            }
        }
        readPumpEnStatus()
    }
    
 
  
    
    func readPumpEnStatus(){
        if schedulerTag == 22{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(FILTRATION_PUMP_EN), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 1{
                    self.scheduleSwitch.isOn = true
                } else {
                    self.scheduleSwitch.isOn = false
                }
            })
        } else if schedulerTag == 11{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(SURGE_PUMP_EN), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 1{
                    self.scheduleSwitch.isOn = true
                } else {
                    self.scheduleSwitch.isOn = false
                }
            })
        } else if schedulerTag == 33{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(DISPLAY_PUMP_EN), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 1{
                    self.scheduleSwitch.isOn = true
                } else {
                    self.scheduleSwitch.isOn = false
                }
            })
        } else if schedulerTag == 44{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(RUNNEL_PUMP_EN), completion: { (success, response) in
                
                guard success == true else { return }
                
                let status = Int(truncating: response![0] as! NSNumber)
                
                if status == 1{
                    self.scheduleSwitch.isOn = true
                } else {
                    self.scheduleSwitch.isOn = false
                }
            })
        }
    }
   
    
}
