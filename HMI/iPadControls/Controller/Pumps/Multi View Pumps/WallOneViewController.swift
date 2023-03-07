//
//  WallOneViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 4/20/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class WallOneViewController: UIViewController {

      
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private var centralSystem = CentralSystem()
    private let helper = Helper()
    private let httpComm = HTTPComm()
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var pumpModel:Pump?
    private var is24hours = true
    private var iPadNumber = 0
    private var selectedPumpNumber = 0
    //MARK: - View Life Cycle
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
       
    }
    
    //MARK: - View Will Appear
    
    override func viewWillAppear(_ animated: Bool){
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        //Configure Pump Screen Text Content Based On Device Language
        configureScreenTextContent()
        
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    @objc func checkSystemStat(){
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            getPumpRunningStat()
            getPumpFaultStat()
        } else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrorLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrorLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrorLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
    }
    
    func getPumpRunningStat(){
        
        let offset = 14
        let tagNum = 101
        
        for index in 0..<9 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(WALL_1_SURGE_PUMPS_RUNNING_STATUS_START_REGISTER + (index*offset)), completion:{ (success, response) in
                if response != nil{
                    let tempstatus = Int(truncating: response![0] as! NSNumber)
                    self.parsePumpStatus(tag: tagNum + index, status: tempstatus)
                }
            })
        }
    }
    
    func parsePumpStatus(tag: Int, status: Int) {
        if tag != 109 {
            let tempbtn = self.view.viewWithTag(tag) as! UIButton
            status == 1 ? (tempbtn.setImage(#imageLiteral(resourceName: "pumps_on"), for: .normal)) : (tempbtn.setImage(#imageLiteral(resourceName: "pumps"), for: .normal))
        }
    }

    func getPumpFaultStat(){
        
        let offset = 14
        let tagNum = 1
        
        for index in 0..<9 {
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(WALL_1_SURGE_PUMPS_FAULT_STATUS_START_REGISTER + (index*offset)), completion:{ (success, response) in
                if response != nil{
                    let tempstatus = Int(truncating: response![0] as! NSNumber)
                    self.parsePumpFaults(tag: tagNum + index, status: tempstatus)
                }
            })
        }
    }
    
    func parsePumpFaults(tag: Int, status: Int) {
        if tag != 9 {
            let tempLbl = self.view.viewWithTag(tag) as! UILabel
            status == 1 ? (tempLbl.textColor = RED_COLOR) : (tempLbl.textColor = DEFAULT_GRAY)
        }
        
    }
    
    //MARK: - Configure Screen Text Content Based On Device Language
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: PUMPS_LANGUAGE_DATA_PARAM)
        
        guard pumpModel != nil else {
            
            self.logger.logData(data: "PUMPS: PUMP MODEL EMPTY")
            
            //If the pump model is empty, put default parameters to avoid system crash
            self.navigationItem.title = "WALL - 1 PUMPS"
            self.noConnectionErrorLbl.text = "CHECK SETTINGS"
            
            return
            
        }
        
        //Get iPad Number Specified On User Side
        
        let ipadNum = UserDefaults.standard.object(forKey: IPAD_NUMBER_USER_DEFAULTS_NAME) as? Int
        
        if ipadNum == nil || ipadNum == 0{
            self.iPadNumber = 1
        }else{
            self.iPadNumber = ipadNum!
        }
        
        self.setDefaultSelectedPumpNumber()
        
        self.navigationItem.title = langData[pumpModel!.screenName!]!
        self.noConnectionErrorLbl.text = pumpModel!.outOfRangeMessage!
        
    }

    //MARK: - By Default Set the current selected pump to 0
    
    private func setDefaultSelectedPumpNumber(){
        
        let registersSET1 = PUMP_SETS[iPadNumber-1]
        let iPadNumberRegister = registersSET1[0]
        CENTRAL_SYSTEM!.writeRegister(register: iPadNumberRegister.register, value: 0)
        
        
    }
    
    @IBAction func redirectToPumpDetails(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "pumps", bundle:nil)
               
        let pumpDetail = storyBoard.instantiateViewController(withIdentifier: "autoPumpDetail") as! AutoPumpDetailViewController
        pumpDetail.pumpNumber = sender.tag
        self.navigationController?.pushViewController(pumpDetail, animated: true)
        
    }
        
}
