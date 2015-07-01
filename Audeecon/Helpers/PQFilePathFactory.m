//
//  PQFilePathFactory.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQFilePathFactory.h"

@implementation PQFilePathFactory
+ (NSURL *)tempDirectory {
    NSURL *result = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    return result;
}

+ (NSURL *)filePathInTemporaryDirectoryForFileName:(NSString *)fileName {
    NSURL *result = [[self tempDirectory] URLByAppendingPathComponent:fileName isDirectory:NO];
    return result;
}

+ (NSURL *)filePathInTemporaryDirectoryForRecordedAudio {
    /*
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    return outputFileURL; */
    NSURL *result = [self filePathInTemporaryDirectoryForFileName:@"temprecorded.m4a"];
    return result;
}

+ (NSURL *)filePathForFileAfterRenameFileAtPath:(NSURL *)oldFile
                                         toName:(NSString *)newName {
    NSString *extension = [[oldFile lastPathComponent] pathExtension];
    NSURL *newUrl = [[[oldFile URLByDeletingLastPathComponent]
                     URLByAppendingPathComponent:newName]
                     URLByAppendingPathExtension:extension];
    return newUrl;
}
@end
