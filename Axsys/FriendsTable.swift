//
//  FriendsTable.swift
//  RPS
//
//  Created by Dillon Murphy on 12/20/15.
//  Copyright © 2015 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import BEMCheckBox
import ParseUI


var FriendsList: [PFUser] = [PFUser]()

struct FriendItem {
    var ProfileImage: PFFile?
    var Name: String?
    var user: PFUser?
}

var friendsSelected: [PFUser] = [PFUser]()


class  FriendsTable: UITableViewController, UISearchBarDelegate, MGSwipeTableCellDelegate, MAGearRefreshDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refresherControl : MAGearRefreshControl!
    var activityIndicatorView: NVActivityIndicatorView!
    
    var searching : Bool = false
    
    var cellHeight: CGFloat = 80.0
    var isLoading = false
    
    var scrollOrientation: UIImageOrientation!
    var lastPos: CGPoint!
    
    override func viewWillDisappear(animated: Bool) {
        friendsSelected.removeAll()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let resizer: UIImage = Images.resizeImage(UIImage(named: "ButterflyFinalIcon")!, width: 150, height: 150)!
        return resizer
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: "No Friends", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: "Search for new friends or connect with Facebook to get started!", attributes: attributes)
    }
    
    func spaceHeightForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return scrollView.bounds.height * 0.05
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        self.AddFriends(UIBarButtonItem())
    }
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(30.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: "Find Friends", attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return self.tableView.backgroundColor
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func createFriend(otherUser: PFUser) {
        let query = PFQuery(className: "Friend")
        query.whereKey("friendOf", equalTo: PFUser.currentUser()!)
        query.whereKey("friend", equalTo: otherUser)
        query.findObjectsInBackgroundWithBlock{
            objects, error in
            if error == nil {
                if objects?.count == 0 {
                    let friend = PFObject(className: "Friend")
                    friend.setObject(PFUser.currentUser()!, forKey: "friendOf")
                    friend.setObject(otherUser.username!, forKey: "friendName")
                    friend.setObject(otherUser, forKey: "friend")
                    friend.saveInBackgroundWithBlock({
                        success, error in
                        if error == nil {
                            if success == true {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            } else {
                let friend = PFObject(className: "Friend")
                friend.setObject(PFUser.currentUser()!, forKey: "friendOf")
                friend.setObject(otherUser.username!, forKey: "friendName")
                friend.setObject(otherUser, forKey: "friend")
                friend.saveInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        if success == true {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }
        let query2 = PFQuery(className: "Friend")
        query2.whereKey("friendOf", equalTo: otherUser)
        query2.whereKey("friend", equalTo: PFUser.currentUser()!)
        query2.findObjectsInBackgroundWithBlock{
            objects, error in
            if error == nil {
                if objects?.count == 0 {
                    let friend2 = PFObject(className: "Friend")
                    friend2.setObject(otherUser, forKey: "friendOf")
                    friend2.setObject(PFUser.currentUser()!.username!, forKey: "friendName")
                    friend2.setObject(PFUser.currentUser()!, forKey: "friend")
                    friend2.saveInBackground()
                }
            } else {
                let friend2 = PFObject(className: "Friend")
                friend2.setObject(otherUser, forKey: "friendOf")
                friend2.setObject(PFUser.currentUser()!.username!, forKey: "friendName")
                friend2.setObject(PFUser.currentUser()!, forKey: "friend")
                friend2.saveInBackground()
            }
        }
    }
    
    func getFriends() {
        FriendsList.removeAll()
        self.startActivityIndicator()
        let query = PFQuery(className: "Friend")
        query.whereKey("friendOf", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock{
            friends, error in
            if error == nil {
                for friend in friends! {
                    let otherUser = friend.objectForKey("friend") as? PFUser
                    FriendsList.append(otherUser!)
                }
                self.tableView.reloadData()
                self.stopActivityIndicator()
            }
        }
    }
    
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var rotationAndPerspectiveTransform = CATransform3DIdentity
        rotationAndPerspectiveTransform.m34 = 1.0 / -1000
        if (scrollOrientation == UIImageOrientation.Down) {
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, CGFloat(M_PI_2), 1.0, 0.0, 0.0)
        } else {
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -CGFloat(M_PI_2), 1.0, 0.0, 0.0)
        }
        cell.layer.transform = rotationAndPerspectiveTransform
        UIView.animateWithDuration(0.5, animations: {
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {refresherControl.MAGearRefreshScrollViewDidScroll(scrollView)
        scrollOrientation = scrollView.contentOffset.y > lastPos.y ? UIImageOrientation.Down : UIImageOrientation.Up
        lastPos = scrollView.contentOffset
    }
    
    override func viewDidLoad() {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
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
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(FriendsTable.backToLogin(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        let newButton2: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendsTable.AddFriends(_:)))
        newButton2.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(newButton2, animated: false)
        self.navigationItem.title = "Friends List"
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        getFriends()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refresherControl.MAGearRefreshScrollViewDidEndDragging(scrollView)
    }
    
    func MAGearRefreshTableHeaderDataSourceIsLoading(view: MAGearRefreshControl) -> Bool {
        return isLoading
    }
    
    func MAGearRefreshTableHeaderDidTriggerRefresh(view: MAGearRefreshControl) {
        getFriends()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        if searching == true {
            self.searchBar.placeholder = "Search User.."
            let newButton2: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendsTable.AddFriends(_:)))
            newButton2.tintColor = UIColor.whiteColor()
            self.navigationItem.setRightBarButtonItem(newButton2, animated: false)
            getFriends()
        } else {
            getFriends()
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //dispatch_async(dispatch_get_main_queue(), {self.loadFriends()})
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searching == false {
            let query = PFQuery(className: "Friend")
            query.whereKey("friendOf", equalTo: PFUser.currentUser()!)
            query.whereKey("friendName", hasPrefix: searchText)
            query.findObjectsInBackgroundWithBlock({
                objects, error in
                FriendsList.removeAll()
                for user in objects! {
                    let otherUser: PFUser = (user.objectForKey("friend") as? PFUser)!
                    FriendsList.append(otherUser)
                }
                self.tableView.reloadData()
            })
        } else if searching == true {
            let query = PFUser.query()
            query!.whereKey("fullname", hasPrefix: searchText)
            query!.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
            query!.findObjectsInBackgroundWithBlock({
                users, error in
                if error == nil {
                   for friend in (users as? [PFUser])! {
                        let query = PFQuery(className: "Friend")
                        query.whereKey("friendOf", equalTo: PFUser.currentUser()!)
                        query.whereKey("friend", equalTo: friend)
                        query.getFirstObjectInBackgroundWithBlock({
                            user, error in
                            if error != nil {
                                FriendsList.append(friend)
                            }
                        })
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        lastPos = self.view.center
    }
    
    func doneFriends(sender: UIBarButtonItem) {
        if self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
        }
        self.searchBar.placeholder = "Search User.."
        let newButton2: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(FriendsTable.AddFriends(_:)))
        newButton2.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(newButton2, animated: false)
    }
    
    func AddFriends(sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: "Add A Friend", message: "How would you like to add a friend?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Facebook = UIAlertAction(title: "Load Facebook Friends", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            let friendRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil)
            friendRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                guard let resultdict = result as? NSDictionary else {
                    ProgressHUD.showError("No Friends")
                    return
                }
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                for i in 0 ..< data.count
                {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let id: String = valueDict.objectForKey("id") as! String
                    let userQuery = PFUser.query()
                    userQuery?.whereKey("PushChannel", equalTo: id)
                    userQuery?.getFirstObjectInBackgroundWithBlock( { (object, error) in
                        if error == nil  {
                            let user = (object! as? PFUser)!
                            self.createFriend(user)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
        let Search = UIAlertAction(title: "Search Friends By Username", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.searching = true
            FriendsList.removeAll()
            self.searchBar.placeholder = "Enter username.."
            self.tableView.reloadData()
            let newButton2: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(FriendsTable.doneFriends(_:)))
            newButton2.tintColor = UIColor.whiteColor()
            self.navigationItem.setRightBarButtonItem(newButton2, animated: false)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Facebook)
        alertVC.addAction(Search)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendsList.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searching == true {
            let Friend = FriendsList[indexPath.row]
            sendFriendPush(Friend)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipeCell") as? SwipeCell
        let Message = Images.resizeImage(UIImage(named:"Messagebubble")!, width: cellHeight, height: cellHeight)!
        let Trash = Images.resizeImage(UIImage(named:"trash")!, width: cellHeight, height: cellHeight)!
        cell!.Name?.font = UIFont.boldSystemFontOfSize(35.0)
        cell!.Name?.adjustsFontSizeToFitWidth = true
        cell!.VC = self
        cell!.Name?.minimumScaleFactor = 0.5
        cell!.Name.textColor = .whiteColor()
        cell!.checkBox.center = (cell?.LoadingAnimator.center)!
        let Friend = FriendsList[indexPath.row]
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(Friend.objectId!, block: ({
            object, error in
            cell!.LoadingAnimator.stopAnimating()
            if error == nil {
                guard let User = object as? PFUser else {
                    return
                }
                cell!.ProfileImage.file = User[PF_USER_PICTURE] as? PFFile
                cell!.ProfileImage.loadInBackground()
                cell!.Name?.text = User["fullname"] as? String
            }
        }))
        let message: MGSwipeButton = MGSwipeButton(title: "", icon: Message, backgroundColor: .clearColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            self.startChat(Friend)
            return true
        })
        let delete : MGSwipeButton = MGSwipeButton(title: "", icon: Trash, backgroundColor: .clearColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            let list = FriendsList[indexPath.row]
            let query = PFQuery(className: "Friend")
            query.whereKey("friendOf", equalTo: PFUser.currentUser()!)
            query.whereKey("friend", equalTo: list)
            query.findObjectsInBackgroundWithBlock{
                friends, error in
                if error == nil {
                    for friend in friends! {
                        friend.deleteEventually()
                    }
                    self.tableView.reloadData()
                }
            }
            FriendsList.removeAtIndex(indexPath.row)
            return true
        })
        if searching == true {
            cell!.rightButtons = [message]
            cell!.LoadingAnimator.hidden = true
            cell!.checkBox.hidden = true
            //cell!.accessoryType = .None
        } else {
            cell!.rightButtons = [message, delete]
        }
        cell!.rightSwipeSettings.transition = MGSwipeTransition.Drag
        return cell!
    }

    func backToLogin(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func sendFriendPush(otherUser: PFUser) {
        let query = PFQuery(className: "Invite")
        query.whereKey("from", equalTo: PFUser.currentUser()!)
        query.whereKey("to", equalTo: otherUser)
        query.getFirstObjectInBackgroundWithBlock {
            invite, error in
            if error == nil {
                ProgressHUD.showError("Friend Request already sent to \(otherUser["fullname"] as! String)")
            } else {
                let Invite = PFObject(className: "Invite")
                Invite.setObject(PFUser.currentUser()!, forKey: "from")
                Invite.setObject(otherUser, forKey: "to")
                Invite.saveInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        let push = PFPush()
                        let data = [
                            "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) sent you a friend request",
                            "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                            "badge" : "Increment",
                            "type" : "friendInvite"
                        ]
                        let installQuery = PFInstallation.query()
                        installQuery?.whereKey("User", equalTo: otherUser)
                        push.setQuery(installQuery)
                        push.setData(data)
                        push.sendPushInBackgroundWithBlock({
                            success, error in
                            if error == nil {
                                ProgressHUD.showSuccess("Friend request sent to \(otherUser["fullname"] as! String)")
                            }
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func toFriends(segue: UIStoryboardSegue) {
        /*
        Empty. Exists solely so that "unwind to Login" segues can find
        instances of this class
        */
    }
    
    func sendGroupInvitePush(otherUser: PFUser) {
        let query = PFQuery(className: "Groups")
        query.whereKey("from", equalTo: PFUser.currentUser()!)
        query.whereKey("to", equalTo: otherUser)
        query.getFirstObjectInBackgroundWithBlock {
            invite, error in
            if error == nil {
                let push = PFPush()
                let data = [
                    "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) sent you a group request",
                    "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                    "groupID" : (myGroup?.objectId!)! as String,
                    "badge" : "Increment",
                    "type" : "groupInvite"
                ]
                
                let installQuery = PFInstallation.query()
                installQuery?.whereKey("User", equalTo: otherUser)
                push.setQuery(installQuery)
                push.setData(data)
                push.sendPushInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        self.searchBar.resignFirstResponder()
                    }
                })
                ProgressHUD.showError("Group Request already sent to \(otherUser["fullname"] as! String)")
            } else {
                let Group = PFObject(className: "Groups")
                Group.setObject(PFUser.currentUser()!, forKey: "from")
                Group.setObject(myGroup!.objectId!, forKey: "groupPass")
                Group.setObject(otherUser, forKey: "to")
                Group.saveInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        let push = PFPush()
                        let data = [
                            "alert" : "\((PFUser.currentUser()?.username!)! as String) sent you a group request",
                            "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                            "groupID" : (myGroup?.objectId!)! as String,
                            "badge" : "Increment",
                            "type" : "groupInvite"
                        ]
                        
                        let installQuery = PFInstallation.query()
                        installQuery?.whereKey("User", equalTo: otherUser)
                        push.setQuery(installQuery)
                        push.setData(data)
                        push.sendPushInBackgroundWithBlock({
                            success, error in
                            if error == nil {
                                self.searchBar.resignFirstResponder()
                                ProgressHUD.showSuccess("Group request sent to \(otherUser["fullname"] as! String)")
                            }
                        })
                    }
                })
            }
        }
    }
    
    func startChat(user: PFUser) {
        let query = PFQuery(className: "ChatGroup")
        query.whereKey("User1", equalTo: PFUser.currentUser()!)
        query.whereKey("User2", equalTo: user)
        query.getFirstObjectInBackgroundWithBlock {
            chat, error in
            if error == nil {
                groupPass = chat!.objectId
                chatTitle = user.username
                self.performSegueWithIdentifier("toChat", sender: nil)
            } else {
                let query2 = PFQuery(className: "ChatGroup")
                query2.whereKey("User2", equalTo: PFUser.currentUser()!)
                query2.whereKey("User1", equalTo: user)
                query2.getFirstObjectInBackgroundWithBlock {
                    chat, error in
                    if error == nil {
                        groupPass = chat!.objectId
                        chatTitle = user.username
                        self.performSegueWithIdentifier("toChat", sender: nil)
                    } else {
                        let ChatGroup = PFObject(className: "ChatGroup")
                        ChatGroup["LastUser"] = user
                        ChatGroup["LastMessage"] = "New Conversation With \(user["fullname"] as? String)"
                        ChatGroup["Users"] = [PFUser.currentUser()!, user]
                        ChatGroup["User1"] = PFUser.currentUser()!
                        ChatGroup["User2"] = user
                        ChatGroup.saveInBackgroundWithBlock({
                            success, error in
                            if error == nil {
                                groupPass = ChatGroup.objectId
                                chatTitle = user.username
                                if success == true {
                                    self.performSegueWithIdentifier("toChat", sender: nil)
                                }
                            }
                        })
                    }
                }
            }
        }
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
    
    
    func donePressed(sender: UIBarButtonItem) {
        LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: {
            location in
            let loc = location.coordinate
            let Group = PFObject(className: "Group")
            Group["Users"] = ["\(PFUser.currentUser()!.objectId!)"]
            Group["Description"] = "Create New Group Description"
            Group["GroupName"] = "Enter Group Name"
            Group["Location"] = PFGeoPoint(latitude: loc.latitude, longitude: loc.longitude)
            Group["Age"] = PFUser.currentUser()!["Age"]
            Group["Creator"] = PFUser.currentUser()!
            Group["Sex"] = PFUser.currentUser()!["Sex"]
            Group["Ages"] = ["18-20"]
            Group["Sexs"] = "Female"
            Group["Status"] = "Single"
            Group["Image"] = PFUser.currentUser()!["thumbnail"] as? PFFile
            Group.saveInBackgroundWithBlock({
                success, error in
                if error == nil {
                    myGroup = Group
                    if success == true {
                        for user in friendsSelected {
                            self.sendGroupInvitePush(user)
                        }
                        PFUser.currentUser()!["CurrentGroup"] = Group
                        PFUser.currentUser()!.saveInBackground()
                        self.performSegueWithIdentifier("toGroup", sender: nil)
                    }
                }
            })
        }) {
            error in
            
        }
    }
}


class SwipeCell: MGSwipeTableCell, BEMCheckBoxDelegate {
    
    @IBOutlet weak var ProfileImage: PFImageView!
    
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var LoadingAnimator: UIActivityIndicatorView!
    
    var user: PFUser = PFUser()


    var VC: FriendsTable!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ProfileImage.layer.cornerRadius = 8.0
        ProfileImage.layer.masksToBounds = true
        
    }
    
    func didTapCheckBox(checkBox: BEMCheckBox) {
        guard let indexpath = VC.tableView.indexPathForCell(self) else {return}
        if checkBox.on == true {
            if friendsSelected.count < 4 {
                let friend: PFUser = FriendsList[indexpath.row]
                if friendsSelected.contains(user) == false {
                    friendsSelected.append(friend)
                }
                Inviter()
            } else {
                checkBox.on = false
                ProgressHUD.showError("Too Many Friends Selected")
            }
            
        } else {
            if friendsSelected.contains(user) == true {
                friendsSelected.removeAtIndex(indexpath.row)
            }
        }
        print("Selected Count : \(friendsSelected.count), Players: \(friendsSelected)")
        Inviter()
    }
    
    func Inviter() {
        if friendsSelected.count > 0 {
            let newButton2: UIBarButtonItem = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: VC, action: #selector(FriendsTable.donePressed(_:)))
            newButton2.tintColor = UIColor.whiteColor()
            VC.navigationItem.setRightBarButtonItem(newButton2, animated: false)
        } else if friendsSelected.count == 0 {
            let newButton2: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add")!, style: UIBarButtonItemStyle.Plain, target: VC, action: #selector(FriendsTable.AddFriends(_:)))
            newButton2.tintColor = UIColor.whiteColor()
            VC.navigationItem.setRightBarButtonItem(newButton2, animated: false)
        }
    }
    
    func animationDidStopForCheckBox(checkBox: BEMCheckBox) {
        //ProgressHUD.showSuccess("Tapped Check Animation Done")
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
