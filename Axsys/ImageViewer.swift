//
//  ImageViewer.swift
//  RPSavvy
//
//  Created by Dillon Murphy on 3/19/16.
//  Copyright © 2016 StrategynMobilePros. All rights reserved.
//

import UIKit
import Foundation


class ImageViewer: UIViewController {
    
    var ImageViewer2: UIImageView!
    
    
    override func viewDidLoad() {
        ImageViewer2.frame = self.view.bounds
        ImageViewer2.contentMode = .ScaleAspectFit
        ImageViewer2.backgroundColor = UIColor.blackColor()
        self.view.addSubview(ImageViewer2)
        /*let newButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(ImageViewer.leave(_:)))
         newButton.tintColor = UIColor.whiteColor()
         self.navigationItem.setRightBarButtonItem(newButton, animated: false)*/
    }
    
    func leave(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("leaveImage", sender: nil)
    }
    
    func addImage(image: UIImage, frame: CGRect) {
        let ImageViewer: UIImageView = UIImageView(image: image)
        ImageViewer.frame = frame
        ImageViewer.contentMode = .ScaleAspectFit
        ImageViewer.backgroundColor = UIColor.blackColor()
        self.view.addSubview(ImageViewer)
    }
    
}