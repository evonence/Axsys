//
//  GroupPage.swift
//  SkyeLync
//
//  Created by Dillon Murphy on 3/31/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import ParseUI


class GroupPage: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, MultiSelectSegmentedControlDelegate {
    
    
    @IBOutlet weak var myGroupImage: PFImageView!
    
     
    
    var GroupUsers: [String] = [String]()
    
    
    //var GroupLocation: UILabel = UILabel()
    
    
    
    @IBOutlet weak var UserStack1: UIStackView!
    @IBOutlet weak var UserImage1: PFImageView!
    @IBOutlet weak var UserLabel1: UILabel!
    
    @IBOutlet weak var UserStack2: UIStackView!
    @IBOutlet weak var UserImage2: PFImageView!
    @IBOutlet weak var UserLabel2: UILabel!

    @IBOutlet weak var UserStack3: UIStackView!
    @IBOutlet weak var UserImage3: PFImageView!
    @IBOutlet weak var UserLabel3: UILabel!
    
    @IBOutlet weak var UserStack4: UIStackView!
    @IBOutlet weak var UserImage4: PFImageView!
    @IBOutlet weak var UserLabel4: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var GroupDescription: UITextView!
    
    @IBOutlet weak var saveButton:     UIButton!
    
    
    
    @IBOutlet weak var pickerTextField: UITextField!
    
    var pickOption = ["Bars", "Ballgame", "Concert", "Hang Out", "Park", "Something Different"]

    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var ageSegment: MultiSelectSegmentedControl!
    @IBOutlet weak var StatusSegment: UISegmentedControl!
    
    
    var users: [Int: PFUser] = [Int: PFUser]()
    
    
    var Tapped1: UITapGestureRecognizer?
    var Tapped2: UITapGestureRecognizer?
    var Tapped3: UITapGestureRecognizer?
    var Tapped4: UITapGestureRecognizer?
    
    
    var senduser = 0
    
