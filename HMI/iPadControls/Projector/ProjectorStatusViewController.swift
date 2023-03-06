//
//  ProjectorStatusViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 5/14/19.
//  Copyright © 2019 WET. All rights reserved.
//

import UIKit

class ProjectorStatusViewController: UIViewController {

    @IBOutlet weak var prjName: UILabel!
    @IBOutlet weak var mirror1: UILabel!
    @IBOutlet weak var mirror2: UILabel!
    @IBOutlet weak var mirror3: UILabel!
    @IBOutlet weak var mirror4: UILabel!
    @IBOutlet weak var mirror5: UILabel!
    @IBOutlet weak var mirror6: UILabel!
    @IBOutlet weak var mirror7: UILabel!
    @IBOutlet weak var handView: UIView!
    
    @IBOutlet weak var mirrhiBtn: UIButton!
    @IBOutlet weak var mirrlowBtn: UIButton!
    @IBOutlet weak var autoHandImg: UIImageView!
    @IBOutlet weak var hoaStatus: UILabel!
    @IBOutlet weak var autoHandBtn: UIButton!
    
    var wall1Stats = PROJECTOR_STATS()
    var wall2Stats = PROJECTOR_STATS()
    var wall3Stats = PROJECTOR_STATS()
    var tempStats = PROJECTOR_STATS()
    private let httpComm = HTTPComm()
    private let showManager  = ShowManager()
    private var centralSystem = CentralSystem()
    var prjNumber = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        readProjectorStats()
        // Do any additional setup after loading the view.
    }
        
    override func viewWillAppear(_ animated: Bool) {
         centralSystem.getNetworkParameters()
         centralSystem.connect()
         CENTRAL_SYSTEM = centralSystem
         NotificationCenter.default.addObserver(self, selector: #selector(checkSystemStat), name: NSNotification.Name(rawValue: "updateSystemStat"), object: nil)
        
        if prjNumber == 22{
            self.prjName.text = "WALL 1 STATUS"
            self.mirror1.text = "PRJ 301"
            self.mirror2.text = "PRJ 302"
            self.mirror3.text = "PRJ 303"
            self.mirror4.text = "PRJ 304"
            self.mirror5.text = "PRJ 205"
            self.mirror6.text = "PRJ 206"
            self.mirror7.text = "PRJ 207"
        } else if prjNumber == 23{
            self.prjName.text = "WALL 2 STATUS"
            self.mirror1.text = "PRJ 101"
            self.mirror2.text = "PRJ 102"
            self.mirror3.text = "PRJ 103"
            self.mirror4.text = "PRJ 104"
            self.mirror5.text = "PRJ 305"
            self.mirror6.text = "PRJ 306"
            self.mirror7.text = "PRJ 307"
        } else if prjNumber == 24{
            self.prjName.text = "WALL 3 STATUS"
            self.mirror1.text = "PRJ 201"
            self.mirror2.text = "PRJ 202"
            self.mirror3.text = "PRJ 203"
            self.mirror4.text = "PRJ 204"
            self.mirror5.text = "PRJ 105"
            self.mirror6.text = "PRJ 106"
            self.mirror7.text = "PRJ 107"
        }
    }
    
    
    @objc func checkSystemStat(){
        readProjectorStats()
        parseProjectorStats()
        let devicelogs = self.showManager.getCurrentAndNextShowInfo()
        let btn1 = self.view.viewWithTag(30) as? UIButton
        let btn2 = self.view.viewWithTag(31) as? UIButton
        let btn3 = self.view.viewWithTag(32) as? UIButton
        let btn4 = self.view.viewWithTag(33) as? UIButton
        let btn5 = self.view.viewWithTag(34) as? UIButton
        let btn6 = self.view.viewWithTag(35) as? UIButton
        let btn7 = self.view.viewWithTag(36) as? UIButton
        
        let btn8  = self.view.viewWithTag(40) as? UIButton
        let btn9  = self.view.viewWithTag(41) as? UIButton
        let btn10 = self.view.viewWithTag(42) as? UIButton
        let btn11 = self.view.viewWithTag(43) as? UIButton
        let btn12 = self.view.viewWithTag(44) as? UIButton
        let btn13 = self.view.viewWithTag(45) as? UIButton
        let btn14 = self.view.viewWithTag(46) as? UIButton
        if devicelogs.cmdFlag == 1{
            self.mirrhiBtn.isEnabled = false
            self.mirrlowBtn.isEnabled = false
            self.autoHandBtn.isEnabled = false
            btn1?.isEnabled = false
            btn2?.isEnabled = false
            btn3?.isEnabled = false
            btn4?.isEnabled = false
            btn5?.isEnabled = false
            btn6?.isEnabled = false
            btn7?.isEnabled = false
            btn8?.isEnabled = false
            btn9?.isEnabled = false
            btn10?.isEnabled = false
            btn11?.isEnabled = false
            btn12?.isEnabled = false
            btn13?.isEnabled = false
            btn14?.isEnabled = false
        } else {
            self.mirrhiBtn.isEnabled = true
            self.mirrlowBtn.isEnabled = true
            self.autoHandBtn.isEnabled = true
            btn1?.isEnabled = true
            btn2?.isEnabled = true
            btn3?.isEnabled = true
            btn4?.isEnabled = true
            btn5?.isEnabled = true
            btn6?.isEnabled = true
            btn7?.isEnabled = true
            btn8?.isEnabled = true
            btn9?.isEnabled = true
            btn10?.isEnabled = true
            btn11?.isEnabled = true
            btn12?.isEnabled = true
            btn13?.isEnabled = true
            btn14?.isEnabled = true
        }
    }
    
    
    @IBAction func toggleAutoHandBtn(_ sender: UIButton) {
        if tempStats.liftHOAStatus == 1{
            CENTRAL_SYSTEM?.writeBit(bit: WALL1_HOA_STATUS, value: 0)
        } else {
            CENTRAL_SYSTEM?.writeBit(bit: WALL1_HOA_STATUS, value: 1)
        }
    }
    
    func readProjectorStats (){
        CENTRAL_SYSTEM?.readBits(length: 21, startingRegister: Int32(WALL1_MIRROR_STATUS), completion: { (success, response) in
            
            guard success == true else { return }
            
            self.wall1Stats.pos1 = Int(truncating: response![0] as! NSNumber)
            self.wall1Stats.pos2 = Int(truncating: response![1] as! NSNumber)
            self.wall1Stats.pos3 = Int(truncating: response![2] as! NSNumber)
            self.wall1Stats.pos4 = Int(truncating: response![3] as! NSNumber)
            self.wall1Stats.pos5 = Int(truncating: response![4] as! NSNumber)
            self.wall1Stats.pos6 = Int(truncating: response![5] as! NSNumber)
            self.wall1Stats.pos7 = Int(truncating: response![6] as! NSNumber)
            
            self.wall2Stats.pos1 = Int(truncating: response![7] as! NSNumber)
            self.wall2Stats.pos2 = Int(truncating: response![8] as! NSNumber)
            self.wall2Stats.pos3 = Int(truncating: response![9] as! NSNumber)
            self.wall2Stats.pos4 = Int(truncating: response![10] as! NSNumber)
            self.wall2Stats.pos5 = Int(truncating: response![11] as! NSNumber)
            self.wall2Stats.pos6 = Int(truncating: response![12] as! NSNumber)
            self.wall2Stats.pos7 = Int(truncating: response![13] as! NSNumber)
            
            self.wall3Stats.pos1 = Int(truncating: response![14] as! NSNumber)
            self.wall3Stats.pos2 = Int(truncating: response![15] as! NSNumber)
            self.wall3Stats.pos3 = Int(truncating: response![16] as! NSNumber)
            self.wall3Stats.pos4 = Int(truncating: response![17] as! NSNumber)
            self.wall3Stats.pos5 = Int(truncating: response![18] as! NSNumber)
            self.wall3Stats.pos6 = Int(truncating: response![19] as! NSNumber)
            self.wall3Stats.pos7 = Int(truncating: response![20] as! NSNumber)
        })
        
        CENTRAL_SYSTEM?.readBits(length: 1, startingRegister: Int32(WALL1_HOA_STATUS), completion:{ (success, response) in
            
            guard success == true else { return }
            
            self.wall1Stats.liftHOAStatus = Int(truncating: response![0] as! NSNumber)
            self.wall2Stats.liftHOAStatus = Int(truncating: response![0] as! NSNumber)
            self.wall3Stats.liftHOAStatus = Int(truncating: response![0] as! NSNumber)
            
        })
        
        if prjNumber == 22{
            self.tempStats = self.wall1Stats
        } else if prjNumber == 23{
            self.tempStats = self.wall2Stats
        } else if prjNumber == 24{
            self.tempStats = self.wall3Stats
        }
    }
    
    func parseProjectorStats (){
        let mirro1State = self.view.viewWithTag(20) as? UIImageView
        let mirro2State = self.view.viewWithTag(21) as? UIImageView
        let mirro3State = self.view.viewWithTag(22) as? UIImageView
        let mirro4State = self.view.viewWithTag(23) as? UIImageView
        let mirro5State = self.view.viewWithTag(24) as? UIImageView
        let mirro6State = self.view.viewWithTag(25) as? UIImageView
        let mirro7State = self.view.viewWithTag(26) as? UIImageView
        
        let btn1 = self.view.viewWithTag(30) as? UIButton
        let btn2 = self.view.viewWithTag(31) as? UIButton
        let btn3 = self.view.viewWithTag(32) as? UIButton
        let btn4 = self.view.viewWithTag(33) as? UIButton
        let btn5 = self.view.viewWithTag(34) as? UIButton
        let btn6 = self.view.viewWithTag(35) as? UIButton
        let btn7 = self.view.viewWithTag(36) as? UIButton
        
        let btn8  = self.view.viewWithTag(40) as? UIButton
        let btn9  = self.view.viewWithTag(41) as? UIButton
        let btn10 = self.view.viewWithTag(42) as? UIButton
        let btn11 = self.view.viewWithTag(43) as? UIButton
        let btn12 = self.view.viewWithTag(44) as? UIButton
        let btn13 = self.view.viewWithTag(45) as? UIButton
        let btn14 = self.view.viewWithTag(46) as? UIButton
    
        tempStats.pos1 == 1 ? ( mirro1State?.image = #imageLiteral(resourceName: "green")) : (mirro1State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos2 == 1 ? ( mirro2State?.image = #imageLiteral(resourceName: "green")) : (mirro2State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos3 == 1 ? ( mirro3State?.image = #imageLiteral(resourceName: "green")) : (mirro3State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos4 == 1 ? ( mirro4State?.image = #imageLiteral(resourceName: "green")) : (mirro4State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos5 == 1 ? ( mirro5State?.image = #imageLiteral(resourceName: "green")) : (mirro5State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos6 == 1 ? ( mirro6State?.image = #imageLiteral(resourceName: "green")) : (mirro6State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        tempStats.pos7 == 1 ? ( mirro7State?.image = #imageLiteral(resourceName: "green")) : (mirro7State?.image = #imageLiteral(resourceName: "blank_icon_on"))
        
        if tempStats.liftHOAStatus == 0{
            self.hoaStatus.text = "AUTO"
            self.handView.isHidden = true
            autoHandImg.image = #imageLiteral(resourceName: "autoMode")
            autoHandImg.rotate360Degrees(animate: true)
            btn1?.isHidden = true
            btn2?.isHidden = true
            btn3?.isHidden = true
            btn4?.isHidden = true
            btn5?.isHidden = true
            btn6?.isHidden = true
            btn7?.isHidden = true
            btn8?.isHidden = true
            btn9?.isHidden = true
            btn10?.isHidden = true
            btn11?.isHidden = true
            btn12?.isHidden = true
            btn13?.isHidden = true
            btn14?.isHidden = true
        } else if tempStats.liftHOAStatus == 1{
            self.hoaStatus.text = "HAND"
            self.handView.isHidden = false
            autoHandImg.image = #imageLiteral(resourceName: "handMode")
            autoHandImg.rotate360Degrees(animate: false)
            btn1?.isHidden = false
            btn2?.isHidden = false
            btn3?.isHidden = false
            btn4?.isHidden = false
            btn5?.isHidden = false
            btn6?.isHidden = false
            btn7?.isHidden = false
            btn8?.isHidden = false
            btn9?.isHidden = false
            btn10?.isHidden = false
            btn11?.isHidden = false
            btn12?.isHidden = false
            btn13?.isHidden = false
            btn14?.isHidden = false
        }
    }
    
    @IBAction func triggerCmdUp(_ sender: UIButton) {
        if prjNumber == 22{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL1_CMD)1"){ (response) in
            }
        } else if prjNumber == 23{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL2_CMD)1"){ (response) in
            }
        } else if prjNumber == 24{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL3_CMD)1"){ (response) in
            }
        }
    }
    
    @IBAction func sendInduvidualPrjUp(_ sender: UIButton) {
        let btnTag = sender.tag
        if prjNumber == 22{
            switch btnTag {
                case 30:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[15,1]"){ (response) in
                    }
                case 31:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[16,1]"){ (response) in
                    }
                case 32:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[17,1]"){ (response) in
                    }
                case 33:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[18,1]"){ (response) in
                    }
                case 34:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[12,1]"){ (response) in
                    }
                case 35:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[13,1]"){ (response) in
                    }
                case 36:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[14,1]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        } else if prjNumber == 23{
            switch btnTag {
                case 30:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[1,1]"){ (response) in
                    }
                case 31:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[2,1]"){ (response) in
                    }
                case 32:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[3,1]"){ (response) in
                    }
                case 33:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[4,1]"){ (response) in
                    }
                case 34:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[19,1]"){ (response) in
                    }
                case 35:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[20,1]"){ (response) in
                    }
                case 36:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[21,1]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        } else if prjNumber == 24{
            switch btnTag {
                case 30:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[8,1]"){ (response) in
                    }
                case 31:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[9,1]"){ (response) in
                    }
                case 32:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[10,1]"){ (response) in
                    }
                case 33:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[11,1]"){ (response) in
                    }
                case 34:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[5,1]"){ (response) in
                    }
                case 35:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[6,1]"){ (response) in
                    }
                case 36:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[7,1]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        }
    }
    
    @IBAction func sendInduvidualPrjDown(_ sender: UIButton) {
        let btnTag = sender.tag
        if prjNumber == 22{
            switch btnTag {
                case 40:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[15,0]"){ (response) in
                    }
                case 41:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[16,0]"){ (response) in
                    }
                case 42:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[17,0]"){ (response) in
                    }
                case 43:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[18,0]"){ (response) in
                    }
                case 44:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[12,0]"){ (response) in
                    }
                case 45:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[13,0]"){ (response) in
                    }
                case 46:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[14,0]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        } else if prjNumber == 23{
            switch btnTag {
                case 40:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[1,0]"){ (response) in
                    }
                case 41:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[2,0]"){ (response) in
                    }
                case 42:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[3,0]"){ (response) in
                    }
                case 43:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[4,0]"){ (response) in
                    }
                case 44:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[19,0]"){ (response) in
                    }
                case 45:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[20,0]"){ (response) in
                    }
                case 46:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[21,0]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        } else if prjNumber == 24{
            switch btnTag {
                case 40:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[8,0]"){ (response) in
                    }
                case 41:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[9,0]"){ (response) in
                    }
                case 42:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[10,0]"){ (response) in
                    }
                case 43:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[11,0]"){ (response) in
                    }
                case 44:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[5,0]"){ (response) in
                    }
                case 45:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[6,0]"){ (response) in
                    }
                case 46:
                    httpComm.httpGetResponseFromPath(url: "\(WRITE_PJ_CMD)[7,0]"){ (response) in
                    }
                default:
                    print("Invalid Tag")
                }
        }
    }
    
    @IBAction func triggerCmdDown(_ sender: UIButton) {
        if prjNumber == 22{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL1_CMD)0"){ (response) in
            }
        } else if prjNumber == 23{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL2_CMD)0"){ (response) in
            }
        } else if prjNumber == 24{
            httpComm.httpGetResponseFromPath(url: "\(WRITE_WALL3_CMD)0"){ (response) in
            }
        }
    }
    
}
