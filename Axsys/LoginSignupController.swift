//
//  LoginSignupController.swift
//  SkyeLyncFinal
//
//  Created by Dillon Murphy on 4/17/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4
//import ParseUI

class LoginSignupController : UIViewController, UITextFieldDelegate {
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    @IBOutlet weak var usernameField: KaedeTextField!
    
    @IBOutlet weak var emailField: KaedeTextField!
    @IBOutlet weak var passwordField:   KaedeTextField!
    
    @IBOutlet weak var imageView:       UIImageView!
    
    @IBOutlet weak var FacebookButton: UIButton!
    @IBOutlet weak var SignupButton: DesignableButton!
    @IBOutlet weak var LoginButton: DesignableButton!
    
    @IBOutlet weak var forgotButton: UIButton!
    

    
    override func viewDidLayoutSubviews() {
        usernameField.layer.cornerRadius = 8.0
        passwordField.layer.cornerRadius = 8.0
        FacebookButton.layer.cornerRadius = 8.0
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
    }
    

    override func viewWillAppear(animated: Bool) {
        facebookLogin.logOut()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginSignupController.dismissKeyboard)))
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginSignupController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: self.view.window)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginSignupController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: self.view.window)
        usernameField.delegate = self
        passwordField.delegate = self
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.alpha = 0
        passwordField.alpha = 0
        UIView.animateWithDuration(0.7, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.usernameField.alpha = 1.0
            self.passwordField.alpha = 1.0
            }, completion: nil)
    }

