//
//  PQRecordingOverlayView.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVAudioRecorder;
@class PQSticker;

@interface PQRecordingOverlayView : UIView
- (void)configUsingAudioRecorder:(AVAudioRecorder *)recorder;
- (BOOL)cancelViewContainGesture:(UIGestureRecognizer *)gesture;
- (void)animatingUsingSticker:(PQSticker *)sticker;
- (void)stopAnimating;
@end
