//
//  RecorderView.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 3/18/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVKit
import AVFoundation
import Parse
import ParseUI

class RecorderView: UIViewController, SCPlayerDelegate, UIViewControllerTransitioningDelegate,  UINavigationControllerDelegate {
    
    var PlayerControl: SCVideoPlayerView = SCVideoPlayerView()
    var activityIndicatorView: NVActivityIndicatorView!
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        self.stopActivityIndicator()
    }
    
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
    
    override func viewWillAppear(animated: Bool) {
        self.startActivityIndicator()
        PlayerControl.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        PlayerControl.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        PlayerControl.tapToPauseEnabled = true
        PlayerControl.layer.masksToBounds = true
        PlayerControl.layer.cornerRadius = 0.0
        PlayerControl.layer.backgroundColor = UIColor.blackColor().CGColor
        PlayerControl.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        PlayerControl.player?.loopEnabled = true
        PlayerControl.player?.delegate = self
        self.view.addSubview(PlayerControl)
        
    }
    
    func checkPlaying() {
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            if self.isViewLoaded() == true {
                if ((self.view.window) != nil) {
                    self.PlayerControl.player?.play()
                } else {
                    self.checkPlaying()
                }
            } else {
                self.checkPlaying()
            }
        }
    }
    
    override func viewDidLoad() {
        
        
        //self.checkPlaying()
        /*let newButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(RecorderView.leave(_:)))
         newButton.tintColor = UIColor.whiteColor()
         self.navigationItem.setRightBarButtonItem(newButton, animated: false)*/
    }
    
    func leave(sender: UIBarButtonItem) {
        self.PlayerControl.player?.pause()
        self.performSegueWithIdentifier("leaveVideo", sender: nil)
    }
    
}

/*
import UIKit
import Foundation
import MediaPlayer
import AVKit
import AVFoundation

class RecorderView: UIViewController, SCPlayerDelegate {

    var PlayerControl: SCVideoPlayerView = SCVideoPlayerView()
    var activityIndicatorView: NVActivityIndicatorView!
    
    func player(player: SCPlayer, didPlay currentTime: CMTime, loopsCount: Int) {
        self.stopActivityIndicator()
    }
    
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
    
    override func viewWillAppear(animated: Bool) {
        self.startActivityIndicator()
        PlayerControl.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        PlayerControl.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        PlayerControl.tapToPauseEnabled = true
        PlayerControl.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        PlayerControl.player?.loopEnabled = true
        PlayerControl.player?.delegate = self
        self.view.addSubview(PlayerControl)
    }
    
    func checkPlaying() {
        let delayInSeconds = 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            if self.isViewLoaded() == true {
                if ((self.view.window) != nil) {
                    self.PlayerControl.player?.play()
                } else {
                    self.checkPlaying()
                }
            } else {
                self.checkPlaying()
            }
        }
    }
    
    override func viewDidLoad() {
        self.checkPlaying()
        let newButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(RecorderView.leave(_:)))
        newButton.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(newButton, animated: false)
    }
    
    func leave(sender: UIBarButtonItem) {
        self.PlayerControl.player?.pause()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}*/