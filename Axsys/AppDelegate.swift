
import FBSDKCoreKit
import FBSDKLoginKit
import Fabric
import Crashlytics
import Whisper
import CoreLocation
import MapKit
import ParseUI
import Parse
import ParseFacebookUtilsV4
import SwiftLocation

var groupPass: String?

var recordSession: SCRecordSession?

let googleMapKey = "AIzaSyD1il3GHy39sR9si5bHGIHHmoDSLIeHHdY"

let defaults = NSUserDefaults.standardUserDefaults()


var disabled = false

let facebookLogin = FBSDKLoginManager()

var myGroup: PFObject?

var chatTitle: String?

var groupProfile: PFObject?

var profileUser: PFUser?



var buckheadCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.795714,longitude: -84.393196), CLLocationCoordinate2D(latitude: 33.802989,longitude: -84.384613), CLLocationCoordinate2D(latitude: 33.811119,longitude: -84.371481), CLLocationCoordinate2D(latitude: 33.817038,longitude: -84.361181),  CLLocationCoordinate2D(latitude: 33.82481,longitude: -84.349594), CLLocationCoordinate2D(latitude: 33.830015,longitude: -84.339123),  CLLocationCoordinate2D(latitude: 33.842064,longitude: -84.33629), CLLocationCoordinate2D(latitude: 33.849834,longitude: -84.33672), CLLocationCoordinate2D(latitude: 33.875278,longitude: -84.346504),    CLLocationCoordinate2D(latitude: 33.882974,longitude: -84.351912),   CLLocationCoordinate2D(latitude: 33.88447,longitude: -84.364872),  CLLocationCoordinate2D(latitude: 33.882832,longitude: -84.382982),  CLLocationCoordinate2D(latitude: 33.889244,longitude: -84.397659),    CLLocationCoordinate2D(latitude: 33.886537,longitude: -84.417229), CLLocationCoordinate2D(latitude: 33.87763,longitude: -84.433022), CLLocationCoordinate2D(latitude: 33.874209,longitude: -84.44787), CLLocationCoordinate2D(latitude: 33.867154,longitude: -84.453535),  CLLocationCoordinate2D(latitude: 33.858245,longitude: -84.454565), CLLocationCoordinate2D(latitude: 33.852258,longitude: -84.460316),CLLocationCoordinate2D(latitude: 33.846341,longitude: -84.458599),CLLocationCoordinate2D(latitude: 33.838214,longitude: -84.460316), CLLocationCoordinate2D(latitude: 33.831085,longitude: -84.456282),  CLLocationCoordinate2D(latitude: 33.825666,longitude: -84.441175),CLLocationCoordinate2D(latitude: 33.815683,longitude: -84.436712),CLLocationCoordinate2D(latitude: 33.809621,longitude: -84.431391), CLLocationCoordinate2D(latitude: 33.802489,longitude: -84.429073), CLLocationCoordinate2D(latitude: 33.79443,longitude: -84.425554),CLLocationCoordinate2D(latitude: 33.792789,longitude: -84.418516), CLLocationCoordinate2D(latitude: 33.79821,longitude: -84.414997),  CLLocationCoordinate2D(latitude: 33.804201,longitude: -84.413366), CLLocationCoordinate2D(latitude: 33.802989,longitude: -84.407959), CLLocationCoordinate2D(latitude: 33.801705,longitude: -84.403582), CLLocationCoordinate2D(latitude: 33.800564,longitude: -84.398603), CLLocationCoordinate2D(latitude: 33.795714,longitude: -84.393196)]

var midtownCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.771102,longitude: -84.390278),
                                               CLLocationCoordinate2D(latitude: 33.787083,longitude: -84.391479),
                                               CLLocationCoordinate2D(latitude: 33.795928,longitude: -84.393711),
                                               CLLocationCoordinate2D(latitude: 33.799851,longitude: -84.39105),
                                               CLLocationCoordinate2D(latitude: 33.801562,longitude: -84.38736),
                                               CLLocationCoordinate2D(latitude: 33.800065,longitude: -84.386415),
                                               CLLocationCoordinate2D(latitude: 33.798353,longitude: -84.385214),
                                               CLLocationCoordinate2D(latitude: 33.796498,longitude: -84.38796),
                                               CLLocationCoordinate2D(latitude: 33.796356,longitude: -84.38633),
                                               CLLocationCoordinate2D(latitude: 33.789223,longitude: -84.380493),
                                               CLLocationCoordinate2D(latitude: 33.787939,longitude: -84.377832),
                                               CLLocationCoordinate2D(latitude: 33.782089,longitude: -84.379206),
                                               CLLocationCoordinate2D(latitude: 33.781875,longitude: -84.36882),
                                               CLLocationCoordinate2D(latitude: 33.77788,longitude: -84.366159),
                                               CLLocationCoordinate2D(latitude: 33.773599,longitude: -84.364529),
                                               CLLocationCoordinate2D(latitude: 33.773813,longitude: -84.36985),
                                               CLLocationCoordinate2D(latitude: 33.772386,longitude: -84.375429),
                                               CLLocationCoordinate2D(latitude: 33.772529,longitude: -84.382296),
                                               CLLocationCoordinate2D(latitude: 33.771102,longitude: -84.390278)]

var highlandCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.790578,longitude: -84.367189),
                                                CLLocationCoordinate2D(latitude: 33.79229,longitude: -84.366674),
                                                CLLocationCoordinate2D(latitude: 33.796855,longitude: -84.368906),
                                                CLLocationCoordinate2D(latitude: 33.792433,longitude: -84.373112),
                                                CLLocationCoordinate2D(latitude: 33.787297,longitude: -84.378004),
                                                CLLocationCoordinate2D(latitude: 33.781946,longitude: -84.380236),
                                                CLLocationCoordinate2D(latitude: 33.781875,longitude: -84.368477),
                                                CLLocationCoordinate2D(latitude: 33.779021,longitude: -84.366417),
                                                CLLocationCoordinate2D(latitude: 33.773385,longitude: -84.3647),
                                                CLLocationCoordinate2D(latitude: 33.772957,longitude: -84.36058),
                                                CLLocationCoordinate2D(latitude: 33.772386,longitude: -84.352255),
                                                CLLocationCoordinate2D(latitude: 33.773813,longitude: -84.347448),
                                                CLLocationCoordinate2D(latitude: 33.778665,longitude: -84.344015),
                                                CLLocationCoordinate2D(latitude: 33.784728,longitude: -84.340496),
                                                CLLocationCoordinate2D(latitude: 33.789579,longitude: -84.349422),
                                                CLLocationCoordinate2D(latitude: 33.789936,longitude: -84.358177),
                                                CLLocationCoordinate2D(latitude: 33.789579,longitude: -84.363499)]

var emoryCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.803719,longitude: -84.338264),
                   CLLocationCoordinate2D(latitude: 33.808854,longitude: -84.324188),
                   CLLocationCoordinate2D(latitude: 33.80757,longitude: -84.300842),
                   CLLocationCoordinate2D(latitude: 33.791736,longitude: -84.303074),
                   CLLocationCoordinate2D(latitude: 33.786743,longitude: -84.328995),
                   CLLocationCoordinate2D(latitude: 33.803719,longitude: -84.338264)]

var eastCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.74556,longitude: -84.349458),
                  CLLocationCoordinate2D(latitude: 33.74035,longitude: -84.35023),
                  CLLocationCoordinate2D(latitude: 33.724004,longitude: -84.350745),
                  CLLocationCoordinate2D(latitude: 33.719149,longitude: -84.330146),
                  CLLocationCoordinate2D(latitude: 33.723718,longitude: -84.317185),
                  CLLocationCoordinate2D(latitude: 33.735568,longitude: -84.323794),
                  CLLocationCoordinate2D(latitude: 33.744275,longitude: -84.332892)]

