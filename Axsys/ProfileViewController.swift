//
//  ProfileViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import ParseUI

class ProfileViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var userImageView: PFImageView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet weak var malefemale: UISegmentedControl!
    @IBOutlet weak var StatusSegment: UISegmentedControl!
    @IBOutlet weak var AgeSegment: UISegmentedControl!
    @IBOutlet weak var savebutton: UIButton!
    @IBOutlet weak var locbutton: UIButton!
    @IBOutlet weak var myDescription: UITextView!
   
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProfileViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        self.navigationController?.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.photoButtonPressed))
        userImageView.addGestureRecognizer(Tap)
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(ProfileViewController.backToMain))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
    }
    
    func backToMain() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func photoButtonPressed() {
        let alertVC = UIAlertController(title: "Change Profile Picture", message: "How would you like to add your Profile Picture?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Button1 = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
        }
        let Button2 = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Button1)
        alertVC.addAction(Button2)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        //locbutton.layer.cornerRadius = 8.0
        savebutton.layer.cornerRadius = 8.0
    }
    
    func tappedRight(sender: UIBarButtonItem) {
        startChat(profileUser!)
    }
    
    @IBAction func LocSettingsTapped(sender: UIButton) {
        let alertVC = UIAlertController(title: "Enable Location sharing", message: "Enable shared location data to help improve the user experience for all", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let Facebook = UIAlertAction(title: "Enable Sharing", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            disabled = false
        }
        let Search = UIAlertAction(title: "Disable Sharing", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            disabled = true
        }
        let Cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in}
        alertVC.addAction(Facebook)
        alertVC.addAction(Search)
        alertVC.addAction(Cancel)
        self.presentViewController(alertVC, animated: true, completion: nil)
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUser(profileUser!)
        if profileUser != PFUser.currentUser() {
            self.view.userInteractionEnabled = false
            self.locbutton.hidden = true
            self.savebutton.hidden = true
            let messageResize: UIImage = Images.resizeImage(UIImage(named: "Messagebubble")!, width: 45, height: 45)!
            let rightbutton: UIBarButtonItem = UIBarButtonItem(image: messageResize, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ProfileViewController.tappedRight(_:)))
            rightbutton.tintColor = UIColor.whiteColor()
            self.navigationItem.setRightBarButtonItem(rightbutton, animated: false)
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.dismissKeyboard)))
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
     
     
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if nameField.isFirstResponder() {} else {
            self.view.frame.origin.y += keyboardSize.height
        }
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    func loadUser(user : PFUser) {
        let userQuery = PFUser.query()
        userQuery?.getObjectInBackgroundWithId(user.objectId!, block: {
            user, error in
            if error == nil {
                let user = user as! PFUser
                self.userImageView.file = user[PF_USER_PICTURE] as? PFFile
                self.userImageView.loadInBackground()
                self.myDescription.text = user["AboutMe"] as? String
                self.nameField.text = user["fullname"] as? String
                
                if user["Age"] != nil {
                    switch(user["Age"] as! String) {
                    case "18-20": self.AgeSegment.selectedSegmentIndex = 0
                    case "21-24": self.AgeSegment.selectedSegmentIndex = 1
                    case "25-29": self.AgeSegment.selectedSegmentIndex = 2
                    case "30+": self.AgeSegment.selectedSegmentIndex = 3
                    default: break
                    }
                }
                
                if user["Sex"] != nil {
                    switch(user["Sex"] as! String) {
                    case "Male": self.malefemale.selectedSegmentIndex = 0
                    case "Female": self.malefemale.selectedSegmentIndex = 1
                    case "Intersex": self.malefemale.selectedSegmentIndex = 2
                    default: break
                    }
                }
                
                if user["Status"] != nil {
                    switch(user["Status"] as! String) {
                    case "Single": self.StatusSegment.selectedSegmentIndex = 0
                    case "Couple": self.StatusSegment.selectedSegmentIndex = 1
                    default: break
                    }
                }
            }
        })
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        profileUser = nil
    }
    
    func saveUser() {
        let fullName = nameField.text
        if fullName!.characters.count > 0 {
            let user = PFUser.currentUser()
            user!.username = fullName
            
            
            switch(AgeSegment.selectedSegmentIndex) {
            case 0: user!["Age"] = "18-20"
            case 1: user!["Age"] = "21-24"
            case 2: user!["Age"] = "25-29"
            case 3: user!["Age"] = "30+"
            default: break
            }
            
            switch(malefemale.selectedSegmentIndex) {
            case 0: user!["Sex"] = "Male"
            case 1: user!["Sex"] = "Female"
            case 2: user!["Sex"] = "Intersex"
            default: break
            }
            
            user!["AboutMe"] = myDescription.text
            
            switch(StatusSegment.selectedSegmentIndex) {
            case 0: user!["Status"] = "Single"
            case 1: user!["Status"] = "Couple"
            default: break
            }
            
            user![PF_USER_FULLNAME_LOWER] = fullName!.lowercaseString
            user!.saveInBackgroundWithBlock({
                succeeded, error in
                if error == nil {
                    ProgressHUD.showSuccess("Saved")
                } else {
                    ProgressHUD.showError("Failed to Save")
                }
            })
        } else {
            ProgressHUD.showError("Name field must not be empty")
        }
    }
    
    // MARK: - User actions
    
    func cleanup() {
        userImageView.image = UIImage(named: "profile")
        nameField.text = nil;
    }
    
    func logout() {
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVCNav") as! UINavigationController
        self.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        self.logout()
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        self.dismissKeyboard()
        self.saveUser()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        if image.size.width > 280 {
            image = Images.resizeImage(image, width: 280, height: 280)!
        }
        
        let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        pictureFile!.saveInBackground()
        userImageView.image = image
        
        if image.size.width > 60 {
            image = Images.resizeImage(image, width: 60, height: 60)!
        }
        
        let thumbnailFile = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image, 0.6)!)
        thumbnailFile!.saveInBackground()
        let user = PFUser.currentUser()
        user![PF_USER_PICTURE] = pictureFile
        user![PF_USER_THUMBNAIL] = thumbnailFile
        user!.saveInBackground()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {
        /*
        Empty. Exists solely so that "unwind to Login" segues can find
        instances of this class.
        */
    }

    
}
