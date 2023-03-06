//=================================== ABOUT ===================================

/*
 *  @FILE:          WindViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all wind sensor data and allows to set the 
 *                  wind sensor settings and setpoints
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Wind Screen screen configuration parameters located in specs.swift file
 *     should be modified
 * 2 : If multiple wind sensors, the readings and data declerations need to be coppied
 ***************************************************************************/

import UIKit

class WindViewController: UIViewController{

    @IBOutlet weak var windStat: UIImageView!
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var windStatBtn: UIButton!
    //MARK: - Class Reference Objects -- Dependencies
    
    private let logger = Logger()
    private let helper = Helper()
    
    //MARK: - Data Structures
    
    private var langData = Dictionary<String, String>()
    private var windModel:Wind?
    private let wind_sensor_1   = WIND_SENSOR_1()  //If there are more wind sensors, this variable needs to be duplicated and number incremented
    private let wind_sensor_2   = WIND_SENSOR_2()
    private let wind_sensor_3   = WIND_SENSOR_3()
    
    private var wind_sensors:Array<Any>?
    private var wind_sensors2:Array<Any>?
    
    private var sensorNumber    = 0
    private var counter         = 0
    private var aboveHigh       = 0
    private var belowLow        = 0
    var windId = 0
    private var windChannelFaults: [Int] = []
    private var centralSystem = CentralSystem()
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        wind_sensors  = [wind_sensor_1,wind_sensor_2,wind_sensor_3]
   
    }
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    override func viewWillAppear(_ animated: Bool){
        //Get Wind Parameters From Local Storage
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        getWindParameters()
        
        //Configure Wind  Screen
        constructWindSensorMeters()
        
        //Configure Wind Screen Text Content Based On Device Language
        configureScreenTextContent()
        if windId == 1{
            self.windStatBtn.setTitle("ST - 1001", for: .normal)
        } else if windId == 2{
            self.windStatBtn.setTitle("ST - 2001", for: .normal)
        } else if windId == 3{
            self.windStatBtn.setTitle("ST - 3001", for: .normal)
        }
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)

    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
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
            readWindSensorData()
            getChannelFaults()
            
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
     * Function :  getWindParameters
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/
         
    private func getWindParameters(){
        
        //Fetch Wind Settings From Local Core Data Storage
        let wind = Wind.all() as! [Wind]
        
        self.logger.logData(data: "WIND - MODEL COUNT -> \(wind.count)")
        
        guard wind.count != 0 else{
            return
        }
        
        windModel = wind[0] as Wind
    
    }

    /***************************************************************************
     * Function :  configureScreenTextContent
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func configureScreenTextContent(){
        
        langData = self.helper.getLanguageSettigns(screenName: WIND_SCREEN_LANGUAGE_DATA_PARAM)
        
        guard windModel != nil else{
            
            self.logger.logData(data: "WIND: WIND MODEL EMPTY")
            
            //If the wind model is empty, put default parameters to avoid system crash
            self.navigationItem.title = langData["WIND"]!
            
            return
            
        }
        
        self.navigationItem.title = langData["WIND"]!
    }

    /***************************************************************************
     * Function :  constructWindSensorMeters
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func constructWindSensorMeters(){
        
        guard windModel != nil else{
            return
        }
    
        //Set Speed Unit Of Measure
        //self.setWindSpeedUnitOfMeasure(metric: windModel!.metric, labelTag: WIND_SPEED_MEASURE_UNIT_1_UI_TAG)

        //Enable Disable Setpoint Button
        self.enableDisableSetPoints(setPointEnabled: self.windModel!.enableSetPoints, buttonTag: WIND_SET_POINT_ENABLE_BTN_1_UI_TAG)

    }
    
    /***************************************************************************
     * Function :  setWindSpeedUnitOfMeasure
     * Input    :  metric yes/no, ui label tag
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func setWindSpeedUnitOfMeasure(metric:Bool,labelTag:Int){
    
        let sensorMetricLbl = self.view.viewWithTag(labelTag) as! UILabel

        if metric == true{
            
            sensorMetricLbl.text = "KM/H"
            
        }else{
            
            sensorMetricLbl.text = "MPH"

        }
        
    }
    
    /***************************************************************************
     * Function :  enableDisableSetPoints
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/

    private func enableDisableSetPoints(setPointEnabled:Bool,buttonTag:Int){
        
        let setPointButton = self.view.viewWithTag(buttonTag) as! UIButton
        
        if setPointEnabled == true{
            
            setPointButton.isHidden = false
            
        }else{
            
            setPointButton.isHidden = true
            
        }
        
    }
    
    /***************************************************************************
     * Function :  readWindSensorData
     * Input    :  none
     * Output   :  none
     * Comment  :  read all wind sensor speed data
     ***************************************************************************/
    
    private func readWindSensorData(){
        
        if windId == 1{
            self.readWindSpeed(register: self.wind_sensor_1.SPEED_SCALED_VALUE.register, labelTag: WIND_SPEED_1_UI_TAG)
            //Read wind direction for all wind sensors
            self.readWindDirection(register: self.wind_sensor_1.DIRECTION_SCALED_VALUE.register, directionTag: WIND_DIRECTION_1_UI_TAG)
        } else if windId == 2{
            self.readWindSpeed(register: self.wind_sensor_2.SPEED_SCALED_VALUE.register, labelTag: WIND_SPEED_1_UI_TAG)
            //Read wind direction for all wind sensors
            self.readWindDirection(register: self.wind_sensor_2.DIRECTION_SCALED_VALUE.register, directionTag: WIND_DIRECTION_1_UI_TAG)
        } else if windId == 3{
            self.readWindSpeed(register: self.wind_sensor_3.SPEED_SCALED_VALUE.register, labelTag: WIND_SPEED_1_UI_TAG)
            //Read wind direction for all wind sensors
            self.readWindDirection(register: self.wind_sensor_3.DIRECTION_SCALED_VALUE.register, directionTag: WIND_DIRECTION_1_UI_TAG)
        }
        
    }
    
    /***************************************************************************
     * Function :  getChannelFaults
     * Input    :  none
     * Output   :  none
     * Comment  :  might include few wind sensor readings
     ***************************************************************************/

    private func getChannelFaults(){
        
        if windId == 1{
            self.readChannelFault(register: self.wind_sensor_1.DIRECTION_CHANNEL_FAULT.register)
            self.readChannelFault(register: self.wind_sensor_1.SPEED_CHANNEL_FAULT.register)
        } else if windId == 2{
           self.readChannelFault(register: self.wind_sensor_2.DIRECTION_CHANNEL_FAULT.register)
            self.readChannelFault(register: self.wind_sensor_2.SPEED_CHANNEL_FAULT.register)
        } else if windId == 3{
            self.readChannelFault(register: self.wind_sensor_3.DIRECTION_CHANNEL_FAULT.register)
            self.readChannelFault(register: self.wind_sensor_3.SPEED_CHANNEL_FAULT.register)
        }
        
        if windChannelFaults.contains(1) {
            windStat.image = #imageLiteral(resourceName: "windicon")
            
        } else {
            windStat.image = #imageLiteral(resourceName: "wind_icon")
        }

    }
    
    /***************************************************************************
     * Function :  readChannelFault
     * Input    :  channel fault PLC Address
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readChannelFault(register: Int){
        
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(register), completion:{ (success, response) in
        
            guard success == true else { return }
            
            if self.windChannelFaults.count == 2 {
                self.windChannelFaults.removeAll()
                
            }
            
            let channelFault = Int(truncating: response![0] as! NSNumber)
            
            self.windChannelFaults.append(channelFault)
            
        })
    }
    
    /***************************************************************************
     * Function :  readWindSpeed
     * Input    :  speed plc address, speed label ui tag
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readWindSpeed(register:Int, labelTag:Int){
        
        guard windModel != nil else{
            return
        }
        
        if windId == 1{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_1.SPEED_ABOVE_HIGH.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let aboveHighValue = Int(truncating: response![0] as! NSNumber)
                self.aboveHigh = aboveHighValue
                
            })
            
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_1.SPEED_BELOW_LOW.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let belowLowValue = Int(truncating: response![0] as! NSNumber)
                self.belowLow = belowLowValue
                
            })
        } else if windId == 2{
           CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_2.SPEED_ABOVE_HIGH.register), completion:{ (success, response) in
               
               guard success == true else{return}
               let aboveHighValue = Int(truncating: response![0] as! NSNumber)
               self.aboveHigh = aboveHighValue
               
           })
           
           CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_2.SPEED_BELOW_LOW.register), completion:{ (success, response) in
               
               guard success == true else{return}
               let belowLowValue = Int(truncating: response![0] as! NSNumber)
               self.belowLow = belowLowValue
               
           })
        } else if windId == 3{
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_3.SPEED_ABOVE_HIGH.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let aboveHighValue = Int(truncating: response![0] as! NSNumber)
                self.aboveHigh = aboveHighValue
                
            })
            
            CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(self.wind_sensor_3.SPEED_BELOW_LOW.register), completion:{ (success, response) in
                
                guard success == true else{return}
                let belowLowValue = Int(truncating: response![0] as! NSNumber)
                self.belowLow = belowLowValue
                
            })
        }
        
        
        CENTRAL_SYSTEM!.readRealRegister(register: register, length: 2){ (success, response)  in
            
            //We want to make sure the PLC read was successfull and we did not get empty response
            
            guard success == true else{
                return
            }
            
            let windSpeedLbl = self.view.viewWithTag(labelTag) as! UILabel

            if self.windModel!.metric == true{

                let metricValue  = Float(response)! * 1.609344
                windSpeedLbl.text = "\(round(10 * metricValue)/10)"

            }else{

                windSpeedLbl.text = "\(round(10*(Float(response)!))/10)"

            }
            
            self.changeWindSpeedColor(labelTag: labelTag)
            
        }
        
        
    }
    
    /***************************************************************************
     * Function :  changeWindSpeedColor
     * Input    :  none
     * Output   :  none
     * Comment  :  Change the wind speed indicator color based on current value
     ***************************************************************************/
    
    private func changeWindSpeedColor(labelTag:Int){
        
        let windSpeedLbl = self.view.viewWithTag(labelTag) as! UILabel

        if self.aboveHigh == 1{
            windSpeedLbl.textColor = RED_COLOR
        }else if self.belowLow == 1 {
            windSpeedLbl.textColor = GREEN_COLOR
        }else if self.aboveHigh == 0 && self.belowLow == 0{
            windSpeedLbl.textColor = ORANGE_COLOR
        }
        
    }
    
    /***************************************************************************
     * Function :  readWindDirection
     * Input    :  direction plc address, direction ui tag
     * Output   :  none
     * Comment  : 
     ***************************************************************************/

    private func readWindDirection(register:Int, directionTag:Int){
        
       CENTRAL_SYSTEM!.readRealRegister(register: register, length: 2){ (success, response)  in
            
            //We want to make sure the PLC read was successfull and we did not get empty response
            guard success == true else{
                return
            }
        
            self.logger.logData(data: "RECIEVING  DIRECTION : \(response)")
        
            //Calculate wind speed direction
            let rotationAngle = (Float(response)! * 0.0174533) 
        
            let directionImage = self.view.viewWithTag(directionTag) as! UIImageView
            directionImage.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngle))
            
        }
    }

    /***************************************************************************
     * Function :  showSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :  This function constructs the popup view for wind setpoins
     ***************************************************************************/

    @IBAction func showSetpoints(_ sender: UIButton){
        
        let storyboard = UIStoryboard(name: "wind", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "windDetails") as! WindAnemometerViewController
        popoverContent.sensorNumber = windId
        popoverContent.wind_sensors = wind_sensors
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popover?.permittedArrowDirections = .up
        popoverContent.preferredContentSize = CGSize(width: 470, height: 550)
        popover?.sourceView = sender
        
        self.present(nav, animated: true, completion: nil)
        
    }

 
}
