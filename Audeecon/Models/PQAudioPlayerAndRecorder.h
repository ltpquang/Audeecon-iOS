//
//  PQAudioRecorder.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/29/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol PQAudioPlayerAndRecorderDelegate;

@interface PQAudioPlayerAndRecorder : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
- (id)initWithDelegate:(id<PQAudioPlayerAndRecorderDelegate>)delegate;
- (void)startRecording;
- (void)stopRecordingAndSaveFileWithInfo:(NSDictionary *)infoDict;
- (void)playAudioFileAtUrl:(NSURL *)filePath;
@end


@protocol PQAudioPlayerAndRecorderDelegate <NSObject>
- (void)didFinishRecordingAndSaveToFileAtUrl:(NSURL *)savedFile;
- (void)didFinishPlaying;
@end