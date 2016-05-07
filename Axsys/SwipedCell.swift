//
//  Swiped.swift
//  SkyeLync
//
//  Created by Dillon Murphy on 3/23/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//


import Foundation
import UIKit
import ParseUI

class SwipedCell: MGSwipeTableCell {
    
    @IBOutlet weak var ProfileImage: PFImageView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Description: UITextView!
    
    @IBOutlet weak var Age: UILabel!
    
    @IBOutlet weak var Sex: UILabel!

    @IBOutlet weak var Location: UILabel!
    
    @IBOutlet weak var Status: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProfileImage.layer.cornerRadius = 8.0
        ProfileImage.layer.masksToBounds = true
        
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}


class CommunityCell: MGSwipeTableCell {
    
    @IBOutlet weak var ProfileImage: PFImageView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var CommunityCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProfileImage.layer.cornerRadius = 8.0
        ProfileImage.layer.masksToBounds = true
        
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}