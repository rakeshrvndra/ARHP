//=================================== ABOUT ===================================

/*
 *  @FILE:          ACTHomeViewController.swift
 *  @AUTHOR:        Arpi Derm
 *  @RELEASE_DATE:  July 28, 2017, 4:13 PM
 *  @Description:   Main iPad Controls Screen
 *  @VERSION:       2.0.0
 */

//=================================== NOTES ===================================

/*  1:Individual notification badges are being accessed through UI tags
 *    there are overall 6 buttons on the home screen. Each button has a tag 1-16
 *    in sequence. Individual badge tags are generated based on following equations.
 *    RedBadge = (ButtonTag x 100) + 1
 *    YellowBadge = (ButtonTag x 100) + 2
 *    So in order to hide or show individual badges, a ui view has to be create with
 *    genertaed tag numbers based on specified equations.
 *
 */

import UIKit


public var CENTRAL_SYSTEM: CentralSystem?


class ACTHomeViewController: UIViewController{
    
    //No Connection View
    
    @IBOutlet weak var noConnectionView:     UIView!
    @IBOutlet weak var noConnectionErrorLbl: UILabel!
    @IBOutlet weak var enableDeadManLbl: UILabel!
    @IBOutlet weak var fireIcon: UIImageView!
    
    //Dependencies
    
    private let logger =                            Logger()
    private var centralSystem =                     CentralSystem()
    private let helper =                            Helper()
    private let showManager =                       ShowManager()
    private let operationManual =                   OperationManual()
    private let utils =                             Utilits()
    private var httpComm = HTTPComm()
    
    //Data Structures
    
    private var langData =                          Dictionary<String, String>()
    private var showPlayStat =                      ShowPlayStat()
    private var fireOnce =                          false
    //Current and Next Playing show information
    
    @IBOutlet weak var nowPlayingTitleLbl:          UILabel!
    @IBOutlet weak var nextPlayingTitleLbl:         UILabel!
    @IBOutlet weak var softwareUpdateAvailable:     UILabel!
    @IBOutlet weak var currentPlayingShow:          UILabel!
    @IBOutlet weak var currentShowRemainingTime:    UILabel!
    @IBOutlet weak var nextShowName:                UILabel!
    @IBOutlet weak var nextShowTime:                UILabel!
    @IBOutlet weak var todayData:                   UILabel!
    