    override func viewWillLayoutSubviews() {
        GroupDescription.layer.borderWidth = 1.0
        GroupDescription.layer.borderColor = myGroupImage.backgroundColor?.CGColor
        
        nameField.layer.cornerRadius = 8.0
        nameField.layer.borderWidth = 1.0
        nameField.layer.borderColor = myGroupImage.backgroundColor?.CGColor
        
        ageSegment.layer.cornerRadius = 8.0
        genderSegment.layer.cornerRadius = 8.0
        
        saveButton.layer.cornerRadius = 8.0
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
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
    
    func multiSelect(multiSelecSegmendedControl: MultiSelectSegmentedControl!, didChangeValue value: Bool, atIndex index: UInt) {
        if multiSelecSegmendedControl == ageSegment {
            switch(index) {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                break
            default: break
            }
        }
    }
    
    func doneTapped2() {
        GroupDescription.resignFirstResponder()
    }



    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is ProfileViewController{
            profileUser = self.users[senduser]
        }
    }
    
    
    func StartGroup(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginSignupVC") as! UINavigationController
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    func TappedUser(sender: UITapGestureRecognizer) {
        if sender == Tapped1 {
            senduser = 0
            self.performSegueWithIdentifier("usersProfile", sender: nil)
        } else if sender == Tapped2 {
            senduser = 1
            self.performSegueWithIdentifier("usersProfile", sender: nil)
        } else if sender == Tapped3 {
            senduser = 2
            self.performSegueWithIdentifier("usersProfile", sender: nil)
        } else if sender == Tapped4 {
            senduser = 3
            self.performSegueWithIdentifier("usersProfile", sender: nil)
        }
    }
    
        
    override func viewWillAppear(animated: Bool) {
        
        let newButton2: UIBarButtonItem = UIBarButtonItem(title: "Go Live", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupPage.StartGroup(_:)))
        newButton2.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(newButton2, animated: false)
        
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupPage.ExitGroup(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GroupPage.dismissKeyboard)))
        
        let tapper: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GroupPage.tappedPic(_:)))
        tapper.numberOfTapsRequired = 1
        myGroupImage.addGestureRecognizer(tapper)
        
        if groupProfile != nil {
            let groupQuery = PFQuery(className: "Group")
            groupQuery.getObjectInBackgroundWithId((groupProfile?.objectId!)!, block: {
                object, error in
                if error == nil {
                    self.nameField.text = object!["GroupName"] as? String
                    self.GroupDescription.text = object!["Description"] as! String
                    //self.GroupLocation.text = object!["GroupName"] as? String
                    self.pickerTextField.text = object!["EventType"] as? String
                    self.GroupUsers = object!["Users"] as! [String]
                    self.myGroupImage.file = object!["Image"] as? PFFile
                    
                    for groupUser in self.GroupUsers {
                        if groupUser == PFUser.currentUser()!.objectId! {
                            let removeIndex = self.GroupUsers.indexOf(groupUser)
                            self.GroupUsers.removeAtIndex(removeIndex!)
                        }
                    }
                    
                    switch(object!["Sexs"] as! String) {
                    case "Male": self.genderSegment.selectedSegmentIndex = 0
                    case "Female": self.genderSegment.selectedSegmentIndex = 1
                    case "Mix": self.genderSegment.selectedSegmentIndex = 2
                    default: break
                    }
                    
                    switch(object!["Status"] as! String) {
                    case "Single": self.StatusSegment.selectedSegmentIndex = 0
                    case "Couple": self.StatusSegment.selectedSegmentIndex = 1
                    case "Mix": self.StatusSegment.selectedSegmentIndex = 2
                    default: break
                    }
                    
                    var Indexes: [Int] = [Int]()
                    for string in (object!["Ages"] as? [String])! {
                        switch(string) {
                        case "18-20": Indexes.append(0)
                        case "21-24": Indexes.append(1)
                        case "25-29": Indexes.append(2)
                        case "30+": Indexes.append(3)
                        default: break
                        }
                    }
                    //self.ageSegment.selected
                    
                    self.myGroupImage.loadInBackground {
                        image, error in
                        if error != nil {
                            print(error)
                        }
                    }
                    var headcount: CGFloat = 0
                    while Int(headcount) < self.GroupUsers.count {
                        let userQuery = PFUser.query()
                        let userID: String = self.GroupUsers[Int(headcount)]
                        switch(headcount) {
                        case 0:
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage1.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage1.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel1.text = thisUser.username!
                                    self.Tapped1 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped1!.numberOfTapsRequired = 1
                                    self.UserImage1.addGestureRecognizer(self.Tapped1!)
                                }
                            })
                        case 1:
                            self.UserStack2.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage2.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage2.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel2.text = thisUser.username!
                                    self.Tapped2 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped2!.numberOfTapsRequired = 1
                                    self.UserImage2.addGestureRecognizer(self.Tapped2!)
                                }
                            })
                        case 2:
                            self.UserStack3.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage3.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage3.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel3.text = thisUser.username!
                                    self.Tapped3 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped3!.numberOfTapsRequired = 1
                                    self.UserImage3.addGestureRecognizer(self.Tapped3!)
                                }
                            })
                        case 3:
                            self.UserStack4.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage4.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage4.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel4.text = thisUser.username!
                                    self.Tapped4 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped4!.numberOfTapsRequired = 1
                                    self.UserImage4.addGestureRecognizer(self.Tapped4!)
                                }
                            })
                        default:
                            break
                        }
                        
                        headcount += 1
                    }
                }
            })
        } else{
            let groupQuery = PFQuery(className: "Group")
            groupQuery.getObjectInBackgroundWithId((myGroup?.objectId!)!, block: {
                object, error in
                if error == nil {
                    self.nameField.text = object!["GroupName"] as? String
                    self.GroupDescription.text = object!["Description"] as! String
                    //self.GroupLocation.text = object!["GroupName"] as? String
                    self.pickerTextField.text = object!["EventType"] as? String
                    self.GroupUsers = object!["Users"] as! [String]
                    self.myGroupImage.file = object!["Image"] as? PFFile
                    
                    for groupUser in self.GroupUsers {
                        if groupUser == PFUser.currentUser()!.objectId! {
                            let removeIndex = self.GroupUsers.indexOf(groupUser)
                            self.GroupUsers.removeAtIndex(removeIndex!)
                        }
                    }
                    
                    switch(object!["Sexs"] as! String) {
                    case "Male": self.genderSegment.selectedSegmentIndex = 0
                    case "Female": self.genderSegment.selectedSegmentIndex = 1
                    case "Mix": self.genderSegment.selectedSegmentIndex = 2
                    default: break
                    }
                    
                    switch(object!["Status"] as! String) {
                    case "Single": self.StatusSegment.selectedSegmentIndex = 0
                    case "Couple": self.StatusSegment.selectedSegmentIndex = 1
                    case "Mix": self.StatusSegment.selectedSegmentIndex = 2
                    default: break
                    }
                    
                    var Indexes: [Int] = [Int]()
                    for string in (object!["Ages"] as? [String])! {
                        switch(string) {
                        case "18-20": Indexes.append(0)
                        case "21-24": Indexes.append(1)
                        case "25-29": Indexes.append(2)
                        case "30+": Indexes.append(3)
                        default: break
                        }
                    }
                    //self.ageSegment.selected
                    
                    self.myGroupImage.loadInBackground {
                        image, error in
                        if error != nil {
                            print(error)
                        }
                    }
                    var headcount: CGFloat = 0
                    while Int(headcount) < self.GroupUsers.count {
                        let userQuery = PFUser.query()
                        let userID: String = self.GroupUsers[Int(headcount)]
                        switch(headcount) {
                        case 0:
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage1.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage1.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel1.text = thisUser.username!
                                    self.Tapped1 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped1!.numberOfTapsRequired = 1
                                    self.UserImage1.addGestureRecognizer(self.Tapped1!)
                                }
                            })
                        case 1:
                            self.UserStack2.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage2.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage2.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel2.text = thisUser.username!
                                    self.Tapped2 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped2!.numberOfTapsRequired = 1
                                    self.UserImage2.addGestureRecognizer(self.Tapped2!)
                                }
                            })
                        case 2:
                            self.UserStack3.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage3.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage3.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel3.text = thisUser.username!
                                    self.Tapped3 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped3!.numberOfTapsRequired = 1
                                    self.UserImage3.addGestureRecognizer(self.Tapped3!)
                                }
                            })
                        case 3:
                            self.UserStack4.hidden = false
                            userQuery?.getObjectInBackgroundWithId(userID, block: {
                                object, error in
                                if error == nil {
                                    let thisUser: PFUser = (object as? PFUser)!
                                    self.UserImage4.file = thisUser["thumbnail"] as? PFFile
                                    self.UserImage4.loadInBackground {
                                        image, error in
                                        if error != nil {
                                            print(error)
                                        }
                                    }
                                    self.UserLabel4.text = thisUser.username!
                                    self.Tapped4 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
                                    self.Tapped4!.numberOfTapsRequired = 1
                                    self.UserImage4.addGestureRecognizer(self.Tapped4!)
                                }
                            })
                        default:
                            break
                        }
                        
                        headcount += 1
                    }
                }
            })
        }
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = .whiteColor()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerTextField.addDoneButton()
        pickerTextField.inputView = pickerView
        
    }
    
    func ExitGroup(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginSignupVC") as! UINavigationController
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func SaveGroup(sender: UIButton) {
        let groupQuery = PFQuery(className: "Group")
        groupQuery.getObjectInBackgroundWithId((myGroup?.objectId!)!, block: {
            group, error in
            if error == nil {
                group!["Description"] = self.GroupDescription.text
                group!["GroupName"] = self.nameField.text
                var Strings: [String] = [String]()
                for _ in self.ageSegment.selectedSegmentIndexes {
                    switch(self.ageSegment.selectedSegmentIndexes) {
                    case 0: Strings.append("18-20")
                    case 1: Strings.append("21-24")
                    case 2: Strings.append("25-29")
                    case 3: Strings.append("30+")
                    default: break
                    }
                }
                group!["EventType"] = self.pickerTextField.text
                group!["Ages"] = Strings
                switch(self.genderSegment.selectedSegmentIndex) {
                    case 0: group!["Sexs"] = "Male"
                    case 1: group!["Sexs"] = "Female"
                    case 2: group!["Sexs"] = "Mix"
                    default: break
                }
                
                switch(self.StatusSegment.selectedSegmentIndex) {
                case 0: group!["Status"] = "Single"
                case 1: group!["Status"] = "Couple"
                case 2: group!["Status"] = "Mix"
                default: break
                }
                group!["Image"] = self.myGroupImage.file
                group!.saveInBackgroundWithBlock({
                    success, error in
                    if error == nil {
                        myGroup = group
                        if success == true {
                            PFUser.currentUser()!["CurrentGroup"] = group
                            PFUser.currentUser()!.saveInBackground()
                            ProgressHUD.showSuccess("Saved Changes")
                        }
                    }
                })
            }
        })
        

    }
    
    func tappedPic(sender: UITapGestureRecognizer) {
        Camera.shouldStartPhotoLibrary(self, canEdit: true)
    }
    
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        if image.size.width > 280 {
            image = Images.resizeImage(image, width: 280, height: 280)!
        }
        self.myGroupImage.image = image
        
        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        pictureFile!.saveInBackgroundWithBlock {
            succeeded, error in
            if error != nil {
                ProgressHUD.showError("Network error: \(error)")
            } else {
                ProgressHUD.showSuccess("SaveFile")
            }
        }
        
        self.myGroupImage.file = pictureFile
        self.myGroupImage.loadInBackground {
            image, error in
            if error != nil {
                print(error)
            }
        }
        
        myGroup!["Image"] = pictureFile
        myGroup!.saveEventually()
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
}

