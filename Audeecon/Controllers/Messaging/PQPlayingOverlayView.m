//
//  PQPlayingOverlayView.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQPlayingOverlayView.h"
#import "SCSiriWaveformView.h"
#import <AVFoundation/AVFoundation.h>
#import "PQSticker.h"
#import "PQMessage.h"
#import "PQAudioPlayerAndRecorder.h"

@interface PQPlayingOverlayView()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@property (strong, nonatomic) PQAudioPlayerAndRecorder *audioRecorderAndPlayer;
@end

@implementation PQPlayingOverlayView


- (void)configRunLoop {
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)startPlayingUsingSticker:(PQMessage *)message
       andAudioRecorderAndPlayer:(PQAudioPlayerAndRecorder *)audioRecorderAndPlayer
                          onView:(UIView *)view {
    self.audioRecorderAndPlayer = audioRecorderAndPlayer;
    [self.audioRecorderAndPlayer playAudioFileAtUrl:[NSURL fileURLWithPath:message.offlineAudioUri]];
    [message.sticker animateStickerOnImageView:self.mainImage];
    [view addSubview:self];
}

- (void)stop {
    [self.mainImage stopAnimating];
    [self.audioRecorderAndPlayer stopPlaying];
    [self removeFromSuperview];
}

- (void)updateMeters
{
    if  (!self.audioRecorderAndPlayer.player.playing) {
        return;
    }
    CGFloat normalizedValue;
    if (self.audioRecorderAndPlayer.player.playing) {
        [self.audioRecorderAndPlayer.player updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.audioRecorderAndPlayer.player averagePowerForChannel:0]];
    }
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
