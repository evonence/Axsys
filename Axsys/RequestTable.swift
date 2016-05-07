//
//  RequestTable.swift
//  RPSavas
//
//  Created by Dillon Murphy on 3/14/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

/*
import Foundation
import UIKit
import Parse
import ParseUI
import SwiftHTTP
import ParseFacebookUtilsV4

class  RequestTable: UITableViewController, MGSwipeTableCellDelegate, MAGearRefreshDelegate {
    
    var refresherControl : MAGearRefreshControl!
    var activityIndicatorView: NVActivityIndicatorView!
    var requestList: [PFObject] = []
    var cellHeight: CGFloat = 80.0
    var isLoading = false
    
    func startActivityIndicator() {
        let size = CGSize(width: 100.0, height: 100.0)
        let frame = CGRect(origin: self.view.center, size: size)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .BallTrianglePath, color: UIColor.redColor(), size: size)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.alpha = 0.9
        activityIndicatorView.startAnimation()
    }
    
    func stopActivityIndicator() {
        activityIndicatorView.stopAnimation()
    }

    func refresh(){
        isLoading = true
        dispatch_async(dispatch_get_main_queue(), {
            self.startActivityIndicator()
            let query = PFQuery(className: "GameInvite")
            query.whereKey("userID", equalTo: userChan)
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock({
                objects, error in
                if error == nil {
                    var checker: Int = 0
                    for object in objects! {
                        if self.requestList.count > 0 {
                            while checker < self.requestList.count {
                                let obj = self.requestList[checker]
                                let listUser: String = obj["User"] as! String
                                let pickedUser: String = object["User"] as! String
                                if listUser == pickedUser {
                                    object.deleteEventually()
                                } else {
                                    self.requestList.append(object)
                                }
                                checker++
                            }
                            checker = 0
                        } else {
                            self.requestList.append(object)
                        }
                    }
                    self.stopActivityIndicator()
                } else {
                    ProgressHUD.showError("Network Error: \(error?.localizedDescription)")
                }
            })
        })
        let delayInSeconds = 3.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.isLoading = false
            self.tableView.reloadData()
            self.stopActivityIndicator()
        }
    }
    
    override func viewDidLoad() {
        self.startActivityIndicator()
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
        refresh()
    }
    
    func loadRequests() {
        let query = PFQuery(className: "GameInvite")
        query.whereKey("userID", equalTo: userChan)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({
            objects, error in
            if error == nil {
                var checker: Int = 0
                for object in objects! {
                    if self.requestList.count > 0 {
                        while checker < self.requestList.count {
                            let obj = self.requestList[checker]
                            let listUser: String = obj["User"] as! String
                            let pickedUser: String = object["User"] as! String
                            if listUser == pickedUser {
                                object.deleteEventually()
                            } else {
                                self.requestList.append(object)
                            }
                            checker++
                        }
                        checker = 0
                    } else {
                        self.requestList.append(object)
                    }
                }
                self.tableView.reloadData()
                self.stopActivityIndicator()
            } else {
                ProgressHUD.showError("Network Error: \(error?.localizedDescription)")
            }
        })
        let delayInSeconds = 5.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            self.stopActivityIndicator()
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
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backToLogin:")
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        self.navigationItem.title = "Game Requests"
        tableView.dataSource = self
        tableView.delegate = self
        self.loadRequests()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let list = self.requestList[indexPath.row]
        let objID = list.objectId!
        let inviter = (list["User"] as? String)!
        SessionID = (list["Session"] as? String)!
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell") as? SwipeCell
        let Trash = Images.resizeImage(UIImage(named:"trash")!, width: cellHeight, height: cellHeight)!
        let Check = Images.resizeImage(UIImage(named:"Check-1")!, width: cellHeight, height: cellHeight)!
        cell!.textLabel?.font = UIFont.boldSystemFontOfSize(35.0)
        cell!.textLabel?.adjustsFontSizeToFitWidth = true
        cell!.textLabel?.minimumScaleFactor = 0.5
        let userQuery = PFUser.query()
        userQuery?.whereKey("PushChannel", equalTo: inviter)
        userQuery?.getFirstObjectInBackgroundWithBlock({
            object, error in
            if error == nil {
                guard let Username = object as? PFUser else {
                    return
                }
                cell!.ProfileImage.file = Username[PF_USER_PICTURE] as? PFFile
                cell!.ProfileImage.loadInBackground {
                    image, error in
                    if error != nil {
                        ProgressHUD.showError("Network Error")
                    }
                }
                cell!.Name?.text = "\(Username.username!) wants to play a game!"
            }
        })
        let accept : MGSwipeButton = MGSwipeButton(title: "", icon: Check, backgroundColor: UIColor.emeraldColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.startActivityIndicator()
            let query = PFQuery(className: "GameInvite")
            query.whereKey("Session", equalTo: SessionID)
            query.getFirstObjectInBackgroundWithBlock({
                object, error in
                if error == nil {
                    if userChan != object!["User"] as! String {
                        gameID = object!.objectId!
                        Token = object!["Token2"] as! String
                        self.sendGamePush(inviter, message: "\(userName) accepted your game invite")
                    } else {
                        gameID = object!.objectId!
                        Token = object!["Token"] as! String
                        self.sendGamePush(inviter, message: "\(userName) accepted your game invite")
                    }
                }
            })
            return true
        })
        let delete : MGSwipeButton = MGSwipeButton(title: "", icon: Trash, backgroundColor: UIColor.brickRedColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            let friendQuery = PFQuery(className: "GameInvite")
            friendQuery.getObjectInBackgroundWithId(objID, block: { (object, error) -> Void in
                if error == nil {
                    object?.deleteEventually()
                    self.tableView.reloadData()
                } else if error != nil {
                    ProgressHUD.showError("Network Error: \(error?.localizedDescription)")
                }
            })
            self.requestList.removeAtIndex(indexPath.row)
            return true
        })
        cell!.rightButtons = [accept, delete]
        cell!.rightSwipeSettings.transition = MGSwipeTransition.Drag
        return cell!
    }
    
    func sendGamePush(theirID: String, message: String) {
        let push = PFPush()
        let data = [
            "alert" : message,
            "badge" : "Increment",
            "ObjID" : userChan,
            "gameID" : gameID,
            "type" : "accepted"
        ]
        let userQuery = PFUser.query()
        userQuery?.whereKey("PushChannel", equalTo: theirID)
        userQuery?.getFirstObjectInBackgroundWithBlock({
            sentUser, error in
            if error != nil {
            } else if let user = sentUser {
                let installQuery = PFInstallation.query()
                installQuery?.whereKey("User", equalTo: user)
                push.setQuery(installQuery)
                push.setData(data)
                push.sendPushInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        if success == true {
                            let delayInSeconds = 0.6
                            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
                            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                                self.performSegueWithIdentifier("requestedGame", sender: nil)
                                self.stopActivityIndicator()
                            }
                        }
                    }
                })
            }
            self.stopActivityIndicator()
        })
    }

    func backToLogin(sender: UIButton) {
        self.performSegueWithIdentifier("backtoLogin", sender: nil)
    }
    
    @IBAction func toRequests(segue: UIStoryboardSegue) {
        /*
        Empty. Exists solely so that "unwind to Login" segues can find
        instances of this class.
        */
    }
}*/