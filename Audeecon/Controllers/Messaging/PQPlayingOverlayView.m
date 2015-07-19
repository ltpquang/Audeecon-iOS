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

@interface PQPlayingOverlayView()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@property (strong, nonatomic) AVAudioPlayer *player;
@end

@implementation PQPlayingOverlayView


- (void)configUsingAudioPlayer:(AVAudioPlayer *)player {
    _player = player;
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateMeters
{
    if  (!self.player.playing) {
        return;
    }
    CGFloat normalizedValue;
    if (self.player.playing) {
        [self.player updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.player averagePowerForChannel:0]];
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