    /***************************************************************************
     * Function :  viewDidLoad
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed only when controller resources
     *             get loaded
     ***************************************************************************/
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        if !setUDForConnection {
            UserDefaults.standard.set("connected", forKey: "ConnectionStatus")
        }
        
    }
    
    /***************************************************************************
     * Function :  viewWillAppear
     * Input    :  none
     * Output   :  none
     * Comment  :  This function gets executed every time view appears
     ***************************************************************************/
    
    override func viewWillAppear(_ animated: Bool){
        
        super.viewWillAppear(true)
        
        //Initialize the central system so we can establish all the system config
        if !fireOnce {
            fireOnce = true 
            centralSystem.initialize()
            centralSystem.connect()
        }
       
        if let ssid = getSSID() {
            print("SSID: \(ssid)")
        }
        
        //Assign it to the global variable which will be shared between all classes
        CENTRAL_SYSTEM = centralSystem
        
        setupUILabelData()
        showManager.getShowsFile()
        loadplcSetpoints()
        checkCurrentSchedule()
        //Add notification observer to get system stat
        NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        //This line of code is an extension added to the view controller by showStoppers module
        //This is the only line needed to add show stopper
        
        
    }
    func loadplcSetpoints(){
        
        guard let maxFreq = UserDefaults.standard.object(forKey: "defaultmaxFreq") as? Float else { return }
        guard let maxCurrent = UserDefaults.standard.object(forKey: "defaultmaxCurrent") as? Float else { return }
        guard let maxVltg = UserDefaults.standard.object(forKey: "defaultmaxVoltage") as? Float else { return }
        guard let minVltg = UserDefaults.standard.object(forKey: "defaultminVoltage") as? Float else { return }
        guard let maxTemp = UserDefaults.standard.object(forKey: "defaultmaxTemp") as? Float else { return }
        guard let midTemp = UserDefaults.standard.object(forKey: "defaultmidTemp") as? Float else { return }
        
        CENTRAL_SYSTEM!.writeRealValue(register: MAX_FREQUENCY_SP, value:Float(maxFreq))
        CENTRAL_SYSTEM!.writeRealValue(register: MAX_TEMPERATURE_SP, value:Float(maxTemp))
        CENTRAL_SYSTEM!.writeRealValue(register: MID_TEMPERATURE_SP, value:Float(midTemp))
        CENTRAL_SYSTEM!.writeRealValue(register: MAX_VOLTAGE_SP, value: Float(maxVltg))
        CENTRAL_SYSTEM!.writeRealValue(register: MIN_VOLTAGE_SP, value:Float(minVltg))
        CENTRAL_SYSTEM!.writeRealValue(register: MAX_CURRENT_SP, value: Float(maxCurrent))
    }

    override func viewWillDisappear(_ animated: Bool){
        
        //NOTE: We need to remove the notification observer so the PUMP stat check point will stop to avoid extra bandwith usage
        
        NotificationCenter.default.removeObserver(self)
        logger.logData(data:"View Is Disappearing")
        
    }
    
    /***************************************************************************
     * Function :  checkSystemStat
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks the network connection for all system components
     ***************************************************************************/
    
    @objc func checkSystemStat(){ 
        let (plcConnection, serverConnection) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED && serverConnection == CONNECTION_STATE_CONNECTED  {
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0

            showPlayStat = showManager.getCurrentAndNextShowInfo()
            getCurrentPlayingShow()
            nextPlayingShow()
            //checkForSoftwareUpdate()
            
            
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
     * Function :  setupUILabelData
     * Input    :  none
     * Output   :  none
     * Comment  :  Simply lays out the ui labels with corresponding translation
     ***************************************************************************/
    
    func setupUILabelData(){
        
        langData = helper.getLanguageSettigns(screenName: "home")
        
        let nowStr = langData["NOW"]!
        let nextStr = langData["NEXT"]!
        let updateStr = langData["UPDATE AVAILABLE"]!
        
        nowPlayingTitleLbl.text! = "\(nowStr):"
        nextPlayingTitleLbl.text! = "\(nextStr):"
        softwareUpdateAvailable.text! = updateStr
        
        navigationItem.title = langData["HOME"]!
        nextPlayingTitleLbl.alpha = 0
        nowPlayingTitleLbl.alpha = 0
        
    }
    
    /***************************************************************************
     * Function :  checkForSoftwareUpdate
     * Input    :  none
     * Output   :  none
     * Comment  :  Checks to see if a new software update is available
     ***************************************************************************/
    
    func checkForSoftwareUpdate(){
        let (currentVersion,updatedVersion) = helper.checkForAppUpdates()
        
        if currentVersion < updatedVersion{
            softwareUpdateAvailable.alpha = 1
        }else{
            softwareUpdateAvailable.alpha = 0
        }
        
    }
    
    /***************************************************************************
     * Function :  pushToStoryboard
     * Input    :  none
     * Output   :  none
     * Comment  :  Handles Navigation. Based on the screen name and its corresponding
     *             tag, we want to instantiate the specified view controller
     *             and navigate to it
     ***************************************************************************/
    
    @IBAction func pushToStoryboard(_ sender: UIButton){
        
        let tag = sender.tag - 1
        let screenName = SCREENS[tag]
        
        //If scnreenName  is empty, it means that the corresponding feature is not implemented in this application
        //Operation Manual has its own navigation handler so we dont want to use the default one
        
        if screenName != "" &&  screenName != "operationManual"{
            
            if screenName == "lights" {
                screen_Name = screenName
                readServerPath = READ_LIGHT_SERVER_PATH
                writeServerPath = WRITE_LIGHT_SERVER_PATH
            } else if screenName == "pumps" {
                readServerPath = READ_TWW_SERVER_PATH
                writeServerPath = WRITE_TWW_SERVER_PATH
                screen_Name = screenName
            } else if screenName == "filtration" {
                readServerPath = READ_FILTRATION_SERVER_PATH
                writeServerPath = WRITE_FILTRATION_SERVER_PATH
                screen_Name = screenName
            } else if screenName == "fillerShows" {
                readServerPath = GET_FILLER_SHOW_SCH_HTTP_PATH
                writeServerPath = SET_FILLER_SHOW_SCH_HTTP_PATH
                screen_Name = screenName
            }
            
            
            let storyBoard = UIStoryboard(name: screenName, bundle: nil)
            let viewController = storyBoard.instantiateViewController(withIdentifier: "\(screenName)ViewController")
            navigationController?.pushViewController(viewController, animated: true)
            
        } else if screenName == "operationManual" {
            
            let operationManual =  self.operationManual.showOperationManual()
            navigationController?.pushViewController(operationManual, animated: true)
            
        }
    }
    
    private func showAlert(){
        let alertController = UIAlertController(title: "WET Alert", message: "Service Required. Please contact WET", preferredStyle: .alert)
     
        let OK = UIAlertAction(title: "OK", style: .destructive) { (alert) in
            print("OK Pressed")
        }
        alertController.addAction(OK)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /***************************************************************************
     * Function :  getCurrentPlayingShow
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func getCurrentPlayingShow(){
        if showPlayStat.servRequired == 1{
            showAlert()
        }
        if showPlayStat.playStatus > 0 && showPlayStat.currentShowNumber > 0{
            currentPlayingShow.alpha = 1
            nowPlayingTitleLbl.alpha = 1
            currentShowRemainingTime.alpha = 1
            currentPlayingShow.text = "PLAYING: \(showPlayStat.currentShowName)"
            let showRemaining = showPlayStat.showRemaining
            let min = showRemaining / 60
            let sec = showRemaining % 60
            currentShowRemainingTime.text = "TIME REMAINING: \(min) : \(sec)"
            
        }else{
            currentPlayingShow.alpha = 0
            nowPlayingTitleLbl.alpha = 0
            currentShowRemainingTime.alpha = 0
            
            
        }
        
        //We also want to show today's date
        todayData.text = utils.todaysDateLabel()
        
    }
    
    /***************************************************************************
     * Function :  nextPlayingShow
     * Input    :  none
     * Output   :  none
     * Comment  :
     ***************************************************************************/
    
    private func nextPlayingShow(){
        
        //NOTE: If next show number is 0. it menas there is no scheduled show so hide the next show ui objects. Otherwise, show them.
        
        if self.showPlayStat.nextShowNumber > 0{
            //We dont want to set the alpha every time. Just when it is different we want to set it
            if self.showPlayStat.nextShowNumber == 3 || self.showPlayStat.nextShowNumber == 6 || self.showPlayStat.nextShowNumber == 9{
                if self.showPlayStat.enableDeadMan == 1 {
                    self.enableDeadManLbl.alpha = 1
                    self.fireIcon.alpha = 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       self.fireIcon.alpha = 0
                    }
                }
            }
            if self.showPlayStat.enableDeadMan == 0 {
                self.enableDeadManLbl.alpha = 0
                self.fireIcon.alpha = 0
            }
            nextPlayingTitleLbl.alpha = 1
            nextShowTime.alpha = 1
            nextShowName.alpha = 1
            nextShowName.text = showPlayStat.nextShowName
            nextShowTime.text = "\(utils.getNextShowTime(withTime: showPlayStat.nextShowTime.description)!)"
            
            
        } else {
            
            //We dont want to set the alpha every time. Just when it is different we want to set it
            nextPlayingTitleLbl.alpha = 0
            nextShowTime.alpha = 0
            nextShowName.alpha = 0
            
        }
    }
}
