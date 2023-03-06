//
//  ProjectorViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 12/28/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class ProjectorViewController: UIViewController {
    
    @IBOutlet weak var noConnectionView: UIView!
    @IBOutlet weak var noConnectionErrLbl: UILabel!
    private var httpComm = HTTPComm()
    private let logger = Logger()
    private var centralSystem = CentralSystem()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         centralSystem.getNetworkParameters()
         centralSystem.connect()
         CENTRAL_SYSTEM = centralSystem
         readProjTemp()
         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
    }
    @objc func checkSystemStat(){
        
        let (plcConnection,_) = CENTRAL_SYSTEM!.getConnectivityStat()
        
        if plcConnection == CONNECTION_STATE_CONNECTED{
            
            //Change the connection stat indicator
            noConnectionView.alpha = 0
//            getProjectorStatus()
            readProjTemp()
            noConnectionView.isUserInteractionEnabled = false
            //Check if the pumps or on auto mode or hand mode
            
            logger.logData(data: "PUMP: CONNECTION SUCCESS")
            
        }  else {
            noConnectionView.alpha = 1
            if plcConnection == CONNECTION_STATE_FAILED {
                noConnectionErrLbl.text = "PLC CONNECTION FAILED, SERVER GOOD"
            } else if plcConnection == CONNECTION_STATE_CONNECTING {
                noConnectionErrLbl.text = "CONNECTING TO PLC, SERVER CONNECTED"
            } else if plcConnection == CONNECTION_STATE_POOR_CONNECTION {
                noConnectionErrLbl.text = "PLC POOR CONNECTION, SERVER CONNECTED"
            }
        }
        
    }
    
    func readProjTemp(){
        
        httpComm.httpGetResponseFromPath(url: READ_PROJ_TEMP){ (response) in
            
            guard response != nil else { return }
            guard let responseArray = response as? [String:Any] else { return }
            let temp  = responseArray["temp"] as! NSArray
            if temp.count == 21{
                for index in 1..<22 {
                    let val = temp[index-1] as? String
                    if val != nil{
                        let intval = val!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let lbl = self.view.viewWithTag(index) as? UILabel
                        lbl?.text = val
                        if Int(intval)! > PROJ_WARNING_TEMP{
                            if Int(intval)! < PROJ_FAULT_TEMP{
                               lbl?.textColor = .yellow
                            } else {
                               lbl?.textColor = RED_COLOR
                           }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func redirectToPrjStatus(_ sender: UIButton) {
       let storyBoard : UIStoryboard = UIStoryboard(name: "Projector", bundle:nil)
        
        let prjDetail = storyBoard.instantiateViewController(withIdentifier: "ProjectorStatus") as! ProjectorStatusViewController
        prjDetail.prjNumber = sender.tag
        self.navigationController?.pushViewController(prjDetail, animated: true)
    }
    
    @IBAction func redirectToSch(_ sender: UIButton) {
        let schedulerShowVC = UIStoryboard.init(name: "pumps", bundle: nil).instantiateViewController(withIdentifier: "pumpSchedulerViewController") as! PumpSchedulerViewController
        schedulerShowVC.schedulerTag = sender.tag
        navigationController?.pushViewController(schedulerShowVC, animated: true)
    }
}
