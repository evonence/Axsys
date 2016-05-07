//
//  myExtensions.swift
//  ShownTell
//
//  Created by Dillon Murphy on 4/9/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import Foundation
import UIKit
import ParseUI


public enum ShakeDirection : Int {
    case Horizontal
    case Vertical
    
    private func startPosition() -> ShakePosition {
        switch self {
        case .Horizontal:
            return ShakePosition.Left
        default:
            return ShakePosition.Top
        }
    }
}


private struct DefaultValues {
    static let numberOfTimes = 5
    static let totalDuration : Float = 0.5
}

extension CLPlacemark {
    func getAddress() -> String {
        let str1: String = self.subThoroughfare!
        let str2: String = self.thoroughfare!
        let str3: String = self.locality!
        let str4: String = self.administrativeArea!
        let str5: String = self.postalCode!
        // try to build full address first
        let address = "\(str1) \(str2) \(str3), \(str4) \(str5)"
        return address
    }
}

/*
extension UIViewController {
    func startActivityIndicator() {
        /*if activityIndicatorView.hidden == false {
         self.stopActivityIndicator()
         }*/
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
}
*/
extension UIView {
    
    /**
     Shake a view back and forth for the number of times given in the duration specified.
     If the total duration given is 1 second, and the number of shakes is 5, it will use 0.20 seconds per shake.
     After it's done shaking, the completion handler is called, if specified.
     
     :param: direction     The direction to shake (horizontal or vertical motion)
     :param: numberOfTimes The total number of times to shake back and forth, default value is 5
     :param: totalDuration Total duration to do the shakes, default is 0.5 seconds
     :param: completion    Optional completion closure
     */
    public func shake(direction: ShakeDirection, numberOfTimes: Int = DefaultValues.numberOfTimes, totalDuration : Float = DefaultValues.totalDuration, completion: (() -> Void)? = nil) -> UIView? {
        if UIAccessibilityIsVoiceOverRunning() {
            return self
        } else {
            let timePerShake = Double(totalDuration) / Double(numberOfTimes)
            shake(numberOfTimes, position: direction.startPosition(), durationPerShake: timePerShake, completion: completion)
            return nil
        }
        
    }
    
    public func postAccessabilityNotification(text : String ) {
        var hasRead = false
        NSNotificationCenter.defaultCenter().addObserverForName(UIAccessibilityAnnouncementDidFinishNotification, object: nil , queue: nil) { (notification) -> Void in
            if hasRead == false {
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, text)
                hasRead = true
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIAccessibilityAnnouncementDidFinishNotification, object:nil)
            }
        }
        
        let delayInSeconds = 0.01
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, " ")
        }
        
        
    }
    
    func didFinishReadingAccessabilityLabel() {
        dispatch_async(dispatch_get_main_queue(), {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, "hello world")
        })
    }
    
    private func shake(forTimes: Int, position: ShakePosition, durationPerShake: NSTimeInterval, completion: (() -> Void)?) {
        UIView.animateWithDuration(durationPerShake, animations: { () -> Void in
            
            switch position.direction {
            case .Horizontal:
                self.layer.setAffineTransform( CGAffineTransformMakeTranslation(2 * position.value, 0))
                break
            case .Vertical:
                self.layer.setAffineTransform( CGAffineTransformMakeTranslation(0, 2 * position.value))
                break
            }
        }) { (complete) -> Void in
            if (forTimes == 0) {
                UIView.animateWithDuration(durationPerShake, animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransformIdentity)
                    }, completion: { (complete) -> Void in
                        completion?()
                })
            } else {
                self.shake(forTimes - 1, position: position.oppositePosition(), durationPerShake: durationPerShake, completion:completion)
            }
        }
    }
    
}

private struct ShakePosition  {
    
    let value : CGFloat
    let direction : ShakeDirection
    
    init(value: CGFloat, direction : ShakeDirection) {
        self.value = value
        self.direction = direction
    }
    
    
    func oppositePosition() -> ShakePosition {
        return ShakePosition(value: (self.value * -1), direction: direction)
    }
    
    static var Left : ShakePosition {
        get {
            return ShakePosition(value: 1, direction: .Horizontal)
        }
    }
    
    static var Right : ShakePosition {
        get {
            return ShakePosition(value: -1, direction: .Horizontal)
        }
    }
    
