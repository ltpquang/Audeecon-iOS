//
//  PQFilePathFactory.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/30/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQFilePathFactory : NSObject
+ (NSURL *)tempDirectory;
+ (NSURL *)filePathInTemporaryDirectoryForFileName:(NSString *)fileName;
+ (NSURL *)filePathInTemporaryDirectoryForRecordedAudio;
+ (NSURL *)filePathInTemporaryDirectoryForAvatarImage;
+ (NSURL *)filePathForFileAfterRenameFileAtPath:(NSURL *)oldFile
                                         toName:(NSString *)newName;
@end
