//
//  PQAudioRecorder.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/29/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQAudioPlayerAndRecorder.h"
#import "PQFilePathFactory.h"
#import "SCSiriWaveformView.h"

@interface PQAudioPlayerAndRecorder()
@property (nonatomic, weak) id<PQAudioPlayerAndRecorderDelegate> delegate;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSDictionary *infoDict;

@property (nonatomic, strong) SCSiriWaveformView *waveformView;
@property (nonatomic, strong) CADisplayLink *displaylink;
@end

@implementation PQAudioPlayerAndRecorder
- (id)initWithDelegate:(id<PQAudioPlayerAndRecorderDelegate>)delegate
       andWaveformView:(SCSiriWaveformView *)waveformView {
    if (self = [super init]) {
        _delegate = delegate;
        _waveformView = waveformView;
        
        NSURL *outputFileURL = [PQFilePathFactory filePathInTemporaryDirectoryForRecordedAudio];
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        NSError *error1 = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error1];
        _recorder.delegate = self;
        
        self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)updateMeters
{
    if  (!self.recorder.recording && !self.player.playing) {
        return;
    }
    CGFloat normalizedValue;
    if ([self.recorder isRecording]) {
        [self.recorder updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
    }
    else if (self.player.playing) {
        [self.player updateMeters];
        normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.player averagePowerForChannel:0]];
    }
    [self.waveformView updateWithLevel:normalizedValue];
    NSLog(@"%f", normalizedValue);
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

- (void)startRecording {
    if ([self.player isPlaying]) {
        [self.player stop];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:&error];
    
    
    
    //[self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    // Start recording
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
}

- (void)stopRecordingAndSaveFileWithInfo:(NSDictionary *)infoDict {
    self.infoDict = infoDict;
    
    [self.recorder stop];
    //[self.displaylink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)playAudioFileAtUrl:(NSURL *)filePath {
    if ([self.recorder isRecording]) {
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    [self.player setDelegate:self];
    [self.player prepareToPlay];
    [self.player setMeteringEnabled:YES];
    [self.player play];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        BOOL isCanceled = [(NSNumber *)self.infoDict[@"isCanceled"] boolValue];
        if (isCanceled) {
            NSLog(@"Canceled");
            [[NSFileManager new] removeItemAtURL:recorder.url error:nil];
            return;
        }
        NSString *from = [_infoDict objectForKey:@"from"];
        NSString *to = [_infoDict objectForKey:@"to"];
        NSString *timestamp = [_infoDict objectForKey:@"timestamp"];
        NSArray *array = @[from, to, timestamp];
        NSString *newName = [array componentsJoinedByString:@"_"];
        
        NSURL *newUrl = [PQFilePathFactory filePathForFileAfterRenameFileAtPath:recorder.url toName:newName];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:[recorder.url path]]) {
            NSError *error = nil;
            [manager moveItemAtPath:[recorder.url path] toPath:[newUrl path] error:&error];
            if (error) {
                NSLog(@"There is an Error: %@", error);
            }
            
            [_delegate didFinishRecordingAndSaveToFileAtUrl:newUrl];
        } else {
            NSLog(@"File doesn't exists");
        }
        
    }
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder {
    NSLog(@"begin interruption");
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags {
    NSLog(@"end interruption");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"encode error");
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_delegate didFinishPlaying];
}
@end
