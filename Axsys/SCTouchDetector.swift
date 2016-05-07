//
//  SCTouchDetector.m
//  SCVideoRecorder
//
//  Created by Simon CORSIN on 8/6/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass
import Foundation


class SCTouchDetector: UIGestureRecognizer {


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.enabled {
            self.state = .Began
        }
    }

    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        if self.enabled {
            self.state = .Ended
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.enabled {
            self.state = .Ended
        }
    }
}
