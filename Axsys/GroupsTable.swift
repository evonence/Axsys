//
//  GroupsTable.swift
//  SkyeLyncFinal
//
//  Created by Dillon Murphy on 4/17/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit


class  GroupsTable: UITableViewController, MGSwipeTableCellDelegate, MAGearRefreshDelegate {
    
    var activityIndicatorView: NVActivityIndicatorView!
    var refresherControl : MAGearRefreshControl!
    var groupsList: [PFObject] = [PFObject]()
    var cellHeight: CGFloat = 80.0
    var isLoading = false
    var userChan: String = ""
    
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
        getGroups()
    }
    
    func getGroups() {
        self.startActivityIndicator()
        let query = PFQuery(className: "Groups")
        query.whereKey("to", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock{
            groups, error in
            if error == nil {
                self.groupsList = groups!
                self.stopActivityIndicator()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
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
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(GroupsTable.backToLogin(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        self.navigationItem.title = "Group Requests"
        tableView.dataSource = self
        tableView.delegate = self
        getGroups()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }
    
    func addToGroup(groupID: String) {
        var grouper: PFObject?
        let queryRemove = PFQuery(className: "Group")
        queryRemove.whereKey("Users", containsAllObjectsInArray: [(PFUser.currentUser()?.objectId!)!])
        queryRemove.findObjectsInBackgroundWithBlock {
            removes, error in
            if error == nil {
                grouper = removes as? PFObject
                for remove in removes! {
                    var users: [String] = remove["Users"] as! [String]
                    let removeIndex = users.indexOf((PFUser.currentUser()?.objectId!)! as String)
                    users.removeAtIndex(removeIndex!)
                    if users.isEmpty {
                        remove.deleteInBackground()
                    } else {
                        remove["Users"] = users
                        remove.saveInBackground()
                    }
                }
                var users: [String] = grouper?["Users"] as! [String]
                users.append((PFUser.currentUser()?.objectId!)! as String)
                grouper?["Users"] = users
                myGroup = grouper
                PFUser.currentUser()!["CurrentGroup"] = grouper
                PFUser.currentUser()!.saveInBackground()
                grouper?.saveInBackground()
                let query = PFQuery(className: "Group")
                query.getObjectInBackgroundWithId(groupID, block: ({
                    group, error in
                    if error == nil {
                        
                    }
                }))
            }
        }
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let list = self.groupsList[indexPath.row]
        let otherUser: PFUser = (list.objectForKey("from") as? PFUser)!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell") as? SwipeCell
        let Trash = Images.resizeImage(UIImage(named:"trash")!, width: cellHeight, height: cellHeight)!
        let Check = Images.resizeImage(UIImage(named:"Check-1")!, width: cellHeight, height: cellHeight)!
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(35.0)
        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.minimumScaleFactor = 0.5
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(otherUser.objectId!, block: ({
            object, error in
            if error == nil {
                guard let Username = object as? PFUser else {
                    return
                }
                cell!.ProfileImage.file = Username[PF_USER_PICTURE] as? PFFile
                cell!.ProfileImage.loadInBackground()
                let nameString: String = Username.username!
                cell!.Name?.text = "\(nameString) sent you a group request!"
            }
        }))
        let accept : MGSwipeButton = MGSwipeButton(title: "", icon: Check, backgroundColor: UIColor.clearColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            let push = PFPush()
            let groupPass: String = list["groupPass"] as! String
            let data = [
                "alert" : "\((PFUser.currentUser()?.username!)! as String) accepted your group request",
                "badge" : "Increment",
                "groupID" : groupPass,
                "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                "type" : "groupAccepted"]
            let installQuery = PFInstallation.query()
            installQuery?.whereKey("User", equalTo: otherUser)
            push.setQuery(installQuery)
            push.setData(data)
            push.sendPushInBackgroundWithBlock({
                success, error in
                if error == nil {
                    ProgressHUD.showSuccess("Group request accepted")
                }
            })
            self.addToGroup(groupPass)
        
            let query = PFQuery(className: "Groups")
            query.whereKey("to", equalTo: PFUser.currentUser()!)
            query.whereKey("from", equalTo: otherUser)
            query.findObjectsInBackgroundWithBlock{
                invites, error in
                if error == nil {
                    for invite in invites! {
                        invite.deleteEventually()
                    }
                    self.tableView.reloadData()
                } else if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                }
            }
            self.groupsList.removeAtIndex(indexPath.row)
            return true
        })
        let delete : MGSwipeButton = MGSwipeButton(title: "", icon: Trash, backgroundColor: UIColor.clearColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            let query = PFQuery(className: "Groups")
            query.whereKey("to", equalTo: PFUser.currentUser()!)
            query.whereKey("from", equalTo: otherUser)
            query.findObjectsInBackgroundWithBlock{
                invites, error in
                if error == nil {
                    for invite in invites! {
                        invite.deleteEventually()
                    }
                    self.tableView.reloadData()
                } else if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                }
                
            }
            self.groupsList.removeAtIndex(indexPath.row)
            return true
        })
        cell!.rightButtons = [accept, delete]
        cell!.rightSwipeSettings.transition = MGSwipeTransition.Drag
        return cell!
    }
    
    func backToLogin(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    
}