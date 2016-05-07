//
//  CustomCallout.swift
//  SkyeLync
//
//  Created by Dillon Murphy on 4/7/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import ParseUI


class CustomCallout: UIView {
    

    @IBOutlet weak var CalloutIcon: PFImageView!

    @IBOutlet weak var CalloutSegmented: UISegmentedControl!

    @IBOutlet weak var CalloutSwitch: UISwitch!
    
    @IBOutlet weak var CalloutLocation: UILabel!
    
    @IBOutlet weak var SendPush: UIButton!
}