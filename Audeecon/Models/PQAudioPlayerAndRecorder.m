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
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

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
        _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    return self;
}

- (void)startRecording {
    if (_player.playing) {
        [_player stop];
    }
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:&error];
    
    // Start recording
    [_recorder record];
}

- (void)stopRecordingAndSaveFileWithInfo:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    
    [_recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)playAudioFileAtUrl:(NSURL *)filePath {
    if (_recorder.recording) {
        return;
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    NSError *error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:&error];
    [_player setDelegate:self];
    [_player play];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
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
