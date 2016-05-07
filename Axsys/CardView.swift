//
//  CardView.swift
//  ZLSwipeableViewSwiftDemo
//
//  Created by Zhixuan Lai on 5/24/15.
//  Copyright (c) 2015 Zhixuan Lai. All rights reserved.
//
/*
import Foundation
import UIKit
import Parse
import ParseUI

class CardView: UIView {
    
    var GroupImage: PFImageView = PFImageView()
    
    var GroupID = ""
    
    var GroupName: UILabel = UILabel()
    
    var Group: [String] = [String]()
    
    var GroupLocation: UILabel = UILabel()
    
    var GroupDescription: UITextView!
    
    var UserLabels: [UILabel] = [UILabel]()
    var UserPics: [PFImageView] = [PFImageView]()
    
    init(frame: CGRect, groupID: String) {
        super.init(frame: frame)
        self.GroupID = groupID
        GroupImage.frame = CGRect(x: self.bounds.midX - (self.bounds.height / 8), y: 5, width: (self.bounds.height / 4), height: (self.bounds.height / 4))
        GroupImage.layer.cornerRadius = 8.0
        self.addSubview(GroupImage)
        GroupLocation.frame = CGRect(x: 0 , y: self.GroupImage.frame.maxY + 2, width: self.frame.width, height: 20)
        GroupLocation.backgroundColor = .clearColor()
        GroupLocation.textColor = .whiteColor()
        GroupLocation.textAlignment = .Center
        GroupLocation.numberOfLines = 2
        GroupLocation.adjustsFontSizeToFitWidth = true
        self.addSubview(GroupLocation)
        
        let textviewHeight = (self.frame.maxY - 94) - (self.GroupLocation.frame.height + self.GroupImage.frame.height)
        GroupDescription = UITextView(frame: CGRect(x: 5 , y: self.GroupLocation.frame.maxY + 84, width: self.frame.width - 10, height: textviewHeight))
        GroupDescription.textAlignment = NSTextAlignment.Left
        GroupDescription.textColor = UIColor.blackColor()
        GroupDescription.backgroundColor = UIColor.whiteColor()
        GroupDescription.layer.cornerRadius = 8.0
        GroupDescription.userInteractionEnabled = false
        self.addSubview(GroupDescription)
        
        let groupQuery = PFQuery(className: "Group")
        groupQuery.getObjectInBackgroundWithId(groupID, block: {
            object, error in
            if error == nil {
                
                self.GroupName.text = object!["GroupName"] as? String
                self.GroupDescription.text = object!["Description"] as! String
                self.GroupLocation.text = object!["GroupName"] as? String
                self.Group = object!["Users"] as! [String]
                self.GroupImage.image = UIImage(named: "profile")
                self.GroupImage.file = object!["Image"] as? PFFile
                self.GroupImage.loadInBackground {
                    image, error in
                    if error != nil {
                        print(error)
                    }
                }
                var headcount: CGFloat = 0
                while Int(headcount) < self.Group.count {
                    let width = self.bounds.width / CGFloat(self.Group.count)
                    let middle = (width / 2) - 20
                    let GroupUser: PFImageView = PFImageView(frame: CGRect(x: (width * headcount) + middle , y: self.GroupLocation.frame.maxY + 2, width: 40, height: 40))
                    GroupUser.layer.cornerRadius = 20
                    let UserLabel: UILabel = UILabel(frame: CGRect(x: GroupUser.frame.minX , y: GroupUser.frame.maxY + 2, width: GroupUser.frame.width, height: 30))
                    UserLabel.backgroundColor = .clearColor()
                    UserLabel.textColor = .whiteColor()
                    UserLabel.textAlignment = .Center
                    UserLabel.numberOfLines = 2
                    UserLabel.adjustsFontSizeToFitWidth = true
                    let userQuery = PFUser.query()
                    let userID: String = self.Group[Int(headcount)]
                    userQuery?.getObjectInBackgroundWithId(userID, block: {
                        object, error in
                        if error == nil {
                            let thisUser: PFUser = (object as? PFUser)!
                            UserLabel.text = thisUser.username
                            GroupUser.image = UIImage(named: "profile")
                            GroupUser.file = thisUser["thumbnail"] as? PFFile
                            GroupUser.loadInBackground {
                                image, error in
                                if error != nil {
                                    print(error)
                                }
                            }
                        }
                    })
                    self.UserLabels.append(UserLabel)
                    self.UserPics.append(GroupUser)
                    self.addSubview(UserLabel)
                    self.addSubview(GroupUser)
                    headcount += 1
                }
            }
        })
        setup()
    }
    
    func updateView() {
        UIView.animateWithDuration(0.1, animations: {
            self.GroupImage.frame = CGRect(x: self.bounds.midX - (self.bounds.height / 8), y: 5, width: (self.bounds.height / 4), height: (self.bounds.height / 4))
            self.GroupLocation.frame = CGRect(x: 0 , y: self.GroupImage.frame.maxY + 2, width: self.frame.width, height: 20)
            var headcount: CGFloat = 0
            while Int(headcount) < self.Group.count {
                let label = self.UserLabels[Int(headcount)]
                let pic = self.UserPics[Int(headcount)]
                let width = self.bounds.width / CGFloat(self.Group.count)
                let middle = (width / 2) - 20
                pic.frame = CGRect(x: (width * headcount) + middle , y: self.GroupLocation.frame.maxY + 2, width: 40, height: 40)
                label.frame = CGRect(x: pic.frame.minX , y: pic.frame.maxY + 2, width: pic.frame.width, height: 30)
                headcount += 1
            }
            let textviewHeight = (self.frame.maxY - 94) - (self.GroupLocation.frame.height + self.GroupImage.frame.height)
            self.GroupDescription.frame = CGRect(x: 5 , y: self.GroupLocation.frame.maxY + 84, width: self.frame.width - 10, height: textviewHeight)
        })
    }

    func reloadViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        GroupImage.frame = CGRect(x: self.bounds.midX - (self.bounds.height / 8), y: 5, width: (self.bounds.height / 4), height: (self.bounds.height / 4))
        GroupImage.layer.cornerRadius = 8.0
        self.addSubview(GroupImage)
        GroupLocation.frame = CGRect(x: 0 , y: self.GroupImage.frame.maxY + 2, width: self.frame.width, height: 20)
        GroupLocation.backgroundColor = .clearColor()
        GroupLocation.textColor = .whiteColor()
        GroupLocation.textAlignment = .Center
        GroupLocation.numberOfLines = 2
        GroupLocation.adjustsFontSizeToFitWidth = true
        self.addSubview(GroupLocation)
        
        let textviewHeight = (self.frame.maxY - 94) - (self.GroupLocation.frame.height + self.GroupImage.frame.height)
        GroupDescription = UITextView(frame: CGRect(x: 5 , y: self.GroupLocation.frame.maxY + 84, width: self.frame.width - 10, height: textviewHeight))
        GroupDescription.textAlignment = NSTextAlignment.Left
        GroupDescription.textColor = UIColor.blackColor()
        GroupDescription.backgroundColor = UIColor.whiteColor()
        GroupDescription.layer.cornerRadius = 8.0
        GroupDescription.userInteractionEnabled = false
        self.addSubview(GroupDescription)
        
        let groupQuery = PFQuery(className: "Group")
        groupQuery.getObjectInBackgroundWithId(self.GroupID, block: {
            object, error in
            if error == nil {
                
                self.GroupName.text = object!["GroupName"] as? String
                self.GroupDescription.text = object!["Description"] as! String
                self.GroupLocation.text = object!["GroupName"] as? String
                self.Group = object!["Users"] as! [String]
                self.GroupImage.image = UIImage(named: "profile")
                self.GroupImage.file = object!["Image"] as? PFFile
                self.GroupImage.loadInBackground {
                    image, error in
                    if error != nil {
                        print(error)
                    }
                }
                var headcount: CGFloat = 0
                while Int(headcount) < self.Group.count {
                    let width = self.bounds.width / CGFloat(self.Group.count)
                    let middle = (width / 2) - 20
                    let GroupUser: PFImageView = PFImageView(frame: CGRect(x: (width * headcount) + middle , y: self.GroupLocation.frame.maxY + 2, width: 40, height: 40))
                    GroupUser.layer.cornerRadius = 20
                    let UserLabel: UILabel = UILabel(frame: CGRect(x: GroupUser.frame.minX , y: GroupUser.frame.maxY + 2, width: GroupUser.frame.width, height: 30))
                    UserLabel.backgroundColor = .clearColor()
                    UserLabel.textColor = .whiteColor()
                    UserLabel.textAlignment = .Center
                    UserLabel.numberOfLines = 2
                    UserLabel.adjustsFontSizeToFitWidth = true
                    let userQuery = PFUser.query()
                    let userID: String = self.Group[Int(headcount)]
                    userQuery?.getObjectInBackgroundWithId(userID, block: {
                        object, error in
                        if error == nil {
                            let thisUser: PFUser = (object as? PFUser)!
                            UserLabel.text = thisUser.username
                            GroupUser.image = UIImage(named: "profile")
                            GroupUser.file = thisUser["thumbnail"] as? PFFile
                            GroupUser.loadInBackground {
                                image, error in
                                if error != nil {
                                    print(error)
                                }
                            }
                        }
                    })
                    
                    self.addSubview(UserLabel)
                    self.addSubview(GroupUser)
                    headcount += 1
                }
            }
        })
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        
        //Border
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2.0

        // Corner Radius
        layer.cornerRadius = 10.0
        
        

    }
}
*/

