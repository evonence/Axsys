//
//  VidPlayerContoller.swift
//  ShownTell
//
//  Created by Dillon Murphy on 2/16/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia





class VidPlayerController: UIViewController, SCPlayerDelegate, SCAssetExportSessionDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate,  UINavigationControllerDelegate {
    
    var recordSession: SCRecordSession?
   
    
    var playerView : SCVideoPlayerView = SCVideoPlayerView()
    
    var imgViewed : SCImageView?
    
    let transition = BubbleTransition()
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .burntOrangeColor()
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(VidPlayerController.backToEvents(_:)))
        backButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButtonItem(backButton, animated: false)
        
        playerView.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.frame = self.view.bounds
        playerView.layer.cornerRadius = 0.0
        playerView.layer.masksToBounds = true
        playerView.layer.backgroundColor = UIColor.blackColor().CGColor
        playerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        playerView.tapToPauseEnabled = true
        self.view.addSubview(playerView)
        
    }
    
    func backToEvents(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("exitEvent", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .Custom
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.startingPoint = self.view.center
        transition.bubbleColor = UIColor.blackColor()
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.startingPoint = self.view.center
        transition.bubbleColor = UIColor.blackColor()
        return transition
    }
    
    
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.playerView.player?.pause()
    }
    
        
       
    
    
}
