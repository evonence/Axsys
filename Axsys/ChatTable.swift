//
//  ChatTable.swift
//  SkyeLyncFinal
//
//  Created by Dillon Murphy on 4/23/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//
import Foundation
import UIKit
import BEMCheckBox
import ParseUI

class SwipeCell2: UITableViewCell {
    
    @IBOutlet weak var ProfileImage: PFImageView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Message: UILabel!
    
    @IBOutlet weak var MessageDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProfileImage.layer.cornerRadius = 8.0
        ProfileImage.layer.masksToBounds = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}



class  ChatTable: UITableViewController, MGSwipeTableCellDelegate, MAGearRefreshDelegate {
    
    var activityIndicatorView: NVActivityIndicatorView!
    var refresherControl : MAGearRefreshControl!
    var MessageList: [PFObject] = [PFObject]()
    var isLoading = false
    
    func startActivityIndicator() {
        let size = CGSize(width: 100.0, height: 100.0)
        let frame = CGRect(origin: self.view.center, size: size)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .BallTrianglePath, color: UIColor.clearColor(), size: size)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.alpha = 0.9
        activityIndicatorView.startAnimation()
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation()
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        refresherControl.MAGearRefreshScrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refresherControl.MAGearRefreshScrollViewDidEndDragging(scrollView)
    }
    
    func MAGearRefreshTableHeaderDataSourceIsLoading(view: MAGearRefreshControl) -> Bool {
        return isLoading
    }
    
    func MAGearRefreshTableHeaderDidTriggerRefresh(view: MAGearRefreshControl) {
        getMessages()
    }
    
    
    
    
    
    func deleteChat(users: [PFUser]) {
        let query = PFQuery(className: "ChatGroup")
        query.whereKey("Users", containsAllObjectsInArray: users)
        query.getFirstObjectInBackgroundWithBlock {
            chat, error in
            if error == nil {
                chat?.deleteEventually()
            }
        }
    }

    
    
    func getMessages() {
        self.startActivityIndicator()
        let query = PFQuery(className: "ChatGroup")
        query.whereKey("Users", containsAllObjectsInArray: [PFUser.currentUser()!])
        query.findObjectsInBackgroundWithBlock{
            groups, error in
            if error == nil {
                self.MessageList = groups!
                self.stopActivityIndicator()
                self.tableView.reloadData()
            }
            
        }
    }
    
    /*
     if section == 0 {
     return 1
     }
     
     
     var MessageList2: [Int:PFObject] = [Int:PFObject]()
     var messageGroups : [String] = [String]()
     
     for groupUser in groups! {
     let messageGroup = groupUser.objectId
     messageGroups.append(messageGroup!)
     }
     
     let myGroupArray: [String] = (myGroup!["Users"] as? [String])!
     if myGroupArray.count == messageGroups.count {
     let group1 = myGroupArray.sort()
     let group2 = messageGroups.sort()
     if group1 == group2 {
     self.MessageList2[0] = []
     }
     }
     */
    
    
    override func viewWillAppear(animated: Bool) {
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(ChatTable.backToLogin(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        
        refresherControl = MAGearRefreshControl(frame: CGRectMake(0, -self.tableView.bounds.height, self.view.frame.width, self.tableView.bounds.height))
        refresherControl.backgroundColor =  UIColor.blackColor()
        refresherControl.addInitialGear(nbTeeth:12, color: UIColor.coolGrayColor(), radius:16)
        refresherControl.addLinkedGear(0, nbTeeth:45, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(0, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(2, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(3, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 0, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(4, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 195, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(6, nbTeeth:30, color: UIColor.coolGrayColor(), angleInDegree: 170, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(6, nbTeeth:25, color: UIColor.coolGrayColor(), angleInDegree: 80, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(0, nbTeeth:45, color: UIColor.coolGrayColor(), angleInDegree: -100, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(2, nbTeeth:50, color: UIColor.coolGrayColor(), angleInDegree: 90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:20, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:14, color: UIColor.coolGrayColor(), angleInDegree: 150, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(5, nbTeeth:34, color: UIColor.coolGrayColor(), angleInDegree: 130, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(5, nbTeeth:54, color: UIColor.coolGrayColor(), angleInDegree: -115, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(4, nbTeeth:28, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(7, nbTeeth:35, color: UIColor.coolGrayColor(), angleInDegree: 90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(15, nbTeeth:47, color: UIColor.coolGrayColor(), angleInDegree: -150, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(15, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: -80, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(14, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 180, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(1, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 82, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(19, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(17, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: -40, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(9, nbTeeth:23, color: UIColor.coolGrayColor(), angleInDegree: -95, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(20, nbTeeth:42, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(14, nbTeeth:50, color: UIColor.coolGrayColor(), angleInDegree: -90, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(13, nbTeeth:24, color: UIColor.coolGrayColor(), angleInDegree: 65, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(13, nbTeeth:18, color: UIColor.coolGrayColor(), angleInDegree: 110, gearStyle: .WithBranchs)
        refresherControl.addLinkedGear(16, nbTeeth:19, color: UIColor.coolGrayColor(), angleInDegree: 20, gearStyle: .WithBranchs)
        refresherControl.delegate = self
        self.tableView.addSubview(refresherControl)
        self.navigationItem.title = "Messages"
        tableView.dataSource = self
        tableView.delegate = self
        getMessages()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell2") as? SwipeCell2
            let groupQuery = PFQuery(className: "Group")
            groupQuery.getObjectInBackgroundWithId((myGroup?.objectId)!, block: {
                object, error in
                if error == nil {
                    if object!["Image"] != nil {
                        cell!.ProfileImage.hidden = false
                    }
                    cell!.Name?.hidden = false
                    cell!.ProfileImage.file = object!["Image"] as? PFFile
                    cell!.ProfileImage.loadInBackground()
                    cell!.Name?.text  = object!["GroupName"] as? String
                    cell?.Message.textAlignment = .Center
                    cell?.Message.text = object!["Description"] as? String
                }
            })
            cell?.MessageDate.hidden = true
            return cell!
        } else {
            let message = self.MessageList[indexPath.row - 1]
            let lastuser: PFUser = message["LastUser"] as! PFUser
            let lastdate: NSDate = message.updatedAt!
            let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell2") as? SwipeCell2
            let userQuery = PFUser.query()
            userQuery?.getObjectInBackgroundWithId(lastuser.objectId!, block: ({
                object, error in
                if error == nil {
                    guard let Username = object as? PFUser else {
                        return
                    }
                    if Username[PF_USER_PICTURE] != nil {
                        cell!.ProfileImage.hidden = false
                    }
                    cell!.ProfileImage.file = Username[PF_USER_PICTURE] as? PFFile
                    cell!.ProfileImage.loadInBackground()
                    if Username != PFUser.currentUser() {
                        cell!.Name?.hidden = false
                        cell!.Name?.text = Username["fullname"] as? String
                    }
                }
            }))
            cell?.Message.text = message["LastMessage"] as? String
            cell?.MessageDate.text = lastdate.formatted
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            groupPass = myGroup!.objectId
            chatTitle = myGroup!["GroupName"] as? String
            self.performSegueWithIdentifier("toChat", sender: nil)
        } else {
            let message = self.MessageList[indexPath.row - 1]
            groupPass = message.objectId
            chatTitle = nil
            self.performSegueWithIdentifier("toChat", sender: nil)
        }
    }
    
    func backToLogin(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    @IBAction func toChats(segue: UIStoryboardSegue) {
        /*
         Empty. Exists solely so that "unwind to Login" segues can find
         instances of this class.
         */
    }
}