//
//  SCSessionListViewController.m
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 14/08/14.
//
//


/*

import SCRecorder
import Foundation



class SCSessionListController : UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var recorder: SCRecorder!
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save current", style: .Bordered, target: self, action: "saveCurrentRecordSession")
        // Do any additional setup after loading the view.
    }

    func saveCurrentRecordSession() {
        SCRecordSessionManager.sharedInstance().saveRecordSession(recorder.session)
        self.tableView.reloadData()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if recorder.session!.segments.count > 0 {
            SCRecordSessionManager.sharedInstance().saveRecordSession(recorder.session)
        }
        var recordSessionMetadata: [NSObject : AnyObject] = SCRecordSessionManager.sharedInstance().savedRecordSessions() as! [NSObject : AnyObject]
        var newRecordSession: SCRecordSession = SCRecordSession(recordSessionMetadata)
        self.recorder.session = newRecordSession
        self.navigationController!.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SCTableCell = (tableView.dequeueReusableCellWithIdentifier("Session") as? SCTableCell)!
        let sessionList = SCRecordSessionManager.sharedInstance().savedRecordSessions()
        var recordSession: [NSObject : AnyObject] = sessionList[indexPath.row] as! [NSObject : AnyObject]
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        let text = recordSession[SCRecordSessionDateKey]
        cell.dateLabel.text = formatter.stringFromDate(NSDate())
        if let recordSegments: [NSObject : AnyObject] = (recordSession[SCRecordSessionSegmentsKey] as? [NSObject : AnyObject])! {
            cell.segmentsCountLabel.text = "\(Int(recordSegments.count)) segments"
            cell.durationLabel.text = "\(recordSession[SCRecordSessionDurationKey)!)"
            if recordSegments.count > 0 {
                if var dictRepresentation: [NSObject : AnyObject] = (recordSegments.first as?  [NSObject : AnyObject])! {
                    var directory: String = (recordSession[SCRecordSessionDirectoryKey] as? String)!
                    var segment: SCRecordSessionSegment = SCRecordSessionSegment(dictionaryRepresentation: dictRepresentation, directory: directory)!
                    cell.videoPlayerView.player!.setItemByAsset(segment.asset)
                }
            }
        }
        return cell
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var recordSession: [NSObject : AnyObject] = (SCRecordSessionManager.sharedInstance().savedRecordSessions()[indexPath.row] as?  [NSObject : AnyObject])!
        var urls: [String] = (recordSession[SCRecordSessionSegmentFilenamesKey] as?  [String])!
        var manager: NSFileManager = NSFileManager.defaultManager()
        for path: String in urls {
            do{
                try manager.removeItemAtPath(path)
            } catch {
                
            }
        }
        SCRecordSessionManager.sharedInstance().removeRecordSessionAtIndex(indexPath.row)
        if (recorder.session!.identifier == (recordSession[SCRecordSessionIdentifierKey] as! String)) {
            self.recorder.session = nil
        }
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SCRecordSessionManager.sharedInstance().savedRecordSessions().count
    }
    
    
    
}

*/