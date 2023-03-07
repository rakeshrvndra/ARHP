//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterLevelViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all water level sensor values and
 *                  displays on the screen
 *  @VERSION:       2.0.0
 */

/***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Level screen configuration parameters located in specs.swift file
 *     should be modified
 * 2 : readWaterLevelLiveValues function should be modified based on required
 *     value readings
 * 3 : Basin images should be replaced according to project drawings.
 *     Note: The image names should remain the same as what is provied in the
 *           project workspace image files
 * 4 : parseWaterLevelFaults() function should be modified based on required
 *     fault readings
 ***************************************************************************/


import UIKit


class WaterLevelViewController: UIViewController{
    
    //MARK: - UI View Outlets
    
    @IBOutlet weak var waterLevelIcon:                      UIImageView!
    @IBOutlet weak var noConnectionView:                    UIView!
    @IBOutlet weak var noConnectionErrorLbl:                UILabel!
    
    //MARK: - Water Level Sensors Faults
    @IBOutlet weak var lt1001View: UIView!
    @IBOutlet weak var lt2001View: UIView!
    @IBOutlet weak var lt3001View: UIView!
    
    @IBOutlet weak var lowWaterNoShow: UIImageView!
    @IBOutlet weak var lowWaterNoLights:                    UIImageView!
    @IBOutlet weak var fillTimeout:                         UIImageView!
    @IBOutlet weak var waterMakeupFaucet:                   UIImageView!
    
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger          =          Logger()
    private let helper          =          Helper()
    private let utility         =         Utilits()
    private let operationManual = OperationManual()
    
    //MARK: - Data Structures
    
    private var langData          = Dictionary<String, String>()
    private var lt1001liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
    private var lt2001liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
    private var lt3001liveSensorValues  = WATER_LEVEL_SENSOR_VALUES()
    private var centralSystem = CentralSystem()
    private var acquiredTimersFromPLC = 0
    
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
         //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(WaterLevelViewController.checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        //Configure Water Level Screen
        configureWaterLevel()
        
