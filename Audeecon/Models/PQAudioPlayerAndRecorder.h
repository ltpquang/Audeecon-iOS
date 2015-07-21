//
//  PQAudioRecorder.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/29/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@class SCSiriWaveformView;

@protocol PQAudioPlayerAndRecorderDelegate;

@interface PQAudioPlayerAndRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

- (id)initWithDelegate:(id<PQAudioPlayerAndRecorderDelegate>)delegate;
- (void)startRecording;
- (void)stopRecordingAndSaveFileWithInfo:(NSDictionary *)infoDict;
- (void)stopPlaying;
- (void)playAudioFileAtUrl:(NSURL *)filePath;
@end


@protocol PQAudioPlayerAndRecorderDelegate <NSObject>
- (void)didFinishRecordingAndSaveToFileAtUrl:(NSURL *)savedFile;
- (void)didFinishPlaying;
@end