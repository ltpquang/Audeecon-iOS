//
//  PQAudioRecorder.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/29/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQAudioPlayerAndRecorder.h"
#import "PQFilePathFactory.h"

@interface PQAudioPlayerAndRecorder()
@property (nonatomic, weak) id<PQAudioPlayerAndRecorderDelegate> delegate;

@property (nonatomic, strong) NSDictionary *infoDict;

@end

@implementation PQAudioPlayerAndRecorder
- (id)initWithDelegate:(id<PQAudioPlayerAndRecorderDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        
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
        
    }
    return self;
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

- (void)stopPlaying {
    [self.player stop];
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
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    AVAudioSession *playbackSession = [AVAudioSession sharedInstance];
    [playbackSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [playbackSession setActive:YES error:nil];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    [self.player setDelegate:self];
    [self.player setVolume:1.0];
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