/*
 func loadOldUsers() {
 let groupQuery = PFQuery(className: "Group")
 groupQuery.getObjectInBackgroundWithId((myGroup?.objectId!)!, block: {
 object, error in
 if error == nil {
 self.nameField.text = object!["GroupName"] as? String
 self.GroupDescription.text = object!["Description"] as! String
 //self.GroupLocation.text = object!["GroupName"] as? String
 self.pickerTextField.text = ""
 self.GroupUsers = object!["Users"] as! [String]
 self.myGroupImage.file = object!["Image"] as? PFFile
 self.myGroupImage.loadInBackground {
 image, error in
 if error != nil {
 print(error)
 }
 }
 var headcount: CGFloat = 0
 while Int(headcount) < self.GroupUsers.count {
 let userQuery = PFUser.query()
 let userID: String = self.GroupUsers[Int(headcount)]
 switch(headcount) {
 case 0:
 userQuery?.getObjectInBackgroundWithId(userID, block: {
 object, error in
 if error == nil {
 let thisUser: PFUser = (object as? PFUser)!
 self.UserImage1.file = thisUser["thumbnail"] as? PFFile
 self.UserImage1.loadInBackground {
 image, error in
 if error != nil {
 print(error)
 }
 }
 self.Tapped1 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
 self.Tapped1!.numberOfTapsRequired = 1
 self.UserImage1.addGestureRecognizer(self.Tapped1!)
 }
 })
 case 1:
 self.UserStack2.hidden = false
 userQuery?.getObjectInBackgroundWithId(userID, block: {
 object, error in
 if error == nil {
 let thisUser: PFUser = (object as? PFUser)!
 self.UserImage2.file = thisUser["thumbnail"] as? PFFile
 self.UserImage2.loadInBackground {
 image, error in
 if error != nil {
 print(error)
 }
 }
 self.Tapped2 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
 self.Tapped2!.numberOfTapsRequired = 1
 self.UserImage2.addGestureRecognizer(self.Tapped2!)
 }
 })
 case 2:
 self.UserStack3.hidden = false
 userQuery?.getObjectInBackgroundWithId(userID, block: {
 object, error in
 if error == nil {
 let thisUser: PFUser = (object as? PFUser)!
 self.UserImage3.file = thisUser["thumbnail"] as? PFFile
 self.UserImage3.loadInBackground {
 image, error in
 if error != nil {
 print(error)
 }
 }
 self.Tapped3 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
 self.Tapped3!.numberOfTapsRequired = 1
 self.UserImage3.addGestureRecognizer(self.Tapped3!)
 }
 })
 case 3:
 self.UserStack4.hidden = false
 userQuery?.getObjectInBackgroundWithId(userID, block: {
 object, error in
 if error == nil {
 let thisUser: PFUser = (object as? PFUser)!
 self.UserImage4.file = thisUser["thumbnail"] as? PFFile
 self.UserImage4.loadInBackground {
 image, error in
 if error != nil {
 print(error)
 }
 }
 self.Tapped4 = UITapGestureRecognizer(target: self, action: #selector(GroupPage.TappedUser(_:)))
 self.Tapped4!.numberOfTapsRequired = 1
 self.UserImage4.addGestureRecognizer(self.Tapped4!)
 }
 })
 default:
 break
 }
 
 headcount += 1
 }
 }
 })
 }*/