    static var Top : ShakePosition {
        get {
            return ShakePosition(value: 1, direction: .Vertical)
        }
    }
    
    static var Bottom : ShakePosition {
        get {
            return ShakePosition(value: -1, direction: .Vertical)
        }
    }
}





extension NSData {
    var asUIImage:UIImage? {
        return UIImage(data: self)
    }
}

extension UIImage {
    var asNSData :NSData! {
        return UIImagePNGRepresentation(self)
    }
}

extension SwipeCell {
    func GradLayerTable(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        let color4 = color.lightenedColor(0.7).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1, color4]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 0.98, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
}

internal extension NSDateComponents {
    func to1201() {
        self.hour = 0
        self.minute = 0
        self.second = 1
    }
    
    func to1159() {
        self.hour = 23
        self.minute = 59
        self.second = 59
    }
}

extension CGFloat {
    /// Rounds the double to decimal places value
    func showPercent() -> String {
        let percent = Int(self * 100)
        return "\(percent)%"
    }
    
    func show50Percent() -> String {
        let percent = Int(self) + 50
        return "\(percent)%"
    }
}

extension NSDate {
    
    func toLocalTime() -> NSDate? {
        let timezone: NSTimeZone = NSTimeZone.localTimeZone()
        let seconds: Double = Double(timezone.secondsFromGMTForDate(self))
        return NSDate(timeInterval: seconds, sinceDate: self)
    }
    
    func startOfMonth() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components([.Year, .Month], fromDate: self) else { return nil }
        comp.to1201()
        return cal.dateFromComponents(comp)!.toLocalTime()!
    }
    
    func endOfMonth() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = NSDateComponents() else { return nil }
        comp.month = 1
        comp.day -= 1
        comp.to1159()
        return cal.dateByAddingComponents(comp, toDate: self.startOfMonth()!, options: [])!
    }
    
    func startOfDay() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = cal.components([.Year, .Month, .Day], fromDate: self) else { return nil }
        comp.to1201()
        return cal.dateFromComponents(comp)!.toLocalTime()!
    }
    
    func endOfDay() -> NSDate? {
        guard
            let cal: NSCalendar = NSCalendar.currentCalendar(),
            let comp: NSDateComponents = NSDateComponents() else { return nil }
        comp.hour = 23
        comp.minute = 59
        comp.second = 58
        return cal.dateByAddingComponents(comp, toDate: self.startOfDay()!, options: [])!
    }
}



extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}


extension UITextView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    /*
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: CGColor {
        get {
            return layer.borderColor!
        }
        set {
            layer.borderColor = borderColor
        }
    }*/
    
}


import UIKit

@IBDesignable class DesignableButton: UIButton {
    
    // IBInspectable properties for the gradient colors
    @IBInspectable var bottomColor: UIColor = .crimsonColor()
    @IBInspectable var middleColor: UIColor = .crimsonColor()
    @IBInspectable var topColor: UIColor = .crimsonColor()
    @IBInspectable var bottomColorAlpha: CGFloat = 1.0
    @IBInspectable var middleColorAlpha: CGFloat = 1.0
    @IBInspectable var topColorAlpha: CGFloat = 1.0
    
    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.blackColor()
    @IBInspectable var borderAlpha: CGFloat = 1.0
    
    override func drawRect(rect: CGRect) {
        
        // set up border and cornerRadius
        self.layer.cornerRadius = cornerSize
        self.layer.borderColor = borderColor.colorWithAlphaComponent(borderAlpha).CGColor
        self.layer.borderWidth = borderSize
        self.layer.masksToBounds = true
        
        // set up gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        let c1 = bottomColor.colorWithAlphaComponent(bottomColorAlpha).CGColor
        let c2 = middleColor.colorWithAlphaComponent(middleColorAlpha).CGColor
        let c3 = topColor.colorWithAlphaComponent(topColorAlpha).CGColor
        gradientLayer.colors = [c3, c2, c1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        
    }
    
}

@IBDesignable class DesignableView: UIView {
    
    
    // IBInspectable properties for the gradient colors
    @IBInspectable var bottomColor: UIColor = UIColor.crimsonColor().lightenedColor(0.2)
    @IBInspectable var middleColor: UIColor = UIColor.crimsonColor().lightenedColor(0.2)
    @IBInspectable var topColor: UIColor = UIColor.crimsonColor().lightenedColor(0.2)
    @IBInspectable var bottomColorAlpha: CGFloat = 1.0
    @IBInspectable var middleColorAlpha: CGFloat = 0.8
    @IBInspectable var topColorAlpha: CGFloat = 1.0
    
