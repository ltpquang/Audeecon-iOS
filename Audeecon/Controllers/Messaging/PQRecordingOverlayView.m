//
//  PQRecordingOverlayView.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQRecordingOverlayView.h"
#import "SCSiriWaveformView.h"
#import "PQSticker.h"
#import <AVFoundation/AVFoundation.h>

@interface PQRecordingOverlayView()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@end

@implementation PQRecordingOverlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)configUsingAudioRecorder:(AVAudioRecorder *)recorder {
    _recorder = recorder;
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateMeters
{
    if  (!self.recorder.recording) {
        return;
    }
    CGFloat normalizedValue;
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
    }
//    else if (self.player.playing) {
//        [self.player updateMeters];
//        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.player averagePowerForChannel:0]];
//    }
    [self.waveformView updateWithLevel:normalizedValue];
    //NSLog(@"%f", normalizedValue);
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

- (BOOL)cancelViewContainGesture:(UIGestureRecognizer *)gesture {
    return CGRectContainsPoint(self.cancelView.bounds, [gesture locationInView:self.cancelView])
    || CGRectContainsPoint(self.mainImage.bounds, [gesture locationInView:self.mainImage])
    || CGRectContainsPoint(self.waveformView.bounds, [gesture locationInView:self.waveformView])
    ? YES : NO;
}

- (void)animatingUsingSticker:(PQSticker *)sticker {
    [sticker animateStickerOnImageView:self.mainImage];
    [sticker freeUpSticker];
}

- (void)stopAnimating {
    [self.mainImage stopAnimating];
    self.mainImage.animationImages = nil;
}

@end
