//
//  LightsSelectViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 10/1/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class LightsSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func redirectToLights(_ sender: UIButton) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "lights", bundle:nil)
        let lightDetail = storyBoard.instantiateViewController(withIdentifier: "lightSelect") as! LightsViewController
        lightDetail.lightType = sender.tag
        if lightDetail.lightType == 100{
            readServerPath = READ_LIGHT_SERVER_PATH
            writeServerPath = WRITE_LIGHT_SERVER_PATH
            screen_Name = "lights"
        } else if lightDetail.lightType == 200{
            readServerPath = READ_PIXIE_LIGHT_SERVER_PATH
            writeServerPath = WRITE_PIXIE_LIGHT_SERVER_PATH
            screen_Name = "lights"
        }
        self.navigationController?.pushViewController(lightDetail, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
