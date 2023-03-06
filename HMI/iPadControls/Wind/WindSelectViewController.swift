//
//  WindSelectViewController.swift
//  iPadControls
//
//  Created by Rakesh Raveendra on 9/7/21.
//  Copyright © 2021 WET. All rights reserved.
//

import UIKit

class WindSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func pushToWindScreen(_ sender: UIButton) {
        let windVC = UIStoryboard.init(name: "wind", bundle: nil).instantiateViewController(withIdentifier: "windSelect") as! WindViewController
        windVC.windId = sender.tag
        navigationController?.pushViewController(windVC, animated: true)
    }

    @IBAction func showAlerSettings(_ sender: UIButton) {
         self.addAlertAction(button: sender)
    }
}
