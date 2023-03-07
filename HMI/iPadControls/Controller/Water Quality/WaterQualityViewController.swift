//=================================== ABOUT ===================================

/*
 *  @FILE:          WaterQualityViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   This Module reads all water quality data, parses them
 *                  and generates corresponding chart data
 *  @VERSION:       2.0.0
 */

 /***************************************************************************
 *
 * PROJECT SPECIFIC CONFIGURATION
 *
 * 1 : Water Quality screen configuration parameters located in specs.swift file
 *     should be modified
 ***************************************************************************/

import UIKit


//WQ Data Structures

var x_values:     [String] = []
var br_y_values:  [Float]  = []
var orp_y_values: [Float]  = []
var tds_y_values: [Float]  = []
var ph_y_values:  [Float]  = []

class WaterQualityViewController: UIViewController{

    @IBOutlet weak var noConnectionView:     UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    
    @IBOutlet weak var orpIndicator:         UILabel!
    @IBOutlet weak var phIndicator:          UILabel!
    @IBOutlet weak var bromineIndicator:     UILabel!
    @IBOutlet weak var tdsIndicator:         UILabel!
    
    @IBOutlet weak var orpCurrentValue:      UILabel!
    @IBOutlet weak var phCurrentValue:       UILabel!
    @IBOutlet weak var bromineCurrentValue:  UILabel!
    @IBOutlet weak var tdsCurrentValue:      UILabel!
    @IBOutlet weak var brominatorTimedOut:   UILabel!
    @IBOutlet weak var brDisabledLbl:        UILabel!
    
    @IBOutlet weak var ozoneBtn: UIButton!
    @IBOutlet weak var weekView:             UIView!
    @IBOutlet weak var scrollView:           UIScrollView!
    @IBOutlet weak var liveModeButton:       UIButton!
    @IBOutlet weak var dayModeButton:        UIButton!
    
    private var isLiveMode          = true
    private var showStoppers        =   ShowStoppers()
    private var langData            =   Dictionary<String, String>()
    private var dataAcquisitionMode = WQ_LIVE_MODE_STATE
    private var wq_data: NSDictionary?
    private var phScaledValue: Float    =  0.0
    private var orpScaledValue: Float   =  0.0
    private var brScaledValue: Float    =  0.0
    private var tdsScaledValue: Float   =  0.0
    //MARK: - Class Reference Objects -- Dependencies
    
    @IBOutlet weak var ozoneButton: UIButton!
    private let logger   = Logger()
    private let httpComm = HTTPComm()
    private let helper   = Helper()
    var waterQualityEW  = 0
    var westoffset = 0
    
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

    
    override func viewWillAppear(_ animated: Bool) {
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 800)
        
        
        //Add notification observer to get system stat
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        setupUILabelData()
         removeData()
        
        let tapgesture2 = UITapGestureRecognizer.init(target: self,action: #selector(clickable2))
        tapgesture2.numberOfTapsRequired = 1
        bromineIndicator.addGestureRecognizer(tapgesture2)
    }
    
    
    /***************************************************************************
     * Function :  viewWillDisappear
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func clickable2 (){
        
        let BRViewController = UIStoryboard.init(name: "WQMultiple", bundle: nil).instantiateViewController(withIdentifier: "brSetpoint") as! BRSetpointViewController
        let nav = UINavigationController(rootViewController: BRViewController)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        BRViewController.preferredContentSize = CGSize(width: 800.0, height: 200.0)
        BRViewController.waterqualityEW = waterQualityEW
        popover?.sourceView = bromineIndicator
        self.present(nav, animated: true, completion: nil)
    }
    
    
    /***************************************************************************
     * Function :  setupUILabelData
     * Input    :  none
     * Output   :  none
     * Comment  :  Simply lays out the ui labels with corresponding translation
     ***************************************************************************/
    