    // IBInspectable properties for rounded corners and border color / width
    @IBInspectable var cornerSize: CGFloat = 0
    @IBInspectable var borderSize: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.crimsonColor().lightenedColor(0.2)
    @IBInspectable var borderAlpha: CGFloat = 1.0
    
    override func drawRect(rect: CGRect) {
        
        // set up border and cornerRadius
        self.layer.cornerRadius = cornerSize
        self.layer.borderColor = borderColor.colorWithAlphaComponent(borderAlpha).CGColor
        self.layer.borderWidth = borderSize
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.crimsonColor().lightenedColor(0.2)
        // set up gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        let c1 = bottomColor.colorWithAlphaComponent(bottomColorAlpha).CGColor
        let c2 = middleColor.colorWithAlphaComponent(middleColorAlpha).CGColor
        let c3 = topColor.colorWithAlphaComponent(topColorAlpha).CGColor
        gradientLayer.colors = [c3, c2, c1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
        
    }
    
}


/*

extension GradientButton {
    func GradMe(color: UIColor) {
        self.useColorStyle(color.darkenedColor(0.25), color2: color, color3: color.lightenedColor(0.4), color4: color.lightenedColor(0.7))
    }
}
*/
class ProgressSpin: UIView {
    
    //var HUD_BACKGROUND_COLOR: UIColor = UIColor.whiteColor()
    //var HUD_IMAGE_SUCCESS: UIImage = UIImage(named:"ProgressHUD.bundle/progresshud-success.png")!
    //var HUD_IMAGE_ERROR: UIImage = UIImage(named:"ProgressHUD.bundle/progresshud-error.png")!
    
    
    
    var spinwindow: UIWindow?
    var background:UIView?
    var hud:UIToolbar = UIToolbar()
    var spinner:UIActivityIndicatorView?
    var imageview:UIImageView?
    var label:UILabel?
    var interaction: Bool = false
    
    
    /*
     
     UIViewAnimationOptionLayoutSubviews            = 1 <<  0,
     UIViewAnimationOptionAllowUserInteraction      = 1 <<  1, // turn on user interaction while animating
     UIViewAnimationOptionBeginFromCurrentState     = 1 <<  2, // start all views from current value, not initial value
     UIViewAnimationOptionRepeat                    = 1 <<  3, // repeat animation indefinitely
     UIViewAnimationOptionAutoreverse               = 1 <<  4, // if repeat, run animation back and forth
     UIViewAnimationOptionOverrideInheritedDuration = 1 <<  5, // ignore nested duration
     UIViewAnimationOptionOverrideInheritedCurve    = 1 <<  6, // ignore nested curve
     UIViewAnimationOptionAllowAnimatedContent      = 1 <<  7, // animate contents (applies to transitions only)
     UIViewAnimationOptionShowHideTransitionViews   = 1 <<  8, // flip to/from hidden state instead of adding/removing
     UIViewAnimationOptionOverrideInheritedOptions  = 1 <<  9, // do not inherit any options or animation type
     
     UIViewAnimationOptionCurveEaseInOut            = 0 << 16, // default
     UIViewAnimationOptionCurveEaseIn               = 1 << 16,
     UIViewAnimationOptionCurveEaseOut              = 2 << 16,
     UIViewAnimationOptionCurveLinear               = 3 << 16,
     
     UIViewAnimationOptionTransitionNone            = 0 << 20, // default
     UIViewAnimationOptionTransitionFlipFromLeft    = 1 << 20,
     UIViewAnimationOptionTransitionFlipFromRight   = 2 << 20,
     UIViewAnimationOptionTransitionCurlUp          = 3 << 20,
     UIViewAnimationOptionTransitionCurlDown        = 4 << 20,
     UIViewAnimationOptionTransitionCrossDissolve   = 5 << 20,
     UIViewAnimationOptionTransitionFlipFromTop     = 6 << 20,
     UIViewAnimationOptionTransitionFlipFromBottom  = 7 << 20,
     
     */
    