var downtownCoords: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 33.7703,longitude: -84.404674),
                     CLLocationCoordinate2D(latitude: 33.766519,longitude: -84.404846),
                     CLLocationCoordinate2D(latitude: 33.76288,longitude: -84.406047),
                     CLLocationCoordinate2D(latitude: 33.758456,longitude: -84.406305),
                     CLLocationCoordinate2D(latitude: 33.754174,longitude: -84.406477),
                     CLLocationCoordinate2D(latitude: 33.74964,longitude: -84.404869),
                     CLLocationCoordinate2D(latitude: 33.746895,longitude: -84.398924),
                     CLLocationCoordinate2D(latitude: 33.74561,longitude: -84.39446),
                     CLLocationCoordinate2D(latitude: 33.743683,longitude: -84.39446),
                     CLLocationCoordinate2D(latitude: 33.740828,longitude: -84.394889),
                     CLLocationCoordinate2D(latitude: 33.737045,longitude: -84.395147),
                     CLLocationCoordinate2D(latitude: 33.732977,longitude: -84.394289),
                     CLLocationCoordinate2D(latitude: 33.730835,longitude: -84.39137),
                     CLLocationCoordinate2D(latitude: 33.731549,longitude: -84.38665),
                     CLLocationCoordinate2D(latitude: 33.733476,longitude: -84.381328),
                     CLLocationCoordinate2D(latitude: 33.738116,longitude: -84.380813),
                     CLLocationCoordinate2D(latitude: 33.746324,longitude: -84.380985),
                     CLLocationCoordinate2D(latitude: 33.747466,longitude: -84.377981),
                     CLLocationCoordinate2D(latitude: 33.750035,longitude: -84.373603),
                     CLLocationCoordinate2D(latitude: 33.754602,longitude: -84.366565),
                     CLLocationCoordinate2D(latitude: 33.758812,longitude: -84.365106),
                     CLLocationCoordinate2D(latitude: 33.76288,longitude: -84.360386),
                     CLLocationCoordinate2D(latitude: 33.769176,longitude: -84.358864),
                     CLLocationCoordinate2D(latitude: 33.772957,longitude: -84.36058),
                     CLLocationCoordinate2D(latitude: 33.773385,longitude: -84.3647),
                     CLLocationCoordinate2D(latitude: 33.77401,longitude: -84.369913),
                     CLLocationCoordinate2D(latitude: 33.772155,longitude: -84.375663),
                     CLLocationCoordinate2D(latitude: 33.772369,longitude: -84.382959),
                     CLLocationCoordinate2D(latitude: 33.771156,longitude: -84.388452),
                     CLLocationCoordinate2D(latitude: 33.771299,longitude: -84.396263),
                     CLLocationCoordinate2D(latitude: 33.771156,longitude: -84.398774)]


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    var window: UIWindow?
    var shortcutItem: UIApplicationShortcutItem?
    var devicePushToken: NSData!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        Parse.enableLocalDatastore()
        Parse.setApplicationId("z2LBH5SF7I44efdLh9HslQPknL8pKvRFhQDtS7cS", clientKey: "u7rvYJ0QFNEwDpiKVLMLurwCEarARVeayvMxJNy0")
        Fabric.with([Crashlytics.self])
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if PFUser.currentUser() != nil {
            LocationManager.shared.observeLocations(.Block, frequency: .OneShot, onSuccess: { location in
                let location = location.coordinate
                if PFUser.currentUser()!["CurrentGroup"] != nil {
                    myGroup = PFUser.currentUser()!["CurrentGroup"] as? PFObject
                    if myGroup != nil {
                        let groupQuery = PFQuery(className: "Group")
                        groupQuery.getObjectInBackgroundWithId((myGroup?.objectId)!, block: {
                            group, error in
                            if error == nil {
                                let groupUser = group!["Creator"] as? PFUser
                                if PFUser.currentUser() == groupUser! {
                                    let newGeoPoint: PFGeoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                                    myGroup?["Location"] = newGeoPoint
                                    myGroup?.saveInBackground()
                                }
                            }
                        })
                    }
                }
            }) {error in}
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginSignupVC") as! UINavigationController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            var performShortcutDelegate = true
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                self.shortcutItem = shortcutItem
                performShortcutDelegate = false
            } else {
                return performShortcutDelegate
            }
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("LoginVCNav") as! UINavigationController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    /*
    func igLocationManager(manager: IGLocationManager!, didUpdateLocation igLocation: IGLocation!) {
        print("Location \(igLocation)")
        myGroup = PFUser.currentUser()!["CurrentGroup"] as? PFObject
        if myGroup != nil {
            let groupQuery = PFQuery(className: "Group")
            groupQuery.getObjectInBackgroundWithId((myGroup?.objectId)!, block: {
                group, error in
                if error == nil {
                    let groupUser = group!["Creator"] as? PFUser
                    if PFUser.currentUser() == groupUser! {
                        let newGeoPoint: PFGeoPoint = PFGeoPoint(latitude: igLocation.latitude, longitude: igLocation.longitude)
                        myGroup?["Location"] = newGeoPoint
                        myGroup?.saveInBackground()
                    }
                }
            })
            
        }
    }
    
    func igLocationManager(manager: IGLocationManager!, didExitRegion region: IGRegion!) {
        print("Exited \(region)")
    }
    
    func igLocationManager(manager: IGLocationManager!, didEnterRegion region: IGRegion!) {
        print("Enter \(region)")
    }
    
    func igLocationManager(manager: IGLocationManager!, didDetectMotionState motionState: IGMotionState) {
        print("Detected Motion State:\(motionState)")
    }
    */
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation["User"] = PFUser.currentUser()
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFail! with error: \(error)")
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
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        handePush(userInfo)
        
    }
    
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.badge = 0
        currentInstallation.saveEventually()
        
        
        print("Application did become active")
        
        guard let shortcut = shortcutItem else { return }
        
        print("- Shortcut property has been set")
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil
        
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(.NewData)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        if let VC = self.window!.rootViewController {
            let controllers = VC.childViewControllers
            for control in controllers {
                if control is MessagesViewController {
                    if control.isViewLoaded() == true {
                        let tableLoad = (control as! MessagesViewController)
                        NSNotificationCenter.defaultCenter().postNotificationName("LoadMessages", object: tableLoad)
                    }
                }
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        //PFUser.logOut()
    }
    
    
    func handleShortcut( shortcutItem:UIApplicationShortcutItem ) -> Bool {
        print("Handling shortcut")
        
        var succeeded = false
        
        if( shortcutItem.type == "be.thenerd.appshortcut.new-user" ) {
            
            // Add your code here
            print("- Handling \(shortcutItem.type)")
            
            succeeded = true
            
        }
        
        return succeeded
        
    }
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        print("Application performActionForShortcutItem")
        completionHandler( handleShortcut(shortcutItem) )
        
    }
    
    func handePush(dict: NSDictionary) {
        let ap = (dict["aps"] as? NSDictionary)!
        let type: String = (dict["type"] as? String)!
        let objID: String = (dict["ObjID"] as? String)!
        let alertMessage: String = (ap["alert"] as? String)!
        if let wd = self.window {
            var vc = wd.rootViewController
            if(vc is UINavigationController){
                vc = (vc as! UINavigationController).visibleViewController
                if type == "chat" {
                    groupPass = (dict["messageID"] as? String)!
                    let userQuerying = PFUser.query()
                    userQuerying?.getObjectInBackgroundWithId(objID, block: {
                        user, error in
                        if error == nil {
                            let thisUser: PFUser = user as! PFUser
                            let userImageView : PFImageView = PFImageView()
                            userImageView.file = thisUser[PF_USER_PICTURE] as? PFFile
                            userImageView.loadInBackground {
                                image, error in
                                if error != nil {
                                    
                                } else {
                                    let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
                                    if (types == UIUserNotificationType.None) {
                                    } else {
                                        if (types == [.Alert, .Badge]) {
                                        } else if (types == .Alert) {
                                        } else if (types == .Badge) {
                                        } else {
                                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                        }
                                    }
                                    let announcement = Announcement(title: "SkyeLync", subtitle: alertMessage, image: image, action: {
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("ChatControl") as! UINavigationController
                                        vc?.presentViewController(initialViewController, animated: true, completion: nil)
                                        return
                                    })
                                    Shout(announcement, to: vc!)
                                }
                            }
                        }
                    })
                } else if type == "friendAccepted" {
                    if vc is FriendsTable {
                        let reloadVC: FriendsTable = (vc as? FriendsTable)!
                        reloadVC.tableView.reloadData()
                    }
                    let userQuerying = PFUser.query()
                    userQuerying?.getObjectInBackgroundWithId(objID, block: {
                        user, error in
                        if error == nil {
                            let thisUser: PFUser = user as! PFUser
                            let userImageView : PFImageView = PFImageView()
                            userImageView.file = thisUser[PF_USER_PICTURE] as? PFFile
                            userImageView.loadInBackground {
                                image, error in
                                if error != nil {
                                    
                                } else {
                                    let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
                                    if (types == UIUserNotificationType.None) {
                                    } else {
                                        if (types == [.Alert, .Badge]) {
                                        } else if (types == .Alert) {
                                        } else if (types == .Badge) {
                                        } else {
                                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                        }
                                    }
                                    let announcement = Announcement(title: "SkyeLync", subtitle: alertMessage, image: image, action: {
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Friends") as! FriendsTable
                                        vc?.presentViewController(initialViewController, animated: true, completion: nil)
                                        return
                                    })
                                    Shout(announcement, to: vc!)
                                }
                            }
                        }
                    })
                } else if type == "friendInvite" {
                    let userQuerying = PFUser.query()
                    userQuerying?.getObjectInBackgroundWithId(objID, block: {
                        user, error in
                        if error == nil {
                            let thisUser: PFUser = user as! PFUser
                            let userImageView : PFImageView = PFImageView()
                            userImageView.file = thisUser[PF_USER_PICTURE] as? PFFile
                            userImageView.loadInBackground {
                                image, error in
                                if error != nil {
                                    
                                } else {
                                    let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
                                    if (types == UIUserNotificationType.None) {
                                    } else {
                                        if (types == [.Alert, .Badge]) {
                                        } else if (types == .Alert) {
                                        } else if (types == .Badge) {
                                        } else {
                                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                        }
                                    }
                                    let announcement = Announcement(title: "SkyeLync", subtitle: alertMessage, image: image, action: {
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Friends") as! FriendsTable
                                        vc?.presentViewController(initialViewController, animated: true, completion: nil)
                                        self.createFriend(thisUser)
                                        let push = PFPush()
                                        let data = [
                                            "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) accepted your friend request",
                                            "badge" : "Increment",
                                            "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                                            "type" : "friendAccepted"
                                        ]
                                        let installQuery = PFInstallation.query()
                                        installQuery?.whereKey("User", equalTo: user!)
                                        push.setQuery(installQuery)
                                        push.setData(data)
                                        push.sendPushInBackground()
                                        return
                                    })
                                    Shout(announcement, to: vc!)
                                }
                            }
                        }
                    })
                    if vc is InviteTable {
                        let reloadVC: InviteTable = (vc as? InviteTable)!
                        reloadVC.tableView.reloadData()
                    }
                } else if type == "groupInvite" {
                    if vc is GroupsTable {
                        let reloadVC: GroupsTable = (vc as? GroupsTable)!
                        reloadVC.tableView.reloadData()
                    }
                    groupPass = (dict["groupID"] as? String)!
                    let userQuerying = PFUser.query()
                    userQuerying?.getObjectInBackgroundWithId(objID, block: {
                        user, error in
                        if error == nil {
                            let thisUser: PFUser = user as! PFUser
                            let userImageView : PFImageView = PFImageView()
                            userImageView.file = thisUser[PF_USER_PICTURE] as? PFFile
                            userImageView.loadInBackground {
                                image, error in
                                if error != nil {
                                    
                                } else {
                                    let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
                                    if (types == UIUserNotificationType.None) {
                                    } else {
                                        if (types == [.Alert, .Badge]) {
                                        } else if (types == .Alert) {
                                        } else if (types == .Badge) {
                                        } else {
                                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                        }
                                    }
                                    let announcement = Announcement(title: "SkyeLync", subtitle: alertMessage, image: image, action: {
                                        self.addToGroup(groupPass!)
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Groups") as! GroupsTable
                                        vc?.presentViewController(initialViewController, animated: true, completion: nil)
                                        let push = PFPush()
                                        let data = [
                                            "alert" : "\((PFUser.currentUser()?["fullname"])! as! String) accepted your group request",
                                            "badge" : "Increment",
                                            "groupID" : groupPass! as String,
                                            "ObjID" : (PFUser.currentUser()?.objectId!)! as String,
                                            "type" : "groupAccepted"
                                        ]
                                        let installQuery = PFInstallation.query()
                                        installQuery?.whereKey("User", equalTo: user!)
                                        push.setQuery(installQuery)
                                        push.setData(data)
                                        push.sendPushInBackground()
                                        return
                                    })
                                    Shout(announcement, to: vc!)
                                }
                            }
                            
                        }
                    })
                } else if type == "groupAccepted" {
                    groupPass = (dict["groupID"] as? String)!
                    let userQuerying = PFUser.query()
                    userQuerying?.getObjectInBackgroundWithId(objID, block: {
                        user, error in
                        if error == nil {
                            let thisUser: PFUser = user as! PFUser
                            let userImageView : PFImageView = PFImageView()
                            userImageView.file = thisUser[PF_USER_PICTURE] as? PFFile
                            userImageView.loadInBackground {
                                image, error in
                                if error != nil {
                                    
                                } else {
                                    let types = UIApplication.sharedApplication().currentUserNotificationSettings()!.types
                                    if (types == UIUserNotificationType.None) {
                                    } else {
                                        if (types == [.Alert, .Badge]) {
                                        } else if (types == .Alert) {
                                        } else if (types == .Badge) {
                                        } else {
                                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                        }
                                    }
                                    let announcement = Announcement(title: "SkyeLync", subtitle: alertMessage, image: image, action: {
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let initialViewController = storyboard.instantiateViewControllerWithIdentifier("Groups") as! GroupsTable
                                        vc?.presentViewController(initialViewController, animated: true, completion: nil)
                                        return
                                    })
                                    Shout(announcement, to: vc!)
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    func addToGroup(groupID: String) {
        let query = PFQuery(className: "Group")
        query.getObjectInBackgroundWithId(groupID, block: ({
            group, error in
            if error == nil {
                var users: [String] = group!["Users"] as! [String]
                users.append((PFUser.currentUser()?.objectId!)! as String)
                group?["Users"] = users
                PFUser.currentUser()!["CurrentGroup"] = group
                PFUser.currentUser()!.saveInBackground()
                group?.saveInBackground()
            }
        }))
    }
    
}
