//
//  WindAnemometerViewController.swift
//  iPadControls
//
//  Created by Arpi Derm on 12/22/16.
//  Copyright © 2016 WET. All rights reserved.
//

import UIKit

class WindAnemometerViewController: UIViewController,UIGestureRecognizerDelegate{
    
    
    //MARK: - Class Reference Objects -- Dependencies
    private let logger = Logger()
    private let helper = Helper()
    
    var connection          = 0
    var sensorNumber        = 0
    var fetchedSetpoints    = 0
    var wind_sensors:  Array<Any>?
    var wind_sensors2: Array<Any>?
    var pixelsPerUnit       = 0.0
    var aboveHigh           = 0.0
    var belowLow            = 0.0
    var highSP              = 0
    var lowSP               = 0    
    var abortSetPoint       = 0.0
    
    var belowylocation:CGFloat     = 0.0
    var aboveylocation:CGFloat     = 0.0
    
    var currentAbortSetpointRegister = 0
    var aboveSetPoint: UIPanGestureRecognizer!
    var belowSetPoint: UIPanGestureRecognizer!
    
    @IBOutlet weak var abortSPView: UIView!
    @IBOutlet weak var belowLView: UIView!
    @IBOutlet weak var abortSetpointLbl:    UILabel!
    @IBOutlet weak var windSpeedIndicator:  UIView!
    @IBOutlet weak var windSpeedLbl:        UILabel!
    @IBOutlet weak var rangeBackground:     UIView!
    @IBOutlet weak var upperrangeBackground: UIView!
    @IBOutlet weak var lowerrangeBackground: UIView!
    @IBOutlet weak var aboveHView: UIView!
    @IBOutlet weak var abortSPTextField: UITextField!
    private var centralSystem = CentralSystem()
    @IBOutlet weak var aboveSP: UILabel!
    @IBOutlet weak var belowSP: UILabel!
    
    
    
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
    
    }
    
    private func initializePumpGestureRecognizer(){
        
        //RME: Initiate PUMP Flow Control Gesture Handler
        
        aboveSetPoint = UIPanGestureRecognizer(target: self, action: #selector(changeAboveSP(sender:)))
        belowSetPoint = UIPanGestureRecognizer(target: self, action: #selector(changeBelowSP(sender:)))
        aboveHView.isUserInteractionEnabled = true
        aboveHView.addGestureRecognizer(self.aboveSetPoint)
        aboveSetPoint.delegate = self
        belowLView.isUserInteractionEnabled = true
        belowLView.addGestureRecognizer(self.belowSetPoint)
        belowSetPoint.delegate = self
        
    }
    
    @objc func changeAboveSP(sender: UIPanGestureRecognizer){
        
        aboveHView.isUserInteractionEnabled = true
        aboveSP.textColor = GREEN_COLOR
        var touchLocation:CGPoint = sender.location(in: self.view)
        if touchLocation.y <= 35.8 {
            touchLocation.y = 35.8
        }
        if touchLocation.y > 35.7 && touchLocation.y <= belowylocation - 8.62 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 467 - Int(touchLocation.y)
            let herts = Double(flowRange)/(self.pixelsPerUnit)
            let formattedHerts = String(format: "%.1f", herts)
            //NOTE: We multiply the frequency by 10 because PLC expects 3 digit number
            
            aboveSP.text = formattedHerts
            
            if sender.state == .ended {
                aboveylocation = CGFloat(touchLocation.y)
                CENTRAL_SYSTEM?.writeRealValue(register: self.highSP, value: Float(formattedHerts)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                    self.readSetpointAgain()
                }
            }
        } else {
            aboveSP.textColor = RED_COLOR
        }
    }
    
    @objc func changeBelowSP(sender: UIPanGestureRecognizer){
        
        belowLView.isUserInteractionEnabled = true
        belowSP.textColor = GREEN_COLOR
        var touchLocation:CGPoint = sender.location(in: self.view)
        print(touchLocation.y)
        if touchLocation.y >= 467 {
            touchLocation.y = 467
        }
        if touchLocation.y >= aboveylocation + 25.86 && touchLocation.y < 468 {
            
            sender.view?.center.y = touchLocation.y
            
            let flowRange = 467 - Int(touchLocation.y)
            let herts = Double(flowRange)/(self.pixelsPerUnit)
            let formattedHerts = String(format: "%.1f", herts)
            //NOTE: We multiply the frequency by 10 because PLC expects 3 digit number
            
            
            belowSP.text = formattedHerts
            
            if sender.state == .ended {
                belowylocation = CGFloat(touchLocation.y)
                CENTRAL_SYSTEM?.writeRealValue(register: self.lowSP, value: Float(formattedHerts)!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                    self.readSetpointAgain()
                }
            }
        } else {
            belowSP.textColor = RED_COLOR
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        //Uncomment the below line to make changes to the AbortsetPoint
        centralSystem.getNetworkParameters()
        centralSystem.connect()
        CENTRAL_SYSTEM = centralSystem
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        initializePumpGestureRecognizer()
        
    }
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/   
    
    @objc private func checkSystemStat(){
        
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        self.connection = plcConnection
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            self.getCurrentWindSpeed()
            
        }
        
    }
    
    
    /***************************************************************************
     * Function :  getCurrentWindSpeed
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/   
    
    private func getCurrentWindSpeed(){
        
        //TODO: Find a way to not make PLC calls again. Just get it from previous page
        
        
        switch sensorNumber{
            
        case 1:
            let windSensor1 = wind_sensors?[0] as! WIND_SENSOR_1
            self.currentAbortSetpointRegister = windSensor1.SPEED_ABORT_SET_POINT.register
            self.highSP = windSensor1.SPEED_HIGH_SET_POINT.register
            self.lowSP = windSensor1.SPEED_LOW_SET_POINT.register
            self.getWindSpeedReading(windSpeedRegister: windSensor1.SPEED_SCALED_VALUE.register, windAbortSetpoint: windSensor1.SPEED_ABORT_SET_POINT.register, aboveHigh:windSensor1.SPEED_HIGH_SET_POINT.register,belowLow: windSensor1.SPEED_LOW_SET_POINT.register)
        case 2:
            let windSensor2 = wind_sensors?[1] as! WIND_SENSOR_2
            self.currentAbortSetpointRegister = windSensor2.SPEED_ABORT_SET_POINT.register
            self.highSP = windSensor2.SPEED_HIGH_SET_POINT.register
            self.lowSP = windSensor2.SPEED_LOW_SET_POINT.register
            self.getWindSpeedReading(windSpeedRegister: windSensor2.SPEED_SCALED_VALUE.register, windAbortSetpoint: windSensor2.SPEED_ABORT_SET_POINT.register, aboveHigh:windSensor2.SPEED_HIGH_SET_POINT.register,belowLow: windSensor2.SPEED_LOW_SET_POINT.register)
            
        case 3:
            let windSensor3 = wind_sensors?[2] as! WIND_SENSOR_3
            self.currentAbortSetpointRegister = windSensor3.SPEED_ABORT_SET_POINT.register
            self.highSP = windSensor3.SPEED_HIGH_SET_POINT.register
            self.lowSP = windSensor3.SPEED_LOW_SET_POINT.register
            self.getWindSpeedReading(windSpeedRegister: windSensor3.SPEED_SCALED_VALUE.register, windAbortSetpoint: windSensor3.SPEED_ABORT_SET_POINT.register, aboveHigh:windSensor3.SPEED_HIGH_SET_POINT.register,belowLow: windSensor3.SPEED_LOW_SET_POINT.register)
        default:
            
            self.logger.logData(data: "WIND SENSOR NOT FOUND")
            
        }
        
        
        
    }
    
    /***************************************************************************
     * Function :  getWindSpeedReading
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/   
    
    private func getWindSpeedReading(windSpeedRegister:Int, windAbortSetpoint:Int, aboveHigh:Int, belowLow:Int){
        
        if self.fetchedSetpoints != 1{
            self.readSetpoints(aboveHighSetPoint: aboveHigh, belowLowSetpoint: belowLow, abortSP: windAbortSetpoint)
            
            self.fetchedSetpoints = 1
            
        }else{
            
            CENTRAL_SYSTEM!.readRealRegister(register: windSpeedRegister, length: 2){ (success, response)  in
                
                guard success == true else{
                    return
                }
                
                let windSpeed = Double(response)!
                self.windSpeedLbl.text = String(format: "%.1f", windSpeed)
                let windSpeedYPosition = (windSpeed * self.pixelsPerUnit)
                
                if windSpeed >= self.abortSetPoint {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 26, width: 102, height: 23)
                } else if windSpeed <= 0 {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 455, width: 102, height: 23)
                } else {
                    self.windSpeedIndicator.frame = CGRect(x: 20, y: 455 - windSpeedYPosition, width: 102, height: 23)
                }
            }
        }
        
    }
    
    
    /***************************************************************************
     * Function :  readSetpoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/   
    
    private func readSetpoints(aboveHighSetPoint: Int, belowLowSetpoint: Int, abortSP: Int){
        CENTRAL_SYSTEM!.readRealRegister(register: abortSP, length: 2){ (success, response)  in
            
            guard success == true else{
                return
            }
            
            self.abortSetPoint = Double(response)!
            
            let abortSPValue = String(format: "%.1f", self.abortSetPoint)
            
            if self.abortSetpointLbl != nil {
                self.abortSetpointLbl.text =  abortSPValue
                print("current abort set point successful")
            }
            
        }
        
        
        print("above high sp is \(aboveHighSetPoint). below lo sp is \(belowLowSetpoint)")
        CENTRAL_SYSTEM!.readRealRegister(register: aboveHighSetPoint, length: 2){ (success, response)  in
            
            guard success == true else{
                return
            }
            
            self.aboveHigh = Double(response)!
            
            let aboveHigh = String(format: "%.1f", self.aboveHigh)
            self.aboveSP.text =  aboveHigh
            self.aboveSP.textColor = DEFAULT_GRAY
            
            print("above high set point successful. above high sp is \(aboveHighSetPoint)")
        }
        
        CENTRAL_SYSTEM!.readRealRegister(register: belowLowSetpoint, length: 2){ (success, response)  in
            
            guard success == true else{
                return
            }
            
            self.belowLow = Double(response)!
            if self.belowLow <= 0.2{
                self.belowLow = 0.0
            }
            let belowlow = String(format: "%.1f", self.belowLow)
            self.belowSP.text = belowlow
            self.belowSP.textColor = DEFAULT_GRAY
            self.parseSetPoints(above_high: self.aboveHigh, below_l: self.belowLow)
            
            print("below lo set point successful. above high sp is \(belowLowSetpoint)")
        }
        
        
    }
    
    /***************************************************************************
     * Function :  parseSetPoints
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/   
    
    func parseSetPoints(above_high:Double, below_l:Double){
        if abortSetPoint != 0 {
            pixelsPerUnit = 431.0/abortSetPoint
            
            let greenZoneRange = 467  - (above_high * self.pixelsPerUnit)
            let aboveHzone = greenZoneRange - 13
            let belowLzone = aboveHzone + (above_high - below_l) * self.pixelsPerUnit
            rangeBackground.frame = CGRect(x: 130, y: greenZoneRange, width: 25, height: (above_high - below_l) * self.pixelsPerUnit)
            lowerrangeBackground.frame = CGRect(x: 130, y: belowLzone+13, width: 25, height: (below_l) * self.pixelsPerUnit)
            upperrangeBackground.frame = CGRect(x: 130, y: 36, width: 25, height: (abortSetPoint - above_high) * self.pixelsPerUnit)
            aboveHView.frame = CGRect(x: 247, y: aboveHzone, width:86, height:26)
            
            belowLView.frame = CGRect(x: 247, y: belowLzone, width:86, height:26)
            
            aboveylocation = CGFloat(aboveHzone)
            belowylocation = CGFloat(belowLzone)
        }
        
    }
    
    /***************************************************************************
     * Function :  simulateCoordinate
     * Input    :  none
     * Output   :  none
     * Comment  :  This is a fixd function. Simply returns the position of the indicator on the UI
     ***************************************************************************/   
    
    func simulateCoordinate(setPoint:Double)->Double{
        
        let coordinate =  467 - (setPoint * self.pixelsPerUnit) - 20 // 20 is the offset from center of the indicator
        return coordinate
        
    }
    
    
    /***************************************************************************
     * Function :  readSetpointAgain
     * Input    :  none
     * Output   :  none
     * Comment  :  
     ***************************************************************************/   
    
    @objc private func readSetpointAgain(){
        
        fetchedSetpoints = 0
        
    }
    
    
    
    @IBAction func setNewAbortSPButtonPressed(_ sender: Any) {
        if let setpoint = abortSPTextField.text, !setpoint.isEmpty,
            let floatValue = Float(setpoint) {
            CENTRAL_SYSTEM?.writeRealValue(register: currentAbortSetpointRegister, value: floatValue)
            readSetpointAgain()
        } else {
            print("EMPTY FIELD")
        }
        
    }
}