    init() {
        super.init(frame: UIScreen.mainScreen().bounds)
        spinwindow = UIApplication.sharedApplication().keyWindow
        hud.translucent = true
        hud.backgroundColor = .whiteColor()
        hud.layer.cornerRadius = 10
        hud.layer.masksToBounds = true
        if (hud.superview == nil){
            if (interaction == false){
                background = UIView(frame: spinwindow!.frame)
                background!.backgroundColor = UIColor(colorLiteralRed: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2)
                spinwindow!.addSubview(background!)
                background!.addSubview(hud)
            } else {
                spinwindow!.addSubview(hud)
            }
        }
        if (spinner == nil) {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            spinner!.color = UIColor(colorLiteralRed: 185.0/255.0, green: 220.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            spinner!.hidesWhenStopped = true
        }
        if (spinner!.superview == nil) {
            hud.addSubview(spinner!)
        }
        if (imageview == nil) {
            imageview = UIImageView(frame:CGRect(x: 0, y: 0, width: 28, height: 28))
        }
        if (imageview!.superview == nil) {
            hud.addSubview(imageview!)
        }
        if (label == nil){
            label = UILabel(frame:CGRectZero)
            label!.font = UIFont.boldSystemFontOfSize(16)
            label!.textColor = UIColor.blackColor()
            label!.backgroundColor = UIColor.clearColor()
            label!.textAlignment = NSTextAlignment.Center
            label!.baselineAdjustment = UIBaselineAdjustment.AlignCenters
            label!.numberOfLines = 0
        }
        if (label!.superview == nil) {
            hud.addSubview(label!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func show() {
        
    }
    
    
    func showProgress(int: Int) {
        self.hudMake("Loading..\(int)%", image: nil, spin: true, hide: true)
    }
    
    
    func show(string: String, Interaction: Bool) {
        self.hudMake(string, image: nil, spin: true, hide: false)
    }
    
    
    
    func registerNotifications() {
        /*
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressSpin.hudPosition(_:)), name: UIApplicationDidChangeStatusBarOrientationNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressSpin.hudPosition(_:)), name: UIKeyboardWillHideNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressSpin.hudPosition(_:)), name: UIKeyboardDidHideNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressSpin.hudPosition(_:)), name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressSpin.hudPosition(_:)), name: UIKeyboardDidShowNotification, object: nil)*/
    }
    
    func hudDestroy() {
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        label!.removeFromSuperview()
        label! = UILabel()
        imageview!.removeFromSuperview()
        imageview! = UIImageView()
        spinner!.removeFromSuperview()
        spinner! = UIActivityIndicatorView()
        hud.removeFromSuperview()
        hud = UIToolbar()
        background!.removeFromSuperview()
        background = UIView()
    }
    
    func hudSize() {
        var labelRect: CGRect = CGRectZero
        var hudWidth:CGFloat = 100
        var hudHeight: CGFloat = 100
        if (label!.text != nil) {
            let attributes: [String : AnyObject] = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
            let drawoptions: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading, .UsesDeviceMetrics, .TruncatesLastVisibleLine]
            labelRect = label!.text!.boundingRectWithSize(CGSize(width: 200, height: 300), options:drawoptions, attributes:attributes, context:nil)
            
            labelRect.origin.x = 12
            labelRect.origin.y = 66
            hudWidth = labelRect.size.width + 24
            hudHeight = labelRect.size.height + 80
            
            if (hudWidth < 100)  {
                hudWidth = 100
                labelRect.origin.x = 0
                labelRect.size.width = 100
            }
        }
        hud.bounds = CGRect(x: 0,y: 0,width: hudWidth,height: hudHeight)
        let imagex = hudWidth / 2
        let imagey = (label!.text == nil) ? hudHeight/2 : 36
        spinner!.center = CGPoint(x: imagex, y: imagey)
        imageview!.center = spinner!.center
        label!.frame = labelRect
    }
    
    
    func hudPosition(notification:NSNotification?) {
        UIView.animateWithDuration(0.15, delay:0, options:[.AllowUserInteraction, .CurveEaseOut], animations: {
            let screen = UIScreen.mainScreen().bounds
            self.hud.center = CGPointMake(screen.midX, screen.midY)
            }, completion: {
                finished in
        })
        if (background != nil) {
            background!.frame = spinwindow!.frame
        }
    }
    
    func hudShow() {
        hud.alpha = 0
        let screen = UIScreen.mainScreen().bounds
        self.hud.center = CGPointMake(screen.midX, screen.midY)
        hud.transform = CGAffineTransformScale(hud.transform, 1.4, 1.4)
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.AllowUserInteraction, .CurveEaseOut], animations: { () -> Void in
            self.hud.transform = CGAffineTransformScale(self.hud.transform, 1/1.4, 1/1.4)
            self.hud.alpha = 1
            }, completion: {
                finished in
        })
    }
    
    func hudHide() {
        UIView.animateWithDuration(1.5, delay:0, options: [.AllowUserInteraction, .CurveEaseOut], animations: {
            self.hud.transform = CGAffineTransformScale(self.hud.transform, 0.7, 0.7)
            self.hud.alpha = 0
            }, completion: {
                finished in
                self.hudDestroy()
                //self.alpha = 0
        })
    }
    
    func timedHide(string: String?) {
        var length: Double = 1
        if string == nil {
            length = Double(label!.text!.characters.count)
        }
        let sleep = length * 0.04 + 0.5
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(sleep * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            self.hudHide()
        }
    }
    
    func keyboardHeight() -> CGFloat {
        for testWindow in UIApplication.sharedApplication().windows {
            for possibleKeyboard in testWindow.subviews {
                if possibleKeyboard.description.hasPrefix("<UIPeripheralHostView") {
                    return possibleKeyboard.bounds.size.height
                } else if possibleKeyboard.description.hasPrefix("<UIInputSetContainerView") {
                    for hostKeyboard in possibleKeyboard.subviews {
                        if (hostKeyboard.description.hasPrefix("<UIInputSetHost")) {
                            return hostKeyboard.frame.size.height
                        }
                    }
                }
            }
        }
        return 0
    }
    
    func hudMake(string: String?, image:UIImage?, spin:Bool, hide:Bool) {
        label!.text = string
        label!.hidden = (string == nil) ? true : false
        imageview!.image = image
        imageview!.hidden = (image == nil) ? true : false
        if (spin == true) {
            spinner!.startAnimating()
        } else {
            spinner!.stopAnimating()
        }
        self.hudSize()
        self.hudPosition(nil)
        self.hudShow()
        if (hide) {
            timedHide(string)
        }
    }
    
    
}


extension PFUser {
    func Relate() {
        let user: PFUser = PFUser.currentUser()!
        let relation = user.relationForKey("Friends")
        let relation2 = self.relationForKey("Friends")
        print("Added User: \(user.username!)")
        relation.addObject(self)
        relation2.addObject(user)
        self.saveEventually()
        user.saveEventually()
    }
    
    
    func RemoveUser() {
        let user: PFUser = PFUser.currentUser()!
        let relation = user.relationForKey("Friends")
        print("Added User: \(user.username!)")
        relation.removeObject(self)
        user.saveEventually()
    }
}

extension UIView {
    
