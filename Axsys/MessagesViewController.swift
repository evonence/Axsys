//
//  MessagesViewController.swift
//  FireChat-Swift
//
//  Created by Katherine Fang on 8/13/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVKit
import AVFoundation
import Parse
import ParseUI
import PeekPop

class MessagesViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, PeekPopPreviewingDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    
    
    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    var activityIndicatorView: NVActivityIndicatorView!
    let transition = BubbleTransition()
    var initials = ""
    let font = UIFont.systemFontOfSize(20)
    var users = [PFUser]()
    var messages = [JSQMessage]()
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var blankAvatarImage: JSQMessagesAvatarImage!
    var Players: [SCVideoPlayerView] = [SCVideoPlayerView]()
    var PlayerControl: SCVideoPlayerView = SCVideoPlayerView()
    var senderImageUrl: String!
    var batchMessages = true
    var mediaView: CGRect!
    var imagePass: UIImage!
    
    var peekPop: PeekPop?
    
    var popVideo : SCVideoPlayerView!
    
    
    var touchlocation: CGPoint!
    
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
    
    
    func loadMessages() {
        if self.isLoading == false {
            self.isLoading = true
            let lastMessage = messages.last
            let query = PFQuery(className: PF_CHAT_CLASS_NAME)
            query.whereKey(PF_CHAT_GROUPID, equalTo: groupPass!)
            if lastMessage != nil {
                query.whereKey(PF_CHAT_CREATEDAT, greaterThan: (lastMessage?.date)!)
            }
            query.includeKey(PF_CHAT_USER)
            query.orderByDescending(PF_CHAT_CREATEDAT)
            query.limit = 50
            query.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) in
                if error == nil {
                    for object in Array((objects as [PFObject]!).reverse()) {
                        self.addMessage(object)
                    }
                    if objects!.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    if objects!.count >= 49 {
                        self.showLoadEarlierMessagesHeader = true
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                    self.isLoading = false
                    self.collectionView?.reloadData()
                    self.collectionView?.layoutIfNeeded()
                }
            })
        }
    }
    
    
    
    func previewingContext(previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if isLoading == false {
            if let indexPath = self.collectionView!.indexPathForItemAtPoint(location) {
                touchlocation = location
                if let layoutAttributes = self.collectionView!.layoutAttributesForItemAtIndexPath(indexPath) {
                    previewingContext.sourceRect = layoutAttributes.frame
                }
                let message = self.messages[indexPath.item]
                if message.isMediaMessage {
                    if let mediaItem = message.media as? JSQVideoMediaItem {
                        let asset = AVAsset(URL: mediaItem.fileURL)
                        let item = AVPlayerItem(asset: asset)
                        let player: SCPlayer = SCPlayer()
                        player.loopEnabled = true
                        player.setItem(item)
                        let storyboard = UIStoryboard(name:"Main", bundle:nil)
                        if let previewViewController = storyboard.instantiateViewControllerWithIdentifier("VidNav") as? RecorderView {
                            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewCell
                            var added = false
                            for sub in (cell.mediaView!.subviews) {
                                if sub is SCVideoPlayerView {
                                    let thisSub = sub as! SCVideoPlayerView
                                    previewViewController.PlayerControl = thisSub
                                    popVideo = SCVideoPlayerView(player: thisSub.player!)
                                    popVideo.frame = (cell.mediaView!.frame)
                                    popVideo.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                                    popVideo.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                                    popVideo.tapToPauseEnabled = true
                                    popVideo.userInteractionEnabled = true
                                    popVideo.layer.cornerRadius = 21.0
                                    cell.mediaView!.addSubview(popVideo)
                                    added = true
                                }
                            }
                            if added == false {
                                previewViewController.PlayerControl = SCVideoPlayerView(player: player)
                            }
                            let screenWidth = UIScreen.mainScreen().bounds.width
                            if screenWidth <= 320 {
                                previewViewController.PlayerControl = SCVideoPlayerView(player: player)
                            }
                            
                            return previewViewController
                        }
                    }
                    if let mediaItem2 = message.media as? JSQPhotoMediaItem {
                        let storyboard = UIStoryboard(name:"Main", bundle:nil)
                        if let previewViewController = storyboard.instantiateViewControllerWithIdentifier("ImageNav") as? ImageViewer {
                            previewViewController.ImageViewer2 = UIImageView(image: mediaItem2.image)
                            return previewViewController
                        }
                    }
                }
                
                
                
            }
        }
        return nil
    }
    
    
    
    
    func previewingContext(previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
    
    func addMessage(object: PFObject) {
        var message: JSQMessage!
        let user = object[PF_CHAT_USER] as! PFUser
        let name = user.username
        let videoFile = object[PF_CHAT_VIDEO] as? PFFile
        let pictureFile = object[PF_CHAT_PICTURE] as? PFFile
        if videoFile == nil && pictureFile == nil {
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, text: (object[PF_CHAT_TEXT] as? String))
        }
        if videoFile != nil {
            let mediaItem = JSQVideoMediaItem(fileURL: NSURL(string: videoFile!.url!), isReadyToPlay: true)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
        }
        if pictureFile != nil {
            let mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (user.objectId == self.senderId)
            message = JSQMessage(senderId: user.objectId, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            pictureFile!.getDataInBackgroundWithBlock({
                imageData, error in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData!)
                    self.collectionView!.reloadData()
                    self.collectionView?.layoutIfNeeded()
                }
            })
        }
        users.append(user)
        messages.append(message)
    }
    
    
    func sendMessage(text: String, video: NSURL?, picture: UIImage?) {
        var texter = text
        var videoFile: PFFile!
        var pictureFile: PFFile!
        if let video = video {
            texter = "[Video message]"
            videoFile = PFFile(name: "video.mp4", data: NSFileManager.defaultManager().contentsAtPath(video.path!)!)
            videoFile.saveInBackgroundWithBlock({
                succeded, error in
                if error != nil {
                    ProgressHUD.showError("Network error")
                }
            })
        }
        if let picture = picture {
            texter = "[Picture message]"
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            pictureFile.saveInBackgroundWithBlock({
                succeded, error in
                if error != nil {
                    ProgressHUD.showError("Picture save error")
                }
            })
        }
        let object = PFObject(className: PF_CHAT_CLASS_NAME)
        object[PF_CHAT_USER] = PFUser.currentUser()
        object[PF_CHAT_GROUPID] = groupPass
        object[PF_CHAT_TEXT] = texter
        if let videoFile = videoFile {
            object[PF_CHAT_VIDEO] = videoFile
        }
        if let pictureFile = pictureFile {
            object[PF_CHAT_PICTURE] = pictureFile
        }
        object.saveInBackgroundWithBlock {
            succeded, error in
            if error == nil {
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.loadMessages()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
        self.sendChatPush(texter)
        
        Messages.updateMessageCounter(groupPass!, lastMessage: texter)
        self.finishSendingMessage()
    }
    
    func sendChatPush(message: String) {
        let userChan: String = (PFUser.currentUser()?.objectId!)!
        let query = PFQuery(className: "ChatGroup")
        query.getObjectInBackgroundWithId(groupPass!, block: {
            object, error in
            if error == nil  {
                if object != nil  {
                    let array: [PFUser] = (object!["Users"] as? [PFUser])!
                    for user in array {
                        let userQuery = PFUser.query()
                        userQuery?.getObjectInBackgroundWithId(user.objectId!, block: {
                            user, error in
                            if error == nil {
                                if user != PFUser.currentUser() {
                                    let installationQuery = PFInstallation.query()
                                    installationQuery!.whereKey("User", equalTo: user!)
                                    let push = PFPush()
                                    var data: [NSObject: AnyObject]!
                                    if message == "[Video message]" {
                                        data = [
                                            "alert" : "Video Message",
                                            "ObjID" : userChan,
                                            "messageID" : groupPass!,
                                            "badge" : "Increment",
                                            "type" : "chat"
                                        ]
                                    } else if message == "[Picture message]" {
                                        data = [
                                            "alert" : "Picture Message",
                                            "ObjID" : userChan,
                                            "messageID" : groupPass!,
                                            "badge" : "Increment",
                                            "type" : "chat"
                                        ]
                                    } else {
                                        data = [
                                            "alert" : message,
                                            "ObjID" : userChan,
                                            "messageID" : groupPass!,
                                            "badge" : "Increment",
                                            "type" : "chat"
                                        ]
                                    }
                                    push.setQuery(installationQuery)
                                    push.setData(data)
                                    push.sendPushInBackgroundWithBlock { succeded, error in
                                        if error != nil {
                                            print("sendPushNotification error")
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            }
            
        })
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        self.sendMessage(text, video: nil, picture: nil)
    }
    
    func backToLogin(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        chatTitle = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(MessagesViewController.backToLogin(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(newButton, animated: false)
        _ = NSTimer.scheduledTimerWithTimeInterval(15.0, target: self, selector: #selector(MessagesViewController.counter(_:)), userInfo: nil, repeats: true)
        
        if chatTitle != nil {
            self.navigationItem.title = chatTitle
        }
        self.senderId = PFUser.currentUser()?.objectId!
        self.senderDisplayName = PFUser.currentUser()?.username!
        self.outgoingBubbleImage = self.bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        self.incomingBubbleImage = self.bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        
        let chars = self.senderDisplayName.characters
        self.initials.appendContentsOf("\(chars.first)")
        let nameArray: [String] = self.senderDisplayName.componentsSeparatedByString(" ")
        if nameArray.count == 1 {
            var comp: String = nameArray[0]
            self.initials = "\(comp.removeAtIndex(comp.startIndex))"
        } else if nameArray.count == 2 {
            var comp: String = nameArray[0]
            var comp2: String = nameArray[1]
            self.initials = "\(comp.removeAtIndex(comp.startIndex))\(comp2.removeAtIndex(comp2.startIndex))"
        } else if nameArray.count == 3 {
            var comp: String = nameArray[0]
            var comp2: String = nameArray[1]
            var comp3: String = nameArray[2]
            self.initials = "\(comp.removeAtIndex(comp.startIndex))\(comp2.removeAtIndex(comp2.startIndex))\(comp3.removeAtIndex(comp3.startIndex))"
        }
        self.blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(self.initials, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.blackColor(), font: self.font, diameter: 30)
    }
    
    func counter(sender: NSTimer) {
        if self.isLoading == false {
            loadMessages()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyScrollsToMostRecentMessage = true
        navigationController?.navigationBar.topItem?.title = "Logout"
        
        self.loadMessages()
        peekPop = PeekPop(viewController: self)
        peekPop?.registerForPreviewingWithDelegate(self, sourceView: self.collectionView!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView!.collectionViewLayout.springinessEnabled = true
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .Custom
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let photo = UIAlertAction(title: "Take photo", style: .Default, handler: {
            error in
            Camera.shouldStartCamera(self, canEdit: true, frontFacing: true)
        })
        actionSheet.addAction(photo)
        let lib = UIAlertAction(title: "Choose existing photo", style: .Default, handler: {
            error in
            Camera.shouldStartPhotoLibrary(self, canEdit: true)
        })
        actionSheet.addAction(lib)
        let vid = UIAlertAction(title: "Choose existing video", style: .Default, handler: {
            error in
            Camera.shouldStartVideoLibrary(self, canEdit: true)
        })
        actionSheet.addAction(vid)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = self.users[indexPath.item]
        if self.avatars[user.objectId!] == nil {
            let thumbnailFile = user[PF_USER_THUMBNAIL] as? PFFile
            thumbnailFile?.getDataInBackgroundWithBlock({
                imageData, error in
                if error == nil {
                    self.avatars[user.objectId! as String] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
                    self.collectionView!.reloadData()
                    self.collectionView?.layoutSubviews()
                }
            })
            return blankAvatarImage
        } else {
            return self.avatars[user.objectId!]
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if isLoading == false {
            let cell : JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
            let message = self.messages[indexPath.item]
            if message.isMediaMessage {
                if let mediaItem = message.media as? JSQVideoMediaItem {
                    let asset = AVAsset(URL: mediaItem.fileURL)
                    let item = AVPlayerItem(asset: asset)
                    let player: SCPlayer = SCPlayer()
                    player.loopEnabled = true
                    player.setItem(item)
                    let playerController2: SCVideoPlayerView = SCVideoPlayerView(player: player)
                    playerController2.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                    playerController2.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    playerController2.tapToPauseEnabled = true
                    playerController2.frame = CGRect(x: 0, y: 0, width: cell.mediaView!.bounds.width, height: cell.mediaView!.bounds.height)
                    playerController2.backgroundColor = .clearColor()
                    var add = true
                    for subs in (cell.mediaView?.subviews)! {
                        if subs is SCVideoPlayerView {
                            add = false
                        }
                    }
                    if add == true {
                        self.Players.append(playerController2)
                        cell.mediaView!.addSubview(playerController2)
                        cell.layoutIfNeeded()
                    }
                }
            }
            return cell
        }
        let cell: JSQMessagesCollectionViewCell = super.collectionView?.dequeueReusableCellWithReuseIdentifier( "MessageCell", forIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        if self.isLoading == false {
            let cell : JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
            let message = self.messages[indexPath.item]
            if message.isMediaMessage {
                if let mediaItem = message.media as? JSQVideoMediaItem {
                    let asset = AVAsset(URL: mediaItem.fileURL)
                    let item = AVPlayerItem(asset: asset)
                    let player: SCPlayer = SCPlayer()
                    player.loopEnabled = true
                    player.setItem(item)
                    self.PlayerControl = SCVideoPlayerView(player: player)
                    self.PlayerControl.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                    self.PlayerControl.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                    self.PlayerControl.tapToPauseEnabled = true
                    self.PlayerControl.frame = cell.mediaView!.bounds
                    self.collectionView?.reloadData()
                    
                }
                if let mediaItem2 = message.media as? JSQPhotoMediaItem {
                    self.imagePass = mediaItem2.image
                    self.collectionView?.reloadData()
                    //self.performSegueWithIdentifier("toImage", sender: nil)
                }
            }
        }
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        //self.PassPoint = touchLocation
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let video = info[UIImagePickerControllerMediaURL] as? NSURL
        let picture = info[UIImagePickerControllerEditedImage] as? UIImage
        self.sendMessage("", video: video, picture: picture)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func unwindToChat(segue: UIStoryboardSegue) {
        /*
        Empty. Exists solely so that "unwind to Login" segues can find
        instances of this class.
        */
    }
    
    
}
