//
//  PQPlayingOverlayView.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  AVAudioPlayer;
@class PQMessage;
@class PQAudioPlayerAndRecorder;

@interface PQPlayingOverlayView : UIView
- (void)configRunLoop;
- (void)startPlayingUsingSticker:(PQMessage *)message
       andAudioRecorderAndPlayer:(PQAudioPlayerAndRecorder *)audioRecorderAndPlayer
                          onView:(UIView *)view;
- (void)stop;
@end