    public func GradButton(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.startPoint = CGPoint(x: self.bounds.minX, y: self.bounds.minY)
        gradientLayer.endPoint = CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)
        gradientLayer.cornerRadius = 8.0
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func GradLayer(color: UIColor) {
        if self.layer.sublayers!.isEmpty == false {
            for layer in self.layer.sublayers! {
                if layer is CAGradientLayer {
                    layer.removeFromSuperlayer()
                }
            }
        }
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addGradView(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
    
    func addCenteredPFImageView(object: PFObject, circle: Bool) {
        if circle == true {
            let Point: CGPoint = CGPoint(x: 0 - (self.frame.height / 2), y: 0)
            let Size: CGSize = CGSize(width: self.frame.height, height: self.frame.height)
            let ImageRect: CGRect = CGRect(origin: Point, size: Size)
            let GroupImage = PFImageView(frame: ImageRect)
            GroupImage.image = UIImage(named: "profile")
            GroupImage.file = object["Image"] as? PFFile
            GroupImage.layer.cornerRadius = self.frame.height / 2
            GroupImage.layer.masksToBounds = true
            GroupImage.loadInBackground {
                image, error in
                if error != nil {
                    ProgressHUD.showError("Reload Group")
                }
            }
            self.addSubview(GroupImage)
        } else {
            let Point: CGPoint = CGPoint(x: 0 - (self.frame.height / 2), y: 0)
            let Size: CGSize = CGSize(width: self.frame.height, height: self.frame.height)
            let ImageRect: CGRect = CGRect(origin: Point, size: Size)
            let GroupImage = PFImageView(frame: ImageRect)
            GroupImage.image = UIImage(named: "profile")
            GroupImage.file = object["Image"] as? PFFile
            GroupImage.layer.cornerRadius = 8.0
            GroupImage.layer.masksToBounds = true
            GroupImage.loadInBackground {
                image, error in
                if error != nil {
                    ProgressHUD.showError("Reload Group")
                }
            }
            self.addSubview(GroupImage)
        }
    }
    
    
    func addCenteredPFImageViewUser(user: PFUser, circle: Bool) -> PFImageView {
        let sizer = self.bounds.height
        if circle == true {
            let Point: CGPoint = CGPoint(x: self.bounds.midX - (sizer / 2), y: 0)
            let Size: CGSize = CGSize(width: sizer, height: sizer)
            let ImageRect: CGRect = CGRect(origin: Point, size: Size)
            let GroupImage = PFImageView(frame: ImageRect)
            GroupImage.image = UIImage(named: "profile")
            GroupImage.file = user["thumbnail"] as? PFFile
            GroupImage.layer.cornerRadius = sizer / 2
            GroupImage.layer.masksToBounds = true
            GroupImage.loadInBackground {
                image, error in
                if error != nil {
                    ProgressHUD.showError("Reload Group")
                }
            }
            self.addSubview(GroupImage)
            return GroupImage
        } else {
            let Point: CGPoint = CGPoint(x: (sizer / 2), y: 0)
            let Size: CGSize = CGSize(width: sizer, height: sizer)
            let ImageRect: CGRect = CGRect(origin: Point, size: Size)
            let GroupImage = PFImageView(frame: ImageRect)
            GroupImage.image = UIImage(named: "profile")
            GroupImage.file = user["thumbnail"] as? PFFile
            GroupImage.layer.cornerRadius = 8.0
            GroupImage.layer.masksToBounds = true
            GroupImage.loadInBackground {
                image, error in
                if error != nil {
                    ProgressHUD.showError("Reload Group")
                }
            }
            self.addSubview(GroupImage)
            return GroupImage
        }
    }
    
    
    
}


extension UIColor{
    class func colorWithHex(hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var rgb: CUnsignedInt = 0;
        let scanner = NSScanner(string: hex)
        if hex.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        scanner.scanHexInt(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0xFF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

extension NSDate {
    var formatted:String {
        let formatter = NSDateFormatter()
        formatter.AMSymbol = "AM"
        formatter.PMSymbol = "PM"
        let cal: NSCalendar = NSCalendar.currentCalendar()
        
        if cal.isDateInToday(self) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "d/M/yyyy, h:mm a"
        }
        return formatter.stringFromDate(self)
    }
    func formattedWith(format:String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}


extension NSLayoutConstraint {
    
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.active = self.active
        
        NSLayoutConstraint.deactivateConstraints([self])
        NSLayoutConstraint.activateConstraints([newConstraint])
        return newConstraint
    }
}

extension UITextField {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(UITextField.PressedDone))
        doneButton.tintColor = UIColor.blackColor()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    
    func PressedDone() {
        self.resignFirstResponder()
    }
}


extension UITextView {
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(UITextView.PressedDone))
        doneButton.tintColor = UIColor.blackColor()
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    
    func PressedDone() {
        self.resignFirstResponder()
    }
}



extension UIImage {
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    func scaleImage(toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, self.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension SwipedCell {
    func GradLayerTable(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        //let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = self.frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        let color4 = color.lightenedColor(0.7).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1, color4]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 0.98, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
}

extension CommunityCell {
    func GradLayerTable(color: UIColor) {
        let gradientLayer = CAGradientLayer()
        //let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradientLayer.frame = self.frame
        let color1 = color.CGColor as CGColorRef
        let color2 = color.lightenedColor(0.2).CGColor as CGColorRef
        let color3 = color.lightenedColor(0.5).CGColor as CGColorRef
        let color4 = color.lightenedColor(0.7).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color2, color1, color4]
        gradientLayer.locations = [0.0, 0.15, 0.5, 0.85, 0.98, 1.0]
        self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
}

  
