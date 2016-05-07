//
//  SCSessionTableViewCell.h
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 14/08/14.
//
//
import UIKit

class SCTableCell: UITableViewCell {
    
    
    @IBOutlet weak var videoPlayerView: SCVideoPlayerView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var segmentsCountLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
}