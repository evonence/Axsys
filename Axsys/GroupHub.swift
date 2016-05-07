//
//  GroupHub.swift
//  SkyeLync
//
//  Created by Dillon Murphy on 4/5/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GIFRefreshControl
import ParseUI



var GroupImage: PFImageView!


class GroupHub: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, MultiSelectSegmentedControlDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    @IBOutlet weak var GroupTable: UITableView!
    @IBOutlet weak var GroupImage: PFImageView!
    @IBOutlet weak var myProfileImage: PFImageView!
    
    
    @IBOutlet weak var UserStack: UIStackView!
    @IBOutlet weak var User1Stack: UIStackView!
    @IBOutlet weak var User2Stack: UIStackView!
    @IBOutlet weak var User3Stack: UIStackView!
    @IBOutlet weak var User4Stack: UIStackView!
    
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var UserLabel1: UILabel!
    @IBOutlet weak var UserLabel2: UILabel!
    @IBOutlet weak var UserLabel3: UILabel!
    
    @IBOutlet weak var UserImage: PFImageView!
    @IBOutlet weak var UserImage1: PFImageView!
    @IBOutlet weak var UserImage2: PFImageView!
    @IBOutlet weak var UserImage3: PFImageView!
    
    @IBOutlet weak var message: UIButton!
    
    @IBOutlet weak var GroupName: UILabel!
    
    var Group: [String] = [String]()
    
    var heighter: CGFloat!
    
    var myGroupHidden = false
    
    
    var communities: [String] = ["Buckhead", "Midtown", "Virginia Highlands", "Emory University", "Edgewood/Downtown", "East Atlanta"]
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    var pickOption = ["Bars", "Ballgame", "Concert", "Hang Out", "Park", "Something Different"]
    
    var communitiesFilter: [String] = [String]()
    var agesFilter: [String] = [String]()
    var genderFilter: [String] = [String]()
    
    var matches: [PFObject]?
    
    var groupID = "TtdcdRJ0Z2"
    
    var activityIndicatorView : NVActivityIndicatorView!
    
    var community = true
    var scrollOrientation: UIImageOrientation!
    var lastPos: CGPoint!
    
    var Tapper: UITapGestureRecognizer?
    var Tapper1: UITapGestureRecognizer?
    var Tapper2: UITapGestureRecognizer?
    var Tapper3: UITapGestureRecognizer?
    var Tapper4: UITapGestureRecognizer?
    
    //var senduser = 0
    
    var users: [Int: PFUser] = [Int: PFUser]()
    
    @IBOutlet weak var TypeSegment: UISegmentedControl!
    
    @IBOutlet weak var StatusSegment: UISegmentedControl!
    
    @IBOutlet weak var GenderSegment: UISegmentedControl!
    
    @IBOutlet weak var AgeSegment: MultiSelectSegmentedControl!
    
    @IBOutlet weak var CommunitySegment: UISegmentedControl!

    @IBOutlet weak var myGroupView: UIView!
    
    @IBAction func FilterChanged(sender: UISegmentedControl) {
        switch(sender.selectedSegmentIndex) {
            case 0:
                self.CommunitySegment.hidden = false
                self.pickerTextField.hidden = true
                self.AgeSegment.hidden = true
                self.GenderSegment.hidden = true
                self.StatusSegment.hidden = true
            case 1:
                self.pickerTextField.hidden = true
                self.CommunitySegment.hidden = true
                self.AgeSegment.hidden = false
                self.GenderSegment.hidden = true
                self.StatusSegment.hidden = true
            case 2:
                self.pickerTextField.hidden = true
                self.CommunitySegment.hidden = true
                self.AgeSegment.hidden = true
                self.GenderSegment.hidden = false
                self.StatusSegment.hidden = true
            case 3:
                self.pickerTextField.hidden = true
                self.CommunitySegment.hidden = true
                self.AgeSegment.hidden = true
                self.GenderSegment.hidden = true
                self.StatusSegment.hidden = false
            case 4:
                self.pickerTextField.hidden = false
                self.CommunitySegment.hidden = true
                self.AgeSegment.hidden = true
                self.GenderSegment.hidden = true
                self.StatusSegment.hidden = true
            case 5:
                self.community = true
                self.pickerTextField.hidden = true
                self.CommunitySegment.hidden = true
                self.AgeSegment.hidden = true
                self.GenderSegment.hidden = true
                self.StatusSegment.hidden = true
                self.TypeSegment.hidden = true
                self.GroupTable.reloadData()
            default: break
        }
    }
    
    @IBAction func GenderChanged(sender: UISegmentedControl) {
        if matches != nil {
            matches!.removeAll()
            loadGroups()
        }
    }
    
    @IBAction func CommunityChanged(sender: UISegmentedControl) {
        if matches != nil {
            matches!.removeAll()
            loadGroups()
        }
    }
    
    @IBAction func StatusChanges(sender: UISegmentedControl) {
        if matches != nil {
            matches!.removeAll()
            loadGroups()
        }
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickOption.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row]
    }

    
    func communityString(string: String) {
        if communitiesFilter.contains(string) {
            let removeIndex = communitiesFilter.indexOf(string)
            communitiesFilter.removeAtIndex(removeIndex!)
        } else {
            communitiesFilter.append(string)
        }
    }
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
       if multiSelecSegmendedControl == AgeSegment {
            switch(index) {
            case 0:
                if agesFilter.contains("18-20") {
                    let removeIndex = agesFilter.indexOf("18-20")
                    agesFilter.removeAtIndex(removeIndex!)
                } else {
                    agesFilter.append("18-20")
                }
            case 1:
                if agesFilter.contains("21-24") {
                    let removeIndex = agesFilter.indexOf("21-24")
                    agesFilter.removeAtIndex(removeIndex!)
                } else {
                    agesFilter.append("21-24")
                }
            case 2:
                if agesFilter.contains("25-29") {
                    let removeIndex = agesFilter.indexOf("25-29")
                    agesFilter.removeAtIndex(removeIndex!)
                } else {
                    agesFilter.append("25-29")
                }
            case 3:
                if agesFilter.contains("30+") {
                    let removeIndex = agesFilter.indexOf("30+")
                    agesFilter.removeAtIndex(removeIndex!)
                } else {
                    agesFilter.append("30+")
                }
            default: break
            }
        }
        loadGroups()
    }
    
    
    /*
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
    }*/
    
    override func viewWillAppear(animated: Bool) {
        lastPos = self.view.center
        self.navigationItem.title = "Axsys"
        GroupTable.backgroundColor = UIColor(rgba: (r: 0.713353, g: 0.220056, b: 0.314792, a: 1.0))
        myGroupView.backgroundColor = UIColor(rgba: (r: 0.713353, g: 0.220056, b: 0.314792, a: 1.0))
        
        GroupTable.emptyDataSetSource = self
        GroupTable.emptyDataSetDelegate = self
        
        let newButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupHub.AddFriends(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(newButton, animated: false)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 37))
        button.setImage(UIImage(named: "ButterflyFinalIconPin"), forState:.Normal)
        button.addTarget(self, action: #selector(GroupHub.ShowMaps(_:)), forControlEvents: .TouchUpInside)
        let newButton2: UIBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.setLeftBarButtonItem(newButton2, animated: false)
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .whiteColor()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerTextField.inputView = pickerView
        pickerTextField.addDoneButton()
        setupGroup()
    }
    
    override func viewDidLoad() {
        if PFUser.currentUser() != nil {
            loadGroups()
            let application = UIApplication.sharedApplication()
            if application.isRegisteredForRemoteNotifications() == false{
                let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
                application.registerForRemoteNotifications()
                application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
                application.registerUserNotificationSettings(settings)
            } else {
                let install = PFInstallation.currentInstallation()
                install["User"] = PFUser.currentUser()
                install.saveEventually()
            }
            AgeSegment.delegate = self
        }
    }
    
    func filterQueryLocations(query: PFQuery) {
        if communitiesFilter == ["Buckhead"] {
            let swOfSF = PFGeoPoint(latitude:33.7980419700625, longitude: -84.4585924716122)
            let neOfSF = PFGeoPoint(latitude:33.8906195711756,longitude: -84.3335736475925)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        } else if communitiesFilter == ["Midtown"] {
            let swOfSF = PFGeoPoint(latitude:33.7710121345731, longitude: -84.3926737484494)
            let neOfSF = PFGeoPoint(latitude:33.8033122102203,longitude: -84.3645354950816)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        } else if communitiesFilter ==  ["Virginia Highlands"] {
            let swOfSF = PFGeoPoint(latitude:33.7713531029848,longitude: -84.3818832995528)
            let neOfSF = PFGeoPoint(latitude:33.7980207611475,longitude: -84.3404872897812)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        } else if communitiesFilter ==  ["Emory University"] {
            let swOfSF = PFGeoPoint(latitude:33.7856195504572,longitude: -84.338509744865)
            let neOfSF = PFGeoPoint(latitude:33.8094464767409,longitude: -84.2975650526133)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        } else if communitiesFilter ==  ["Edgewood/Downtown"] {
            let swOfSF = PFGeoPoint(latitude:33.7323441018936,longitude: -84.4044592136598)
            let neOfSF = PFGeoPoint(latitude:33.774567310574,longitude: -84.3574189167837)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        } else if communitiesFilter ==  ["East Atlanta"] {
            let swOfSF = PFGeoPoint(latitude:33.7183448037208,longitude: -84.3549105852025)
            let neOfSF = PFGeoPoint(latitude:33.7468168747172,longitude: -84.3151052744387)
            query.whereKey("Location", withinGeoBoxFromSouthwest:swOfSF, toNortheast:neOfSF)
        }
    }
    
    
    func loadGroups() {
        //self.startActivityIndicator()
        let groupQuery = PFQuery(className: "Group")
        switch(CommunitySegment.selectedSegmentIndex) {
            case 0: communitiesFilter = ["Buckhead"]
            filterQueryLocations(groupQuery)
            case 1: communitiesFilter = ["Midtown"]
            filterQueryLocations(groupQuery)
            case 2: communitiesFilter = ["Virginia Highlands"]
            filterQueryLocations(groupQuery)
            case 3: communitiesFilter = ["Emory University"]
            filterQueryLocations(groupQuery)
            case 4: communitiesFilter = ["Edgewood/Downtown"]
            filterQueryLocations(groupQuery)
            case 5: communitiesFilter = ["East Atlanta"]
            filterQueryLocations(groupQuery)
            default: break
        }
        if agesFilter.isEmpty == false {
            print("\(agesFilter)")
            groupQuery.whereKey("Age", containedIn: agesFilter)
        }
        switch(GenderSegment.selectedSegmentIndex) {
            case 0: groupQuery.whereKey("Sex", equalTo: "Male")
            case 1: groupQuery.whereKey("Sex", equalTo: "Female")
            default: break
        }
        switch(StatusSegment.selectedSegmentIndex) {
        case 0: groupQuery.whereKey("Status", equalTo: "Single")
        case 1: groupQuery.whereKey("Status", equalTo: "Couple")
        default: break
        }
        groupQuery.addAscendingOrder("createdAt")
        groupQuery.whereKey("objectId", notEqualTo: "TtdcdRJ0Z2")
        groupQuery.findObjectsInBackgroundWithBlock({
            objects, error in
            if error == nil {
                self.matches = objects!
                //self.stopActivityIndicator()
                self.GroupTable.layer.cornerRadius = 8.0
                self.GroupTable.reloadData()
            }
        })
    }
    
    
    
    func TapperTapped(sender: UITapGestureRecognizer) {
        if sender.view == GroupImage {
            if myGroup != nil {
                self.performSegueWithIdentifier("toGroupProfile", sender: nil)
            } else {
                ProgressHUD.showError("Join a group to view your Group Profile")
            }
        } else {
            if sender == Tapper1 {
                profileUser = users[0]
            } else if sender == Tapper2 {
                profileUser = users[1]
            } else if sender == Tapper3 {
                profileUser = users[3]
            } else if sender == Tapper4 {
                profileUser = users[4]
            }
            self.performSegueWithIdentifier("toProfile", sender: nil)
        }
    }
    
    func ShowMaps(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("toMap", sender: nil)
    }

   
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        let resizer: UIImage = Images.resizeImage(UIImage(named: "ButterflyFinalIcon")!, width: 150, height: 150)!
        return resizer
    }
    
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: "No Groups", attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Center
        let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor(), NSParagraphStyleAttributeName: paragraph]
        return NSAttributedString(string: "Remove Group Filters To Expand Your Search And Find A Group", attributes: attributes)
    }
    
    func spaceHeightForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return scrollView.bounds.height * 0.05
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor(rgba: (r: 0.713353, g: 0.220056, b: 0.314792, a: 1.0))
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func AddFriends(sender: UIBarButtonItem) {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Button1 = UIAlertAction(title: "Friends List", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("toFriends", sender: nil)
        }
        let Button2 = UIAlertAction(title: "Friend Requests", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("toInvites", sender: nil)
        }
        let Button3 = UIAlertAction(title: "Group Requests", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("GroupsInvites", sender: nil)
            //toInvites
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Button1)
        alertVC.addAction(Button2)
        alertVC.addAction(Button3)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if community == true {
            return 6
        }
        if matches!.count == 0 {
            GroupTable.separatorStyle = .None
        } else {
            GroupTable.separatorStyle = .SingleLine
        }
        return matches!.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if community == true {
            //GroupTable.scrollEnabled = false
            return GroupTable.frame.height / CGFloat(communities.count)
        }
        return 120.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if community == true {
            var userImage: [MGSwipeButton] = [MGSwipeButton]()
            let cell: CommunityCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! CommunityCell
            cell.Name.text = self.communities[indexPath.row]
            let message: MGSwipeButton = MGSwipeButton(title: "", icon: UIImage(named: "Messagebubble"), backgroundColor: self.myGroupView.backgroundColor, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                myGroup = nil
                chatTitle = self.communities[indexPath.row]
                groupPass = self.communities[indexPath.row]
                self.performSegueWithIdentifier("thisChat", sender: nil)
                return true
            })
            message.buttonWidth = 120.0
            userImage.append(message)
            cell.rightButtons = userImage
            cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SwipedCell") as? SwipedCell
        if matches!.count > indexPath.row {
            let match = matches![indexPath.row]
            
            let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(16.0)]
            let string: NSMutableAttributedString = NSMutableAttributedString(string: (match["Description"] as? String)!, attributes: attributes)
            cell?.Description.attributedText = string
            
            cell?.Age.textColor = .whiteColor()
            cell?.Age.adjustsFontSizeToFitWidth = true
            cell?.Age.text = match["Age"] as? String
            
            cell?.Sex.textColor = .whiteColor()
            cell?.Sex.adjustsFontSizeToFitWidth = true
            cell?.Sex.text = match["Sex"] as? String
            
            cell?.Status.text = match["Status"] as? String
            
            cell?.Location.textColor = .whiteColor()
            cell?.Location.adjustsFontSizeToFitWidth = true
            //let point = match["Location"] as? PFGeoPoint
            //let GroupPoint: MKMapPoint = MKMapPoint(x: (point?.latitude)!,y: (point?.longitude)!)
            
            if CommunitySegment.selectedSegmentIndex == 6 {
                cell?.Location.hidden = true
            } else {
                switch(CommunitySegment.selectedSegmentIndex) {
                case 0: cell?.Location.text = "Buckhead"
                case 1: cell?.Location.text = "Midtown"
                case 2: cell?.Location.text = "Virginia Highlands"
                case 3: cell?.Location.text = "Emory University"
                case 4: cell?.Location.text = "Edgewood/Downtown"
                case 5: cell?.Location.text = "East Atlanta"
                default: break
                }
            }
            //33.8373° N, 84.4068
            
            cell?.Name.textColor = .whiteColor()
            cell?.Name.adjustsFontSizeToFitWidth = true
            cell?.Name.text = match["GroupName"] as? String
            cell?.ProfileImage.file = match["Image"] as? PFFile
            cell?.ProfileImage.loadInBackground {
                image, error in
                if error != nil {
                    print(error)
                }
            }
            let PinImage: UIImage = Images.resizeImage(UIImage(named: "ButterflyFinalIconPin")!, width: self.GroupTable.frame.height / 6, height: self.GroupTable.frame.height / 6)!
            let Pin: MGSwipeButton = MGSwipeButton(title: "", icon: PinImage, backgroundColor: self.myGroupView.backgroundColor, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                self.performSegueWithIdentifier("toMapPicker", sender: nil)
                return true
            })
            Pin.buttonWidth = 120.0
            let Messager2: UIImage = Images.resizeImage(UIImage(named: "Messagebubble")!, width: self.GroupTable.frame.height / 6, height: self.GroupTable.frame.height / 6)!
            let message2: MGSwipeButton = MGSwipeButton(title: "", icon: Messager2, backgroundColor: self.myGroupView.backgroundColor, callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                self.startGroupChat(match)
                return true
            })
            message2.buttonWidth = 120.0
            cell!.leftButtons = [Pin, message2]
            cell!.leftSwipeSettings.transition = MGSwipeTransition.Drag
            let groupQuery = PFQuery(className: "Group")
            groupQuery.getObjectInBackgroundWithId(match.objectId!, block: {
                object, error in
                if error == nil {
                    let Group: [String] = object!["Users"] as! [String]
                    var headcount = 0
                    var userImage: [MGSwipeButton] = [MGSwipeButton]()
                    while headcount < Group.count {
                        let objID = Group[headcount]
                        let userQuery = PFUser.query()
                        userQuery?.getObjectInBackgroundWithId(objID, block: {
                            user, error in
                            if error == nil {
                                let objectImage: PFImageView = PFImageView(image: UIImage(named: "ButterflyFinalIcon"))
                                objectImage.file = user!["profPic"] as? PFFile
                                objectImage.contentMode = .ScaleAspectFill
                                objectImage.loadInBackground {
                                    image, error in
                                    if error != nil {
                                        print(error)
                                    } else {
                                        let user = user as! PFUser
                                        if image != nil {
                                            let Messager: UIImage = Images.resizeImage(image!, width: self.GroupTable.frame.height / 6, height: self.GroupTable.frame.height / 6)!
                                            let message: MGSwipeButton = MGSwipeButton(title: user["fullname"] as? String, icon: Messager, backgroundColor: self.myGroupView.backgroundColor, callback: {
                                                (sender: MGSwipeTableCell!) -> Bool in
                                                profileUser = user
                                                self.performSegueWithIdentifier("toProfile", sender: nil)
                                                return true
                                            })
                                            message.buttonWidth = 100.0
                                            message.centerIconOverText()
                                            userImage.append(message)
                                            cell!.rightButtons = userImage
                                            cell!.rightSwipeSettings.transition = MGSwipeTransition.Drag
                                        } else {
                                            let message: MGSwipeButton = MGSwipeButton(title: user["fullname"] as? String, icon: UIImage(named: "profile"), backgroundColor: self.myGroupView.backgroundColor, callback: {
                                                (sender: MGSwipeTableCell!) -> Bool in
                                                profileUser = user
                                                self.performSegueWithIdentifier("toProfile", sender: nil)
                                                return true
                                            })
                                            message.buttonWidth = 100.0
                                            message.centerIconOverText()
                                            userImage.append(message)
                                            cell!.rightButtons = userImage
                                            cell!.rightSwipeSettings.transition = MGSwipeTransition.Drag
                                        }
                                    }
                                }
                            }
                        })
                        headcount += 1
                    }
                }
            })
        }
        return cell!
    }
    
    
    
    func startGroupChat(group: PFObject) {
        //self.startActivityIndicator()
        let query = PFQuery(className: "ChatGroup")
        query.whereKey("Group1", equalTo: myGroup!)
        query.whereKey("Group2", equalTo: group)
        query.getFirstObjectInBackgroundWithBlock {
            chat, error in
            if error == nil {
                groupPass = chat!.objectId
                //self.stopActivityIndicator()
                self.performSegueWithIdentifier("thisChat", sender: nil)
            } else {
                let query2 = PFQuery(className: "ChatGroup")
                query2.whereKey("Group2", equalTo: myGroup!)
                query2.whereKey("Group1", equalTo: group)
                query2.getFirstObjectInBackgroundWithBlock {
                    chat, error in
                    if error == nil {
                        groupPass = chat!.objectId
                        //self.stopActivityIndicator()
                        self.performSegueWithIdentifier("thisChat", sender: nil)
                    } else {
                        let ChatGroup = PFObject(className: "ChatGroup")
                        ChatGroup["LastUser"] = PFUser.currentUser()!
                        ChatGroup["LastMessage"] = "NewMessage"
                        ChatGroup["Group1"] = myGroup
                        ChatGroup["Group2"] = group
                        ChatGroup.saveInBackgroundWithBlock({
                            success, error in
                            if error == nil {
                                if success == true {
                                    groupPass = ChatGroup.objectId
                                    //self.stopActivityIndicator()
                                    self.performSegueWithIdentifier("thisChat", sender: nil)
                                    var messageUsers: [PFUser] = [PFUser]()
                                    let groupUsers = group["Users"] as! [String]
                                    var headcount = 0
                                    for user in groupUsers {
                                        let userQuery = PFUser.query()
                                        userQuery?.getObjectInBackgroundWithId(user, block: {
                                            user, error in
                                            if error === nil {
                                                if messageUsers.contains(user as! PFUser) {} else {
                                                    messageUsers.append(user as! PFUser)
                                                }
                                                headcount += 1
                                                if headcount == groupUsers.count {
                                                    if myGroup != nil {
                                                        var headcount2 = 0
                                                        for user in myGroup?["Users"] as! [String] {
                                                            let userQuery2 = PFUser.query()
                                                            userQuery2?.getObjectInBackgroundWithId(user, block: {
                                                                user2, error in
                                                                if error === nil {
                                                                    if messageUsers.contains(user2 as! PFUser) {} else {
                                                                        messageUsers.append(user2 as! PFUser)
                                                                    }
                                                                    headcount2 += 1
                                                                    if headcount2 == (myGroup?["Users"] as! [String]).count {
                                                                        if messageUsers.contains(PFUser.currentUser()!) {} else {
                                                                            messageUsers.append(PFUser.currentUser()!)
                                                                        }
                                                                        ChatGroup["Users"] = messageUsers
                                                                        ChatGroup.saveInBackground()
                                                                    }
                                                                }
                                                            })
                                                        }
                                                    } else {
                                                        if messageUsers.contains(PFUser.currentUser()!) {} else {
                                                            messageUsers.append(PFUser.currentUser()!)
                                                        }
                                                        ChatGroup["Users"] = messageUsers
                                                        ChatGroup.saveInBackground()
                                                    }
                                                }
                                            }
                                        })
                                    }
                                    
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell is CommunityCell {
            TypeSegment.hidden = false
            community = false
            CommunitySegment.selectedSegmentIndex = indexPath.row
            loadGroups()
            tableView.reloadData()
        } else {
            groupProfile = matches![indexPath.row]
            self.performSegueWithIdentifier("toGroupProfile", sender: nil)
        }
    }

    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if community == false {
            scrollOrientation = scrollView.contentOffset.y > lastPos.y ? UIImageOrientation.Down : UIImageOrientation.Up;
            lastPos = scrollView.contentOffset;
        }
    }
    
    @IBAction func unwindToGroupHub(segue: UIStoryboardSegue) {
        /*
         Empty. Exists solely so that "unwind to Login" segues can find
         instances of this class.
         */
    }
    
    func tappedProfile(sender: UITapGestureRecognizer) {
        profileUser = PFUser.currentUser()!
        self.performSegueWithIdentifier("toProfile", sender: nil)
    }
    
    
    override func viewWillLayoutSubviews() {
        message.layer.cornerRadius = 8.0
        myGroupView.layer.cornerRadius = 8.0
    }
    
    func setupGroup() {
        if PFUser.currentUser()!["CurrentGroup"] != nil {
            myGroup = PFUser.currentUser()!["CurrentGroup"] as? PFObject
        }
        if myGroup != nil {
            groupID = (myGroup?.objectId!)!
            self.myGroupView.frame = CGRect(x: self.myGroupView.frame.minX, y: self.myGroupView.frame.minY - 70, width: self.myGroupView.frame.width, height: 140)
        } else {
            self.myGroupView.frame = CGRect(x: self.myGroupView.frame.minX, y: self.myGroupView.frame.minY, width: self.myGroupView.frame.width, height: 70)
        }
        
        Tapper = UITapGestureRecognizer(target: self, action: #selector(GroupHub.TapperTapped(_:)))
        Tapper!.numberOfTapsRequired = 1
        GroupImage.addGestureRecognizer(Tapper!)
        
        let user: PFUser = PFUser.currentUser()!
        let tapProf: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GroupHub.tappedProfile(_:)))
        tapProf.numberOfTapsRequired = 1
        myProfileImage.file = user["thumbnail"] as? PFFile
        myProfileImage.addGestureRecognizer(tapProf)
        myProfileImage.loadInBackground()
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GroupHub.handleSwipes(_:)))
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GroupHub.handleSwipes(_:)))
        downSwipe.direction = .Down
        upSwipe.direction = .Up
        self.myGroupView.addGestureRecognizer(upSwipe)
        self.myGroupView.addGestureRecognizer(downSwipe)
        
        
        let groupQuery = PFQuery(className: "Group")
        groupQuery.getObjectInBackgroundWithId(groupID, block: {
            object, error in
            if error == nil {
                
                myGroup = object!
                self.GroupName.text = object!["Description"] as? String
                self.Group = object!["Users"] as! [String]
                
                for groupUser in self.Group {
                    if groupUser == PFUser.currentUser()!.objectId! {
                        let removeIndex = self.Group.indexOf(groupUser)
                        self.Group.removeAtIndex(removeIndex!)
                    }
                }
                
                self.GroupImage.file = object!["Image"] as? PFFile
                self.GroupImage.loadInBackground {
                    image, error in
                    if error != nil {
                        print(error)
                    }
                }
                if self.Group.count == 0 {
                    self.UserStack.hidden = true
                } else {
                    var headcount: CGFloat = 0
                    while Int(headcount) < self.Group.count {
                        switch(headcount) {
                        case 0:
                            let userQuery = PFUser.query()
                            let userID: String = self.Group[Int(headcount)]
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    //self.UserStack.hidden = false
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserLabel.text = thisUser.username
                                    self.users.updateValue(thisUser, forKey: 0)
                                    self.UserImage.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage.userInteractionEnabled = true
                                    self.UserImage.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.Tapper1 = UITapGestureRecognizer(target: self, action: #selector(GroupHub.TapperTapped(_:)))
                                    self.Tapper1!.numberOfTapsRequired = 1
                                    self.UserImage.addGestureRecognizer(self.Tapper1!)
                                }
                            })
                        case 1:
                            let userQuery = PFUser.query()
                            let userID: String = self.Group[Int(headcount)]
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    self.User2Stack.hidden = false
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserLabel1.text = thisUser.username
                                    self.users.updateValue(thisUser, forKey: 1)
                                    self.UserImage1.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage1.userInteractionEnabled = true
                                    self.UserImage1.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.Tapper2 = UITapGestureRecognizer(target: self, action: #selector(GroupHub.TapperTapped(_:)))
                                    self.Tapper2!.numberOfTapsRequired = 1
                                    self.UserImage1.addGestureRecognizer(self.Tapper2!)
                                }
                            })
                        case 2:
                            let userQuery = PFUser.query()
                            let userID: String = self.Group[Int(headcount)]
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    self.User3Stack.hidden = false
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserLabel2.text = thisUser.username
                                    self.users.updateValue(thisUser, forKey: 2)
                                    self.UserImage2.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage2.userInteractionEnabled = true
                                    self.UserImage2.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.Tapper3 = UITapGestureRecognizer(target: self, action: #selector(GroupHub.TapperTapped(_:)))
                                    self.Tapper3!.numberOfTapsRequired = 1
                                    self.UserImage2.addGestureRecognizer(self.Tapper3!)
                                }
                            })
                        case 3:
                            let userQuery = PFUser.query()
                            let userID: String = self.Group[Int(headcount)]
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    self.User4Stack.hidden = false
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserLabel3.text = thisUser.username
                                    self.users.updateValue(thisUser, forKey: 3)
                                    self.UserImage3.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage3.userInteractionEnabled = true
                                    self.UserImage3.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.Tapper4 = UITapGestureRecognizer(target: self, action: #selector(GroupHub.TapperTapped(_:)))
                                    self.Tapper4!.numberOfTapsRequired = 1
                                    self.UserImage3.addGestureRecognizer(self.Tapper4!)
                                }
                            })
                        default:
                            break
                        }
                        headcount += 1
                        
                    }
                    
                }
            }
        })
        view.layoutIfNeeded()
    }
    
    
    func handleSwipes(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Up {
            UserStack.hidden = false
        } else if sender.direction == .Down {
            UserStack.hidden = true
        }
    }
}


