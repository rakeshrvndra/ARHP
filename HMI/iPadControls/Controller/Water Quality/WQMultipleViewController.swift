//
//  WQMultipleViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 10/19/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class WQMultipleViewController: UIViewController {

    
var waterQualityEW = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func pushToWaterQualityScreen(_ sender: UIButton) {
        let waterQualityVC = UIStoryboard.init(name: "WQMultiple", bundle: nil).instantiateViewController(withIdentifier: "waterQuality") as! WaterQualityViewController
        waterQualityEW = sender.tag
        waterQualityVC.waterQualityEW = waterQualityEW
        navigationController?.pushViewController(waterQualityVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