        //Configure WaterLeveScreen Text Content Based On Device Language
        configureScreenTextContent()

        
    }
    
    /***************************************************************************
     * Function :  viewDidDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection,_) = (CENTRAL_SYSTEM?.getConnectivityStat())!
        
        if plcConnection == CONNECTION_STATE_CONNECTED {
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            noConnectionView.isUserInteractionEnabled = false
            
            //Now that the connection is established, run functions
            parseWaterLevelFaults()
            readWaterLevelLiveValues()
            
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
    
    

    /***************************************************************************
     * Function :  configureWaterLevel
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func configureWaterLevel(){
        
        lowWaterNoLights.isHidden = true
        acquiredTimersFromPLC = 0
        
    }
    
    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: WATER_LEVEL_LANGUAGE_DATA_PARAM)
        self.navigationItem.title = "WATER LEVEL"
               
    }
    
 
    
    /***************************************************************************
     * Function :  readWaterLevelLiveValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func readWaterLevelLiveValues(){
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_1.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_1.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL FAILED TO GET RESPONSE FROM PLC")
                return
            }
            self.lt1001liveSensorValues.channelFault           = Int(truncating: response![0] as! NSNumber)
            self.lt1001liveSensorValues.above_High            = Int(truncating: response![1] as! NSNumber)
            self.lt1001liveSensorValues.below_l               = Int(truncating: response![2] as! NSNumber)
            self.lt1001liveSensorValues.below_ll              = Int(truncating: response![3] as! NSNumber)
            self.lt1001liveSensorValues.waterMakeupTimeout    = Int(truncating: response![5] as! NSNumber)
            self.lt1001liveSensorValues.waterMakeup           = Int(truncating: response![6] as! NSNumber)
            
            CENTRAL_SYSTEM!.readRealRegister(register: WATER_LEVEL_LT1001_SCALED_VALUE_BIT, length: 2){ (success, response)  in
                       
               guard success == true else{
                   return
               }
               self.lt1001liveSensorValues.scaledValue = Double(response)!
                self.parseLT1001Data()
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_2.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_2.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL FAILED TO GET RESPONSE FROM PLC")
                return
            }
            self.lt2001liveSensorValues.channelFault           = Int(truncating: response![0] as! NSNumber)
            self.lt2001liveSensorValues.above_High            = Int(truncating: response![1] as! NSNumber)
            self.lt2001liveSensorValues.below_l               = Int(truncating: response![2] as! NSNumber)
            self.lt2001liveSensorValues.below_ll              = Int(truncating: response![3] as! NSNumber)
            self.lt2001liveSensorValues.waterMakeupTimeout    = Int(truncating: response![5] as! NSNumber)
            self.lt2001liveSensorValues.waterMakeup           = Int(truncating: response![6] as! NSNumber)
            
            CENTRAL_SYSTEM!.readRealRegister(register: WATER_LEVEL_LT2001_SCALED_VALUE_BIT, length: 2){ (success, response)  in
                       
               guard success == true else{
                   return
               }
               self.lt2001liveSensorValues.scaledValue = Double(response)!
                self.parseLT2001Data()
            }
            
        })
        
        CENTRAL_SYSTEM?.readBits(length: Int32(WATER_LEVEL_SENSOR_BITS_3.count) , startingRegister: Int32(WATER_LEVEL_SENSOR_BITS_3.startBit), completion: { (sucess, response) in
            
            //Check points to make sure the PLC Call was successful
            
            guard sucess == true else{
                self.logger.logData(data: "WATER LEVEL FAILED TO GET RESPONSE FROM PLC")
                return
            }
            self.lt3001liveSensorValues.channelFault           = Int(truncating: response![0] as! NSNumber)
            self.lt3001liveSensorValues.above_High            = Int(truncating: response![1] as! NSNumber)
            self.lt3001liveSensorValues.below_l               = Int(truncating: response![2] as! NSNumber)
            self.lt3001liveSensorValues.below_ll              = Int(truncating: response![3] as! NSNumber)
            self.lt3001liveSensorValues.waterMakeupTimeout    = Int(truncating: response![5] as! NSNumber)
            self.lt3001liveSensorValues.waterMakeup           = Int(truncating: response![6] as! NSNumber)
            
            CENTRAL_SYSTEM!.readRealRegister(register: WATER_LEVEL_LT3001_SCALED_VALUE_BIT, length: 2){ (success, response)  in
                       
               guard success == true else{
                   return
               }
               self.lt3001liveSensorValues.scaledValue = Double(response)!
                self.parseLT3001Data()
            }
            
        })
        
    }
    
    
    /***************************************************************************
     * Function :  parseWaterLevelFaults
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func parseWaterLevelFaults(){
        
        if lt1001liveSensorValues.channelFault == 1 || lt2001liveSensorValues.channelFault == 1 || lt3001liveSensorValues.channelFault == 1{
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-red")
        } else {
            waterLevelIcon.image = #imageLiteral(resourceName: "waterlevel_outline-gray")
        }
        
        //Is there any condition
        
//        if liveSensorValues.lsll1101below_ll == 1 || liveSensorValues.lsll1301below_ll == 1 || liveSensorValues.lsll1401below_ll == 1 || liveSensorValues.lsll1501below_ll == 1 || liveSensorValues.lsll1601below_ll == 1 {
//            lowWaterNoLights.isHidden = false
//        } else {
//            lowWaterNoLights.isHidden = true
//        }
        
        if  lt1001liveSensorValues.below_ll == 1 || lt2001liveSensorValues.below_ll == 1 || lt3001liveSensorValues.below_ll == 1
        {
            lowWaterNoShow.alpha = 1
        } else
        {
            lowWaterNoShow.alpha = 0
        }
        
        if lt1001liveSensorValues.waterMakeupTimeout == 1 || lt2001liveSensorValues.waterMakeupTimeout == 1 || lt3001liveSensorValues.waterMakeupTimeout == 1{
            fillTimeout.alpha = 1
        } else {
            fillTimeout.alpha = 0
        }
    }
    
    func parseLT1001Data(){
        
               let scaledValue = self.lt1001View.viewWithTag(2001) as? UILabel
               let abvH = self.lt1001View.viewWithTag(2002) as? UIImageView
               let blwL = self.lt1001View.viewWithTag(2003) as? UIImageView
               let blwLL = self.lt1001View.viewWithTag(2004) as? UIImageView
               let chFault = self.lt1001View.viewWithTag(2005) as? UIImageView
               let makeupOn = self.lt1001View.viewWithTag(2006) as? UILabel
               let makeupTimeout = self.lt1001View.viewWithTag(2007) as? UIImageView
        
               scaledValue?.text = String(format: "%.1f", self.lt1001liveSensorValues.scaledValue)
        
               if self.lt1001liveSensorValues.above_High == 1
               {
                   abvH?.image = #imageLiteral(resourceName: "red")
               } else {
                   abvH?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt1001liveSensorValues.below_l == 1
               {
                   blwL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwL?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt1001liveSensorValues.below_ll == 1
               {
                   blwLL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwLL?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt1001liveSensorValues.channelFault == 1
               {
                   chFault?.image = #imageLiteral(resourceName: "red")
               } else {
                   chFault?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt1001liveSensorValues.waterMakeup == 1 {
                   makeupOn?.text = "ON"
               } else {
                   makeupOn?.text = "OFF"
               }
        
               if self.lt1001liveSensorValues.waterMakeupTimeout == 1 {
                   makeupTimeout?.image = #imageLiteral(resourceName: "red")
               } else {
                   makeupTimeout?.image = #imageLiteral(resourceName: "green")
               }
    }
    
    func parseLT2001Data(){
        
               let scaledValue = self.lt2001View.viewWithTag(2001) as? UILabel
               let abvH = self.lt2001View.viewWithTag(2002) as? UIImageView
               let blwL = self.lt2001View.viewWithTag(2003) as? UIImageView
               let blwLL = self.lt2001View.viewWithTag(2004) as? UIImageView
               let chFault = self.lt2001View.viewWithTag(2005) as? UIImageView
               let makeupOn = self.lt2001View.viewWithTag(2006) as? UILabel
               let makeupTimeout = self.lt2001View.viewWithTag(2007) as? UIImageView
        
               scaledValue?.text = String(format: "%.1f", self.lt2001liveSensorValues.scaledValue)
        
               if self.lt2001liveSensorValues.above_High == 1
               {
                   abvH?.image = #imageLiteral(resourceName: "red")
               } else {
                   abvH?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt2001liveSensorValues.below_l == 1
               {
                   blwL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwL?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt2001liveSensorValues.below_ll == 1
               {
                   blwLL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwLL?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt2001liveSensorValues.channelFault == 1
               {
                   chFault?.image = #imageLiteral(resourceName: "red")
               } else {
                   chFault?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt2001liveSensorValues.waterMakeup == 1 {
                   makeupOn?.text = "ON"
               } else {
                   makeupOn?.text = "OFF"
               }
        
               if self.lt2001liveSensorValues.waterMakeupTimeout == 1 {
                   makeupTimeout?.image = #imageLiteral(resourceName: "red")
               } else {
                   makeupTimeout?.image = #imageLiteral(resourceName: "green")
               }
    }
    
    func parseLT3001Data(){
        
               let scaledValue = self.lt3001View.viewWithTag(2001) as? UILabel
               let abvH = self.lt3001View.viewWithTag(2002) as? UIImageView
               let blwL = self.lt3001View.viewWithTag(2003) as? UIImageView
               let blwLL = self.lt3001View.viewWithTag(2004) as? UIImageView
               let chFault = self.lt3001View.viewWithTag(2005) as? UIImageView
               let makeupOn = self.lt3001View.viewWithTag(2006) as? UILabel
               let makeupTimeout = self.lt3001View.viewWithTag(2007) as? UIImageView
        
               scaledValue?.text = String(format: "%.1f", self.lt3001liveSensorValues.scaledValue)
        
               if self.lt3001liveSensorValues.above_High == 1
               {
                   abvH?.image = #imageLiteral(resourceName: "red")
               } else {
                   abvH?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt3001liveSensorValues.below_l == 1
               {
                   blwL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwL?.image = #imageLiteral(resourceName: "green")
               }
               
               if self.lt3001liveSensorValues.below_ll == 1
               {
                   blwLL?.image = #imageLiteral(resourceName: "red")
               } else {
                   blwLL?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt3001liveSensorValues.channelFault == 1
               {
                   chFault?.image = #imageLiteral(resourceName: "red")
               } else {
                   chFault?.image = #imageLiteral(resourceName: "green")
               }
        
               if self.lt3001liveSensorValues.waterMakeup == 1 {
                   makeupOn?.text = "ON"
               } else {
                   makeupOn?.text = "OFF"
               }
        
               if self.lt3001liveSensorValues.waterMakeupTimeout == 1 {
                   makeupTimeout?.image = #imageLiteral(resourceName: "red")
               } else {
                   makeupTimeout?.image = #imageLiteral(resourceName: "green")
               }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
       self.addAlertAction(button: sender)
    }
}