/*if multiSelecSegmendedControl == CommunitySegment {
 switch(index) {
 case 0:
 communitiesFilter = ["Buckhead"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 1:
 communitiesFilter = ["Midtown"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 2:
 communitiesFilter = ["Virginia Highlands"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 3:
 communitiesFilter = ["Emory University"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 4:
 communitiesFilter = ["Edgewood/Downtown"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 5:
 communitiesFilter = ["East Atlanta"]
 if CommunitySegment.selectedSegmentIndexes.containsIndex(Int(index)) {
 CommunitySegment.selectedSegmentIndexes = nil
 } else {
 CommunitySegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 default: break
 }
 
 }  else if multiSelecSegmendedControl == GenderSegment {
 switch(index) {
 case 0:
 if genderFilter.contains("Male") {
 let removeIndex = genderFilter.indexOf("Male")
 genderFilter.removeAtIndex(removeIndex!)
 } else {
 genderFilter.append("Male")
 GenderSegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 1:
 if genderFilter.contains("Female") {
 let removeIndex = genderFilter.indexOf("Female")
 genderFilter.removeAtIndex(removeIndex!)
 } else {
 genderFilter.append("Female")
 GenderSegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 case 2:
 if genderFilter.contains("Mix") {
 let removeIndex = genderFilter.indexOf("Mix")
 genderFilter.removeAtIndex(removeIndex!)
 } else {
 genderFilter = ["Male", "Female", "Mix"]
 GenderSegment.selectedSegmentIndexes = NSIndexSet(index: Int(index))
 }
 default: break
 }
 } */