/*
 func saveUser() {
 let fullName = nameField.text
 if fullName!.characters.count > 0 {
 var user = PFUser.currentUser()
 user!.username = fullName
 //let dateStr = user!["Birthday"] as? NSDAte
 let dater = NSDateFormatter()
 dater.dateFormat = "MM-dd-yyyy"
 let Birthday = dater.dateFromString(dateField.text!)
 user!["Birthday"] = Birthday
 user![PF_USER_FULLNAME_LOWER] = fullName!.lowercaseString
 user!.saveInBackgroundWithBlock({
 succeeded, error in
 if error == nil {
 //ProgressHUD.showSuccess("Saved")
 } else {
 //ProgressHUD.showError("Network error")
 }
 })
 } else {
 //ProgressHUD.showError("Name field must not be empty")
 }
 }
 */

/*
 
 func keyboardWillHide(sender: NSNotification) {
 let userInfo: [NSObject : AnyObject] = sender.userInfo!
 let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
 self.view.frame.origin.y += keyboardSize.height
 }
 
 func keyboardWillShow(sender: NSNotification) {
 let userInfo: [NSObject : AnyObject] = sender.userInfo!
 let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
 let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
 if nameField.isFirstResponder() {} else {
 if keyboardSize.height == offset.height {
 UIView.animateWithDuration(0.1, animations: { () -> Void in
 self.view.frame.origin.y -= keyboardSize.height
 })
 } else {
 UIView.animateWithDuration(0.1, animations: { () -> Void in
 self.view.frame.origin.y += keyboardSize.height - offset.height
 })
 }
 }
 }
 
 
 override func viewWillDisappear(animated: Bool) {
 NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
 NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
 groupProfile = nil
 }
 
 NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GroupPage.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
 NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GroupPage.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
 
 */

