//
//  SystemFaultViewController.swift
//  iPadControls
//
//  Created by Jan Manalo on 12/13/18.
//  Copyright © 2018 WET. All rights reserved.
//

import UIKit

class SystemFaultViewController: UIViewController {

    @IBOutlet weak var nameOfFaultLabel: UILabel!
    var faultIndex: [Int]?
    var strainerFaultIndex: [Int]?
    var faultTag = 0
    var faultLabel = UILabel()
    var strainerLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if faultTag == 200{
            nameOfFaultLabel.text = "NETWORK FAULT"
            nameOfFaultLabel.textAlignment = .center 
            readNetworkFaults()
        } else {
            nameOfFaultLabel.text = "CLEAN STRAINER"
            nameOfFaultLabel.textAlignment = .center
            readStarinerFaults()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if faultTag == 100{
            faultLabel.removeFromSuperview()
            faultIndex?.removeAll()
        } else {
            strainerLabel.removeFromSuperview()
            strainerFaultIndex?.removeAll()
        }
       
    }
    
    private func readNetworkFaults() {
        let offset = 30
        
        for (index,value) in faultIndex!.enumerated() {
            
            switch index {
            case 0...26:
                customizeFaultLabel(x: 62, y: (95 + (index * offset)), index: value)
            default:
                print("Wrong index")
            }
            
        }
    }
    
    private func readStarinerFaults() {
        for (index,value) in strainerFaultIndex!.enumerated() {
            let offset = 30
            
            switch index {
                case 0...26:
                    customizeStrainerFaultLabel(x: 25, y: (95 + (index * offset)), index: value)
                default:
                    print("Wrong index")
                }
        }
    }
    
    private func customizeFaultLabel(x: Int, y: Int, index: Int) {
        faultLabel = UILabel(frame: CGRect(x: x, y: y, width: 130, height: 20))
        faultLabel.textAlignment = .center
        faultLabel.textColor = RED_COLOR
        switch index {
            case 0:   faultLabel.text = "MW-103 REMIO"
            case 1:   faultLabel.text = "VFD-101"
            case 2:   faultLabel.text = "VFD-102"
            case 3:   faultLabel.text = "VFD-103"
            case 4:   faultLabel.text = "VFD-104"
            case 5:   faultLabel.text = "VFD-105"
            case 6:   faultLabel.text = "VFD-106"
            case 7:   faultLabel.text = "VFD-107"
            case 8:   faultLabel.text = "VFD-108"
            case 9:   faultLabel.text = "VFD-109"
            default:
                print("Wrong index")
        }
        self.view.addSubview(faultLabel)
    }
    
    private func customizeStrainerFaultLabel(x: Int, y: Int, index: Int) {
        if y > 505 {
           strainerLabel = UILabel(frame: CGRect(x: 200, y: y - 420, width: 150, height: 20))
        } else {
           strainerLabel = UILabel(frame: CGRect(x: x, y: y, width: 150, height: 20))
        }
        
        strainerLabel.textAlignment = .center
        strainerLabel.textColor = RED_COLOR
        switch index {
               case 0:   strainerLabel.text = "PSL-1001"
               case 1:   strainerLabel.text = "VFD-101"
               case 2:   strainerLabel.text = "VFD-102"
               case 3:   strainerLabel.text = "VFD-103"
               case 4:   strainerLabel.text = "VFD-104"
               case 5:   strainerLabel.text = "VFD-105"
               case 6:   strainerLabel.text = "VFD-106"
               case 7:   strainerLabel.text = "VFD-107"
               case 8:   strainerLabel.text = "VFD-108"
               case 9:   strainerLabel.text = "PT-1001"
            
        default:
            print("Wrong index")
        }
       
        self.view.addSubview(strainerLabel)
    }

    
}
