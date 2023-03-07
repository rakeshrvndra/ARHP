//
//  FireSpireSelViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/15/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class FireSpireSelViewController: UIViewController {

   private var httpComm = HTTPComm()
   private let logger = Logger()
   
   override func viewDidLoad() {
       super.viewDidLoad()
       
       // Do any additional setup after loading the view.
   }
   
   override func viewWillAppear(_ animated: Bool) {
        
   }
           
    @IBAction func redirectToShowMonitor(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "firespire", bundle:nil)
        
        let prjDetail = storyBoard.instantiateViewController(withIdentifier: "showMonitor") as! ShowMonitorViewController
        self.navigationController?.pushViewController(prjDetail, animated: true)
        
    }
    @IBAction func redirectToFireStatus(_ sender: UIButton) {
          let storyBoard : UIStoryboard = UIStoryboard(name: "firespire", bundle:nil)
           
           let prjDetail = storyBoard.instantiateViewController(withIdentifier: "fireSelect") as! FireSpireViewController
           prjDetail.fireNumber = sender.tag
           self.navigationController?.pushViewController(prjDetail, animated: true)
    }
    @IBAction func showAlerSettings(_ sender: UIButton) {
         self.addAlertAction(button: sender)
    }
 
}