    func setupUILabelData(){
        
        langData = helper.getLanguageSettigns(screenName: "waterQuality")
        
        brominatorTimedOut.text = langData["BROMINATOR TIMED OUT"]!
        brDisabledLbl.text = langData["BROMINATOR DISABLED"]!
        if waterQualityEW == 3{
            self.navigationItem.title = "WALL - 3"
            westoffset = 80
            ozoneBtn.isHidden = false
        } else if waterQualityEW == 2 {
            self.navigationItem.title  = "WALL - 2"
            westoffset = 40
            ozoneBtn.isHidden = false
        } else if waterQualityEW == 1 {
            self.navigationItem.title  = "WALL - 1"
            westoffset = 0
            ozoneBtn.isHidden = false
        }
        
        
    }
    
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @objc func checkSystemStat(){
        let (plcConnection, serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
            
            readChannelFaults()
            readScaledValue()
            getChartDataFromServer()
            
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
    
    /***************************************************************************
     * Function :  readChannelFaults
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func readChannelFaults(){
        
        self.readChannelFault(label: self.phIndicator, bit: Int32(WQ_PH_CHANNEL_FAULT_BIT + westoffset))
        self.readChannelFault(label: self.orpIndicator, bit: Int32(WQ_OPR_CHANNEL_FAULT_BIT + westoffset))
        self.readChannelFault(label: self.tdsIndicator, bit: Int32(WQ_TDS_CHANNEL_FAULT_BIT + westoffset))
        self.readChannelFault(label: self.brominatorTimedOut, bit: Int32(WQ_BR_DOSING_TIMEOUT_BIT + westoffset))
        self.readChannelFault(label: self.brDisabledLbl, bit: Int32(WQ_BR_ENABLED_BIT + westoffset))

    }
    
    private func readScaledValue() {
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(WQ_BR_DOSING + westoffset), completion:
            { (success, response) in
                guard success == true else { return }
                
                let value = Int(truncating: response![0] as! NSNumber)
                let bromineValue = Float(value)
                self.brScaledValue = bromineValue
                let formattedValue = String(format: "%.2f", self.brScaledValue)
                self.bromineCurrentValue.text   = formattedValue
                self.showLastCurrentSensorValues(value: self.brScaledValue)
            })
        
        
        let offset = 10
        
        for i in 0..<3 {
            
            CENTRAL_SYSTEM?.readRealRegister(register: Int(westoffset + WQ_PH_SCALED_VALUE + (offset * i)), length: 2, completion:
                { (success, response) in
                guard success == true else { return }
                
                if let value = Float(response)
                {
                    let formattedValue = String(format: "%.2f", value)
                    switch i {
                    case 0:
                        self.phCurrentValue.text        = "\(formattedValue)"
                    case 1:
                        self.orpCurrentValue.text       = "\(formattedValue)"
                    case 2:
                        self.tdsCurrentValue.text       = "\(formattedValue)"
                    default:
                        print("Error")
                    }
                    
                }
                
            })
        }
    }
    
    private func readChannelFault(label:UILabel,bit:Int32){
        
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: bit, completion: { (success, response) in
            
            if success == true{
                
                let channelFault = Int(truncating: (response![0] as? NSNumber)!)

                if bit == Int32(WQ_BR_ENABLED_BIT + self.westoffset){
                
                    if channelFault == 0{
                        self.brDisabledLbl.alpha = 1
                    }else{
                        self.brDisabledLbl.alpha = 0
                    }
                    
                }else if bit == Int32(WQ_BR_DOSING_TIMEOUT_BIT + self.westoffset){
                    
                    if channelFault == 1{
                        self.brominatorTimedOut.alpha = 1
                    }else{
                        self.brominatorTimedOut.alpha = 0
                    }
                    
                }else{
                    
                    if channelFault == 1{
                        
                        label.textColor = RED_COLOR
                        
                    }else if channelFault == 0{
                        
                        label.textColor = UIColor.white
                        
                    }
                    
                }
            }
        })
    }
    

    
    /***************************************************************************
     * Function :  getChartDataFromServer
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func getChartDataFromServer(){
    
            switch  dataAcquisitionMode{
            
                
            case WQ_LIVE_MODE_STATE:
                if waterQualityEW == 1{
                    fetchWQData(path: WQ1_LIVE_SERVER_PATH)
                } else if waterQualityEW == 2 {
                    fetchWQData(path: WQ2_LIVE_SERVER_PATH)
                } else if waterQualityEW == 3 {
                    fetchWQData(path: WQ3_LIVE_SERVER_PATH)
                }
            case WQ_DAY_MODE_STATE:
                if waterQualityEW == 1{
                    fetchWQData(path: WQ1_DAY_SERVER_PATH)
                } else if waterQualityEW == 2 {
                    fetchWQData(path: WQ2_DAY_SERVER_PATH)
                } else if waterQualityEW == 3 {
                    fetchWQData(path: WQ3_DAY_SERVER_PATH)
                }
            default:
                
                self.logger.logData(data: "NO VALID STATE FOUND FOR WATER QUALITY DATA ACQUISITION MODE.")
                
            }
        }
    
    /***************************************************************************
     * Function :  fetchWQData
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func fetchWQData(path: String){
   
            self.httpComm.httpGetResponseFromPath(url: path){ (response) in
                
                
                guard let response = response as? NSDictionary else{return}
                self.wq_data = response
                
                
                self.getTDSValues()
                self.getBromineValues()
                self.getPHValues()
                self.getORPValues()
                self.getDate()
                
            }
    
    }
    

    /***************************************************************************
     * Function :  getTDSValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func getTDSValues() {
        guard let TDS =  wq_data?.object(forKey: "tds") as? [Double] else { return }
        
    
        if isLiveMode {
            if tds_y_values.count < 900 {
                for values in TDS {
                    tds_y_values.append(Float(values))
                }
            }else{
                tds_y_values.remove(at: 0)
                tds_y_values.append(Float(TDS.last!))
            }
        } else {
            for values in TDS {
                tds_y_values.append(Float(values))
            }
        }
        
    }
    
    /***************************************************************************
     * Function :  getBromineValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func getBromineValues() {
        guard let BR = wq_data?.object(forKey: "br") as? [Double] else { return }
        
        if isLiveMode {
            if br_y_values.count < 900 {
                for values in BR {
                    br_y_values.append(Float(values))
                }
            }else{
                br_y_values.remove(at: 0)
                br_y_values.append(Float(BR.last!))
            }
        } else {
            for values in BR {
                br_y_values.append(Float(values))
            }
        }
        
        
        
    }
    
    /***************************************************************************
     * Function :  getPHValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func getPHValues() {
        guard let PH = wq_data?.object(forKey: "ph") as? [Double] else { return }

        
        if isLiveMode {
            if ph_y_values.count < 900 {
                for values in PH {
                    ph_y_values.append(Float(values))
                }
            }else{
                ph_y_values.remove(at: 0)
                ph_y_values.append(Float(PH.last!))
            }
        } else {
            for values in PH {
                ph_y_values.append(Float(values))
            }
        }
        
        
    }
    
    
    /***************************************************************************
     * Function :  getORPValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func getORPValues() {
        guard let ORP = wq_data?.object(forKey: "orp") as? [Double] else { return }
        
        if isLiveMode {
            if orp_y_values.count < 900 {
                for values in ORP {
                    orp_y_values.append(Float(values))
                }
            }else{
                orp_y_values.remove(at: 0)
                orp_y_values.append(Float(ORP.last!))
            }
        } else {
            for values in ORP {
                orp_y_values.append(Float(values))
            }
        }


    }
    
    /***************************************************************************
     * Function :  getDate
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    func getDate() {
        guard let date = wq_data?.object(forKey: "date") as? [String] else { return }
        
        if isLiveMode {
            if x_values.count < 900 {
                x_values = date
            }else{
                x_values.remove(at: 0)
                x_values.append(date.last!)
            }
        } else {
            x_values = date
        }
        
    }
    
    /***************************************************************************
     * Function :  showLastCurrentSensorValues
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    private func showLastCurrentSensorValues(value: Float){
        let formattedValue = String(format: "%.2f", value)
        
        switch value {
        case brScaledValue:
            bromineCurrentValue.text   = "\(brScaledValue)"
        case tdsScaledValue:
            tdsCurrentValue.text       = "\(formattedValue)"
        case orpScaledValue:
            orpCurrentValue.text       = "\(formattedValue)"
        case phScaledValue:
            phCurrentValue.text        = "\(formattedValue)"
        default:
            print("Error")
        }
    }
    
    /***************************************************************************
     * Function :  switchToLiveMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @IBAction func switchToLiveMode(_ sender: Any){
        weekView.isHidden = true
        dataAcquisitionMode = WQ_LIVE_MODE_STATE
        removeData()
        isLiveMode = true
        getChartDataFromServer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.liveModeButton.setTitleColor(.white, for: .normal)
            self.dayModeButton.setTitleColor(.gray, for: .normal)
        }
 
    }
    
    /***************************************************************************
     * Function :  switchToDayMode
     * Input    :  none
     * Output   :  none
     * Comment  :
     *
     ***************************************************************************/
    
    @IBAction func switchToDayMode(_ sender: Any){
       weekView.isHidden = true
       dataAcquisitionMode = WQ_DAY_MODE_STATE
       removeData()
       isLiveMode = false
       getChartDataFromServer()
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.liveModeButton.setTitleColor(.gray, for: .normal)
            self.dayModeButton.setTitleColor(.white, for: .normal)
        }

    }
    
    
    @IBAction func switchToWeekMode(_ sender: Any) {
        weekView.isHidden = false
        
        let index = Calendar.current.component(.weekday, from: Date()) // this returns an Int
//      
//        if let weekButton1 = view.viewWithTag(900) as? UIButton {
//            let day = (index + 1) % 7
//            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
//            weekButton1.setTitle(currentDay, for: .normal)
//        }
//        
        if let weekButton2 = view.viewWithTag(901) as? UIButton {
            let day = (index + 2) % 7
            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton2.setTitle(currentDay, for: .normal)
            
        }
        
        
        
        if let weekButton3 = view.viewWithTag(902) as? UIButton {
            let day = (index + 3) % 7
            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton3.setTitle(currentDay, for: .normal)
        }
        
        if let weekButton4 = view.viewWithTag(903) as? UIButton {
            let day = (index + 4) % 7
            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton4.setTitle(currentDay, for: .normal)
            
        }
        
        
        if let weekButton5 = view.viewWithTag(904) as? UIButton {
            let day = (index + 5) % 7
            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton5.setTitle(currentDay, for: .normal)
            
        }
        
        if let weekButton6 = view.viewWithTag(905) as? UIButton {
            let day = (index + 6) % 7
            let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton6.setTitle(currentDay, for: .normal)
        }
        
        if let weekButton7 = view.viewWithTag(906) as? UIButton {
        let day = (index + 7) % 7
           let currentDay = Calendar.current.weekdaySymbols[day - 1] // subtract 1 since the index starts at 1
            weekButton7.setTitle(currentDay, for: .normal)
            
        }
        
   
    }
    
    @IBAction func ozoneButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "WQMultiple", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "ozonePopup") as! OzonePopupViewController
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = .popover
        nav.isNavigationBarHidden = true
        let popover = nav.popoverPresentationController
        popover?.sourceView = sender
        popoverContent.ozoneId = waterQualityEW
        popover?.permittedArrowDirections = .right
        popoverContent.preferredContentSize = CGSize(width: 300, height: 170)
        self.present(nav, animated: true, completion: nil)
    }
    
    private func removeData(){
        x_values.removeAll()
        br_y_values.removeAll()
        orp_y_values.removeAll()
        tds_y_values.removeAll()
        ph_y_values.removeAll()
        ORPDataEntries.removeAll()
        PHDataEntries.removeAll()
        TDSDataEntries.removeAll()
        bromineDataEntries.removeAll()
    }
    
}



