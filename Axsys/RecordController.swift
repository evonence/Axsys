//
//  RecordController.swift
//  ShownTell
//
//  Created by Dillon Murphy on 2/16/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices

import AVKit
import AVFoundation

let kVideoPreset = AVCaptureSessionPresetHigh

extension UIView {
    func startRotating(duration: Double = 0.5) {
        let kAnimationKey = "rotation"
        
        if self.layer.animationForKey(kAnimationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = duration
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float(M_PI * 2.0)
            self.layer.addAnimation(animate, forKey: kAnimationKey)
        }
    }
    func stopRotating() {
        let kAnimationKey = "rotation"
        
        if self.layer.animationForKey(kAnimationKey) != nil {
            self.layer.removeAnimationForKey(kAnimationKey)
        }
    }
}

@objc public class RecordViewController: UIViewController, SCRecorderDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var menuButton: UIView!
    @IBOutlet weak var retakeButton: UIButton!
    
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var timeRecordedLabel: UILabel!
    @IBOutlet weak var downBar: UIView!
    @IBOutlet weak var switchCameraModeButton: UIButton!
    @IBOutlet weak var reverseCamera: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var capturePhotoButton: UIButton!
    @IBOutlet weak var ghostModeButton: UIButton!
    @IBOutlet weak var toolsContainerView: UIView!
    @IBOutlet weak var openToolsButton: UIButton!
    
    @IBOutlet weak var CameraImageView: UIImageView!
    
    @IBOutlet weak var PlayImage: UIImageView!
    
    
    public var player: SCPlayer!
    
    var item1: ExpandingMenuItem!
    var item2: ExpandingMenuItem!
    var item3: ExpandingMenuItem!
    var item4: ExpandingMenuItem!
    var item5: ExpandingMenuItem!
    var item6: ExpandingMenuItem!
    
    let path = NSBundle.mainBundle().pathForResource("spinning", ofType:"mov")
    var Vplayer: AVPlayer = AVPlayer()
    let VplayerController = AVPlayerViewController()

    
    var tapped = false

    var recorder: SCRecorder = SCRecorder()
    var photo: UIImage?
    var ghostImageView: UIImageView?
    
    var playerView : SCVideoPlayerView?
    
    var focusView: SCRecorderToolsView?
    
    
    var menuOpen = false
   

    @IBAction func switchCameraMode(sender: AnyObject) {
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {() -> Void in
                self.capturePhotoButton.alpha = 0.0
                self.recordView.alpha = 1.0
                self.retakeButton.alpha = 1.0
                self.menuButton.alpha = 1.0
                }, completion: {(finished: Bool) -> Void in
                    self.recorder.captureSessionPreset = kVideoPreset
                    self.switchCameraModeButton.setTitle("Switch Photo", forState: .Normal)
                    self.flashModeButton.setTitle("Flash : Off", forState: .Normal)
                    self.recorder.flashMode = SCFlashMode.Off
            })
        }
        else {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: {() -> Void in
                self.recordView.alpha = 0.0
                self.retakeButton.alpha = 0.0
                self.menuButton.alpha = 0.0
                self.capturePhotoButton.alpha = 1.0
                
                }, completion: {(finished: Bool) -> Void in
                    self.recorder.captureSessionPreset = AVCaptureSessionPresetPhoto
                    self.switchCameraModeButton.setTitle("Switch Video", forState: .Normal)
                    self.flashModeButton.setTitle("Flash : Auto", forState: .Normal)
                    self.recorder.flashMode = SCFlashMode.Auto
            })
        }
    }
    
    @IBAction func switchFlash(sender: AnyObject) {
        var flashModeString: String? = nil
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            switch recorder.flashMode {
            case .Auto:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.On
            case .On:
                flashModeString = "Flash : Light"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Auto"
                self.recorder.flashMode = SCFlashMode.Auto
            }
        }
        else {
            switch recorder.flashMode {
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            default:
                break
            }
        }
        self.flashModeButton.setTitle(flashModeString!, forState: .Normal)
    }
    
    @IBAction func capturePhoto(sender: AnyObject) {
        recorder.capturePhoto({
                (error: NSError?, image: UIImage?) -> Void in
                if image != nil {
                    self.showPhoto(image!)
                }
                else {
                    self.showAlertViewWithTitle("Failed to capture photo", message: error!.localizedDescription)
                }
            })
    }
    
    @IBAction func switchGhostMode(sender: AnyObject) {
        //self.ghostModeButton.selected = !ghostModeButton.selected
        //self.ghostImageView!.hidden = !ghostModeButton.selected
        //self.updateGhostImage()
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    func addPopupMenu() {
        let menuButtonSize: CGSize = CGSize(width: 45.0, height: 45.0)
        let newHam: UIImage = Images.resizeImage(UIImage(named: "Hamburger")!, width: 45.0, height: 45.0)!
        let newSave: UIImage = Images.resizeImage(UIImage(named: "saveIcon")!, width: 85.0, height: 85.0)!
        let newRetake: UIImage = Images.resizeImage(UIImage(named: "Retake")!, width: 45.0, height: 45.0)!
        let newShot: UIImage = Images.resizeImage(UIImage(named: "Shutter")!, width: 55.0, height: 55.0)!
        let newtools: UIImage = Images.resizeImage(UIImage(named: "tools")!, width: 45.0, height: 45.0)!
        let newflip: UIImage = Images.resizeImage(UIImage(named: "capture_flip")!, width: 45.0, height: 45.0)!
        let newquit: UIImage = Images.resizeImage(UIImage(named: "Cancel")!, width: 45.0, height: 45.0)!
        
        let addMenuButton = ExpandingMenuButton(frame: CGRect(origin: CGPointZero, size: menuButtonSize), centerImage: newHam, centerHighlightedImage: newHam)
        let newPoint = CGPointMake(menuButton.center.x, self.view.bounds.height - (menuButton.bounds.height / 1.8))
        addMenuButton.center = newPoint
            //CGPointMake(onThirdRight, self.view.bounds.height - 72.0)
        self.view.addSubview(addMenuButton)
        //menuButton.center = CGPointMake(self.view.bounds.width - 32.0, self.view.bounds.height - 72.0)
        //view.addSubview(menuButton)
        
        item1 = ExpandingMenuItem(size: menuButtonSize, title: "Edit/Save", image: newSave, highlightedImage: newSave, backgroundImage: newSave, backgroundHighlightedImage: newSave) { () -> Void in
            self.saveAndShowSession(self.recorder.session!)
        }
        
        
        item2 = ExpandingMenuItem(size: menuButtonSize, title: "Retake", image: newRetake, highlightedImage: newRetake, backgroundImage: newRetake, backgroundHighlightedImage:  newRetake) { () -> Void in
            recordSession = self.recorder.session!
            if recordSession != SCRecordSession() {
                self.recorder.session = nil
                // If the recordSession was saved, we don't want to completely destroy it
                if SCRecordSessionManager.sharedInstance().isSaved(recordSession) {
                    recordSession!.endSegmentWithInfo(nil, completionHandler: nil)
                }
                else {
                    recordSession!.cancelSession(nil)
                }
            }
            self.prepareSession()
        }
        
        item3 = ExpandingMenuItem(size: menuButtonSize, title: "Screenshot", image: newShot, highlightedImage: newShot, backgroundImage: newShot, backgroundHighlightedImage: newShot) { () -> Void in
            self.recorder.capturePhoto({
                (error: NSError?, image: UIImage?) -> Void in
                if image != nil {
                    self.showPhoto(image!)
                }
                else {
                    self.showAlertViewWithTitle("Failed to capture photo", message: error!.localizedDescription)
                }
            })
        }
        
        
        item4 = ExpandingMenuItem(size: menuButtonSize, title: "Open Tools", image: newtools, highlightedImage: newtools, backgroundImage: newtools, backgroundHighlightedImage: newtools) { () -> Void in
            if self.tapped == false {
                self.tapped = true
                self.toolsContainerView.hidden = false
                self.item4.title = "Close Tools"
            } else {
                self.tapped = false
                self.toolsContainerView.hidden = true
                self.item4.title =  "Open Tools"
                
            }
        }
        
       
        item5 = ExpandingMenuItem(size: menuButtonSize, title: "Flip Camera", image: newflip, highlightedImage: newflip, backgroundImage: newflip, backgroundHighlightedImage: newflip) { () -> Void in
            self.recorder.switchCaptureDevices()
        }
        
        item6 = ExpandingMenuItem(size: menuButtonSize, title: "Quit Camera", image: newquit, highlightedImage: newquit, backgroundImage: newquit, backgroundHighlightedImage: newquit) { () -> Void in
            self.performSegueWithIdentifier("toVert", sender: nil)
        }
        
        
        addMenuButton.addMenuItems([item1, item2, item3, item4, item5, item6])
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.capturePhotoButton.alpha = 0.0
        //self.ghostImageView = UIImageView(frame: self.view.bounds)
        //self.ghostImageView!.contentMode = .ScaleAspectFill
        //self.ghostImageView!.alpha = 0.2
        //self.ghostImageView!.userInteractionEnabled = false
        //self.ghostImageView!.hidden = true
        //self.view!.insertSubview(ghostImageView!, aboveSubview: self.previewView)
        
        
    }
    
    
    
    
    public func recorder(recorder: SCRecorder, didSkipVideoSampleBufferInSession recordSession: SCRecordSession) {
        NSLog("Skipped video buffer")
    }
    
    public func recorder(recorder: SCRecorder, didReconfigureAudioInput audioInputError: NSError?) {
        //NSLog("Reconfigured audio input: %@", audioInputError!)
    }
    
    public func recorder(recorder: SCRecorder, didReconfigureVideoInput videoInputError: NSError?) {
        //NSLog("Reconfigured video input: %@", videoInputError!)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.orangeColor().complementaryColor()
        
    
       
        
        //self.stopButton
        let previewView: UIView = self.previewView
        
        self.recorder.captureSessionPreset = SCRecorderTools.bestCaptureSessionPresetCompatibleWithAllDevices()
        self.recorder.maxRecordDuration = CMTimeMake(5, 1);
        self.recorder.delegate = self
        self.recorder.videoConfiguration
        self.recorder.SCImageView?.context = SCContext(type: SCContextType.Auto, options: nil)
        self.recorder.autoSetVideoOrientation = true
        self.recorder.previewView = previewView
        self.recordView.addGestureRecognizer(SCTouchDetector(target: self, action: #selector(RecordViewController.handleTouchDetected(_:))))
        self.loadingView.hidden = true
        self.focusView = SCRecorderToolsView(frame: previewView.bounds)
        self.focusView!.autoresizingMask = [.FlexibleBottomMargin, .FlexibleHeight, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleWidth]
        self.focusView!.recorder = recorder
        previewView.addSubview(self.focusView!)
        //self.focusView!.outsideFocusTargetImage = UIImage(named: "capture_flip")
        //self.focusView!.insideFocusTargetImage = UIImage(named: "capture_flip")
        self.recorder.initializeSessionLazily = false
        self.prepareSession()
        self.navigationController!.navigationBarHidden = true
        self.recorder.startRunning()
    }
    
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    
    func FlashPop() {
        print("Flash")
        var flashModeString: String? = nil
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            switch recorder.flashMode {
            case .Auto:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.On
            case .On:
                flashModeString = "Flash : Light"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Auto"
                self.recorder.flashMode = SCFlashMode.Auto
            }
        }
        else {
            switch recorder.flashMode {
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            default:
                break
            }
        }
        self.flashModeButton.setTitle(flashModeString!, forState: .Normal)
    }
    
    
    func PhotoPop(sender: UIButton) {
        print("Flash")
        var flashModeString: String? = nil
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            switch recorder.flashMode {
            case .Auto:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.On
            case .On:
                flashModeString = "Flash : Light"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Auto"
                self.recorder.flashMode = SCFlashMode.Auto
            }
        }
        else {
            switch recorder.flashMode {
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            default:
                break
            }
        }
        self.flashModeButton.setTitle(flashModeString!, forState: .Normal)
    }
    
    func GhostPop(sender: UIButton) {
        print("Flash")
        var flashModeString: String? = nil
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            switch recorder.flashMode {
            case .Auto:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.On
            case .On:
                flashModeString = "Flash : Light"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Auto"
                self.recorder.flashMode = SCFlashMode.Auto
            }
        }
        else {
            switch recorder.flashMode {
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            default:
                break
            }
        }
        self.flashModeButton.setTitle(flashModeString!, forState: .Normal)
    }
    
    func ImportPop(sender: UIButton) {
        print("Flash")
        var flashModeString: String? = nil
        if (recorder.captureSessionPreset == AVCaptureSessionPresetPhoto) {
            switch recorder.flashMode {
            case .Auto:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.On
            case .On:
                flashModeString = "Flash : Light"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Auto"
                self.recorder.flashMode = SCFlashMode.Auto
            }
        }
        else {
            switch recorder.flashMode {
            case .Off:
                flashModeString = "Flash : On"
                self.recorder.flashMode = SCFlashMode.Light
            case .Light:
                flashModeString = "Flash : Off"
                self.recorder.flashMode = SCFlashMode.Off
            default:
                break
            }
        }
        self.flashModeButton.setTitle(flashModeString!, forState: .Normal)
    }
    
    
    

       override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recorder.previewViewFrameChanged()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.addPopupMenu()
        
        
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        recorder.stopRunning()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController!.navigationBarHidden = false
        self.recorder.previewView = nil
    }
    
    func showAlertViewWithTitle(title: String, message: String) {
        let alertView: UIAlertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alertView.show()
    }
    
    
    func playIcon() {
        
        CameraImageView.image = UIImage(named: "CameraSwirl")
        CameraImageView.startRotating()
        
    }
    
    func stopIcon() {
        CameraImageView.stopRotating()
    }
    
    
 
    
    
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(SCVideoPlayerViewController) {
        let videoPlayer: SCVideoPlayerViewController = (segue.destinationViewController as? SCVideoPlayerViewController)!
            videoPlayer.recordSessions = recordSession
        } else if segue.destinationViewController.isKindOfClass(SCSessionListViewController) {
            let sessionListVC: SCSessionListViewController = (segue.destinationViewController as? SCSessionListViewController)!
            sessionListVC.recorder = recorder
        }
            /*
        else if segue.destinationViewController.isKindOfClass(SCImageDisplayerViewController) {
        var imageDisplayer: SCImageDisplayerViewController = (segue.destinationViewController as? SCImageDisplayerViewController)!
        imageDisplayer.photo = photo
        self.photo = UIImage()
        }
        
        */
    }
    
    func showPhoto(photo: UIImage) {
        self.photo = photo
        //self.performSegueWithIdentifier("Photo", sender: self)
    }
    
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        let url = info[UIImagePickerControllerMediaURL] as! NSURL
        picker.dismissViewControllerAnimated(true, completion: nil)
        let segment: SCRecordSessionSegment = (NSURL(fileURLWithPath: url.path!) as? SCRecordSessionSegment)!
        //SCRecordSessionSegment.segmentURLForFilename(url.path!, andDirectory: "")
        recorder.session!.addSegment(segment)
        recordSession = SCRecordSession()
        recordSession!.addSegment(segment)
        self.performSegueWithIdentifier("Video", sender: self)
    }
    
    
    
    func handleStopButtonTapped(sender: AnyObject) {
        playerView?.removeFromSuperview()
        recorder.pause({() -> Void in
            self.saveAndShowSession(self.recorder.session!)
        })
    }
    
    func saveAndShowSession(recordSessions: SCRecordSession) {
        SCRecordSessionManager.sharedInstance().saveRecordSession(recordSessions)
        recordSession = recordSessions
        self.performSegueWithIdentifier("Video", sender: self)
    }
    
    
    
    func prepareSession() {
        if recorder.session == nil {
            let session: SCRecordSession = SCRecordSession()
            session.fileType = AVFileTypeQuickTimeMovie
            self.recorder.session = session
        }
        self.updateTimeRecordedLabel()
        //self.updateGhostImage()
    }
    
    public func recorder(recorder: SCRecorder, didCompleteSession recordSessions: SCRecordSession) {
        NSLog("didCompleteSession:")
        self.saveAndShowSession(recordSessions)
    }
    
    public func recorder(recorder: SCRecorder, didInitializeAudioInSession recordSession: SCRecordSession, error: NSError?) {
        if recorder.session != nil {
            //NSLog("Initialized audio in record session")
        }
        else {
            //NSLog("Failed to initialize audio in record session: %@", error!.localizedDescription)
        }
    }
    
    
    public func recorder(recorder: SCRecorder, didInitializeVideoInSession recordSession: SCRecordSession, error: NSError?) {
        if recorder.session != nil {
            //NSLog("Initialized video in record session")
        }
        else {
            //NSLog("Failed to initialize video in record session: %@", error!.localizedDescription)
        }
    }
    
    public func recorder(recorder: SCRecorder, didBeginSegmentInSession recordSession: SCRecordSession, error: NSError?) {
        //NSLog("Began record segment: %@", error!)
    }
    
    public func recorder(recorder: SCRecorder, didCompleteSegment segment: SCRecordSessionSegment?, inSession recordSession: SCRecordSession, error: NSError?) {
        //NSLog("Completed record segment at %@: %@ (frameRate: %f)", segment!.url, error!, segment!.frameRate)
        //self.updateGhostImage()
    }
    
    func updateTimeRecordedLabel() {
        var currentTime: CMTime = kCMTimeZero
        if recorder.session != nil {
            currentTime = recorder.session!.duration
        }
        self.timeRecordedLabel.text = String(format: "%.2f sec", CMTimeGetSeconds(currentTime))
    }
    
    public func recorder(recorder: SCRecorder, didAppendVideoSampleBufferInSession recordSession: SCRecordSession) {
        self.updateTimeRecordedLabel()
    }
    
    func handleTouchDetected(touchDetector: SCTouchDetector) {
        if touchDetector.state == .Began {
            //self.ghostImageView!.hidden = true
            //retakeButton.hidden = true
            //stopButton.hidden = true
            recorder.record()
            //CameraImageView.hidden = true
            self.PlayImage.image = UIImage(named: "Pause")
            //let rec = CGRect(x: (self.PlayImage.minX - 10), y: self.PlayImage.minY, width: self.PlayImage.width, height: self.PlayImage.height)
            //self.PlayImage.frame = rec
            self.playIcon()
            playerView?.removeFromSuperview()
        }
        else if touchDetector.state == .Ended {
            //retakeButton.hidden = false
            //stopButton.hidden = false
            self.PlayImage.image = UIImage(named: "Play")
            recorder.pause()
            self.stopIcon()
            //CameraImageView.hidden = false
        }
        
    }
    
    
    /*
    func updateGhostImage() {
        var image: UIImage? = nil
        if ghostModeButton.selected {
            if recorder.session!.segments.count > 0 {
                var segment: SCRecordSessionSegment = recorder.session!.segments.last! as! SCRecordSessionSegment
                image = segment.lastImage
            }
        }
        self.ghostImageView!.image = UIImage()
        self.ghostImageView!.image = recorder.snapshotOfLastVideoBuffer()
        self.ghostImageView!.hidden = !ghostModeButton.selected
    }
    */
    
    
    override  public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func toolsButtonTapped(sender: UIButton) {
        if tapped == false {
            tapped = true
            toolsContainerView.hidden = false
            sender.titleLabel!.text = "Close Tools"
        } else {
            tapped = false
            toolsContainerView.hidden = true
             sender.titleLabel!.text = "Open Tools"
            
        }
        
    }
    
    @IBAction func closeCameraTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("toVert", sender: nil)
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
}


