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
    NSURL *result = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];// URLByAppendingPathComponent:@"audeecon"];
    
    return result;
}

+ (NSURL *)filePathInTemporaryDirectoryForFileName:(NSString *)fileName {
    NSURL *result = [[self tempDirectory] URLByAppendingPathComponent:fileName isDirectory:NO];
    return result;
}

+ (NSURL *)filePathInTemporaryDirectoryForRecordedAudio {
    NSURL *result = [self filePathInTemporaryDirectoryForFileName:@"temprecorded.m4a"];
    return result;
}

+ (NSURL *)filePathInTemporaryDirectoryForAvatarImage {
    NSURL *result = [self filePathInTemporaryDirectoryForFileName:@"avatar.jpeg"];
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
