//
//  FireSpireSelSettingsViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 7/31/18.
//  Copyright © 2018 WET. All rights reserved.
//


import UIKit


class FireSpireSelSettingsViewController: UIViewController{
    
   override func viewDidLoad() {
           super.viewDidLoad()

           // Do any additional setup after loading the view.
       }
       
       @IBAction func redirectToFireSettings(_ sender: UIButton) {
             let storyBoard : UIStoryboard = UIStoryboard(name: "firespire", bundle:nil)
              
              let prjDetail = storyBoard.instantiateViewController(withIdentifier: "fireSettings") as! FireSpireSettingsViewController
              prjDetail.fireSpireNumber = sender.tag
              self.navigationController?.pushViewController(prjDetail, animated: true)
       }
}