/*
     func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        if passwordField.isFirstResponder() {
            self.view.frame.origin.y += keyboardSize.height
        }
     }
     
    
     func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        if passwordField.isFirstResponder() {
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
     
      */
     
     override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
     }


    
    func Fabo() {
        if PFUser.currentUser() != nil {
            let requestParameters = ["fields": "id, email, first_name, last_name"]
            let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
            userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
                if(error != nil){
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                if(result != nil)  {
                    let myresult = (result as? NSDictionary)!
                    let userId: String = (myresult["id"] as? String)!
                    let userFirstName: String = (myresult["first_name"] as? String)!
                    let userLastName: String = (myresult["last_name"] as? String)!
                    let userEmail: String = (myresult["email"] as? String)!
                    profileUser!["email"] = userEmail
                    profileUser!["PushChannel"] = userId
                    profileUser!["Age"] = "18-20"
                    profileUser!["Sex"] = "Male"
                    profileUser!["Status"] = "Single"
                    profileUser!["Groups"] = []
                    profileUser!["AboutMe"] = "Enter a description of yourself"
                    let fullName = "\(userFirstName) \(userLastName)"
                    if fullName.characters.count > 0 {
                        profileUser!.username = userEmail
                        profileUser!["fullname"] = fullName
                        profileUser!["fullname_lower"] = fullName.lowercaseString
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                        let profilePictureUrl = NSURL(string: userProfile)
                        let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                        if(profilePictureData != nil) {
                            var image = UIImage(data: profilePictureData!)
                            if image!.size.width > 280 {
                                image = Images.resizeImage(image!, width: 280, height: 280)!
                            }
                            let pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image!, 0.6)!)
                            pictureFile!.saveInBackgroundWithBlock {
                                succeeded, error in
                                if error != nil {
                                    ProgressHUD.showError(error?.localizedDescription)
                                }
                            }
                            if image!.size.width > 60 {
                                image = Images.resizeImage(image!, width: 60, height: 60)!
                            }
                            let thumbnailFile = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image!, 0.6)!)
                            thumbnailFile!.saveInBackgroundWithBlock {
                                succeeded, error in
                                if error != nil {
                                    ProgressHUD.showError(error?.localizedDescription)
                                }
                            }
                            profileUser!["profPic"] = pictureFile
                            profileUser!["thumbnail"] = thumbnailFile
                            profileUser!.saveInBackgroundWithBlock({
                                succeeded, error in
                                if error != nil {
                                    ProgressHUD.showError(error?.localizedDescription)
                                }
                            })
                        }
                    }
                    profileUser!.saveInBackgroundWithBlock({
                        succeeded, error in
                        if error != nil {
                            ProgressHUD.showError(error?.localizedDescription)
                        }
                    })
                }
            }
            
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
                        }
                    })
                }
            }
        }
        self.performSegueWithIdentifier("toProfile", sender: nil)
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
                    friend.saveInBackground()
                }
            } else {
                let friend = PFObject(className: "Friend")
                friend.setObject(PFUser.currentUser()!, forKey: "friendOf")
                friend.setObject(otherUser.username!, forKey: "friendName")
                friend.setObject(otherUser, forKey: "friend")
                friend.saveInBackground()
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
    
    @IBAction func fabLog(sender: UIButton) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "email", "user_friends"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    profileUser = user
                    self.Fabo()
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginSignupVC") as! UINavigationController
                    self.presentViewController(initialViewController, animated: true, completion: nil)
                }
            } else {
                self.FacebookButton.shake(.Horizontal, numberOfTimes: 3, totalDuration: 0.5, completion: {})
                ProgressHUD.showError("Facebook Login Failed")
            }
        }
    }
       
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func forgot(sender: UIButton) {
        let alerter = UIAlertController(title: "Enter Email", message: nil, preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in}
        alerter.addAction(cancelAction)
        let nextAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            let text: String = (alerter.textFields?.first?.text)!
            PFUser.requestPasswordResetForEmailInBackground(text)
            let alerter2 = UIAlertController(title: "Request Sent", message: nil, preferredStyle: .Alert)
            let cancelAction2: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel) { action -> Void in}
            alerter2.addAction(cancelAction2)
            self.presentViewController(alerter2, animated: true, completion: nil)
        }
        alerter.addAction(nextAction)
        alerter.addTextFieldWithConfigurationHandler { (textField) -> Void in}
        presentViewController(alerter, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            if passwordField.text == "" {
                passwordField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if textField == passwordField {
            if passwordField.text == "" {
                passwordField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        } else if textField == emailField {
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buttonPressed(sender: DesignableButton) {
        self.startActivityIndicator()
        PFUser.logInWithUsernameInBackground(self.usernameField.text!, password:self.passwordField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if error == nil {
                user!.username = self.usernameField.text!
                self.stopActivityIndicator()
                let fullName = self.usernameField.text!
                if fullName.characters.count > 0 {
                    user![PF_USER_FULLNAME] = fullName
                    user![PF_USER_FULLNAME_LOWER] = fullName.lowercaseString
                }
                user!.saveInBackgroundWithBlock({
                    succeeded, error in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                })
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginSignupVC") as! UINavigationController
                self.presentViewController(initialViewController, animated: true, completion: nil)
            } else {
                self.stopActivityIndicator()
                self.usernameField.shake(.Horizontal, numberOfTimes: 3, totalDuration: 0.5, completion: {})
                self.passwordField.shake(.Horizontal, numberOfTimes: 3, totalDuration: 0.5, completion: {})
                ProgressHUD.showError("Incorrect Email/Password")
            }
        }
    }
    
    @IBAction func signupPressed(sender: DesignableButton) {
        self.startActivityIndicator()
        let user = PFUser()
        user.username = self.usernameField.text
        user.password = self.passwordField.text
        user.email = self.usernameField.text
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString: String = (error.userInfo["error"] as? String)!
                self.stopActivityIndicator()
                self.usernameField.shake(.Horizontal, numberOfTimes: 3, totalDuration: 0.5, completion: {})
                self.passwordField.shake(.Horizontal, numberOfTimes: 3, totalDuration: 0.5, completion: {})
                ProgressHUD.showError(errorString)
            } else {
                user["Age"] = "18-20"
                user["Sex"] = "Male"
                user["Groups"] = []
                user["Status"] = "Single"
                user["AboutMe"] = "Enter a description of yourself"
                user["PushChannel"] = user.objectId!
                let fullName = self.usernameField.text
                if fullName!.characters.count > 0 {
                    user[PF_USER_FULLNAME] = fullName
                    user[PF_USER_FULLNAME_LOWER] = fullName!.lowercaseString
                }
                user.saveInBackgroundWithBlock({
                    succeeded, error in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                    }
                })
                self.stopActivityIndicator()
                profileUser = user
                self.performSegueWithIdentifier("toProfile", sender: nil)
            }
        }
    }
}


