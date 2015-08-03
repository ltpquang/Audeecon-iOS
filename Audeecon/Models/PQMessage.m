//
//  PQMessage.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessage.h"
#import "PQSticker.h"
#import "DDXML.h"
#import "DDXMLElement.h"
#import "NSXMLElement+XMPP.h"
#import "PQRequestingService.h"
#import <AWSCore.h>
#import <AWSS3.h>
#import "PQUrlService.h"
#import "PQFilePathFactory.h"
#import "PQNotificationNameFactory.h"

@implementation PQMessage

-(id)initWithSticker:(PQSticker *)sticker
   andOnlineAudioUri:(NSString *)onlineAudioUri
       fromJIDString:(NSString *)fromJIDString
         toJIDString:(NSString *)toJIDString
          isOutgoing:(BOOL)isOutgoing {
    if (self = [super init]) {
        _sticker = sticker;
        _onlineAudioUri = onlineAudioUri;
        _fromJIDString = fromJIDString;
        _toJIDString = toJIDString;
        _isOutgoing = isOutgoing;
        _isRead = NO;
    }
    return self;
}

-(id)initWithSticker:(PQSticker *)sticker
  andOfflineAudioUri:(NSString *)offlineAudioUri
       fromJIDString:(NSString *)fromJIDString
         toJIDString:(NSString *)toJIDString
          isOutgoing:(BOOL)isOutgoing {
    if (self = [super init]) {
        _sticker = sticker;
        _offlineAudioUri = offlineAudioUri;
        _fromJIDString = fromJIDString;
        _toJIDString = toJIDString;
        _isOutgoing = isOutgoing;
        _isRead = NO;
    }
    return self;
}

- (void)markAsRead {
    self.isRead = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory messageDidChangeReadStatus:self]
                                                        object:nil];
}

- (void)uploadAudioWithCompletion:(void(^)(BOOL, NSError *))complete {
    if (_offlineAudioUri.length == 0) {
        complete(YES, nil);
    }
    else {
        // Using parse
        /*
        PFFile *file = [PFFile fileWithName:[_offlineAudioUri lastPathComponent] contentsAtPath:_offlineAudioUri];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                _onlineAudioUri = file.url;
            }
            complete(succeeded, error);
        }
                          progressBlock:^(int percentDone) {
                              NSLog(@"%i", percentDone);
                          }];
         */
        
        // Using S3
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = @"audeecon-us";
        uploadRequest.key = [_offlineAudioUri lastPathComponent];
        uploadRequest.body = [NSURL fileURLWithPath:_offlineAudioUri];
        uploadRequest.uploadProgress = ^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
            NSLog(@"%lld - %lld - %lld", bytes, totalBytes, totalBytesExpected);
        };
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"defaulttransfermanager"];
        
        [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                           withBlock:^id(AWSTask *task) {
                                                               if (task.error != nil) {
                                                                   complete(NO, task.error);
                                                               }
                                                               else {
                                                                   _onlineAudioUri = [PQUrlService urlToS3FileWithFileName:[_offlineAudioUri lastPathComponent]];
                                                                   complete(YES, nil);
                                                               }
                                                               return nil;
                                                           }];
    }
}

- (void)downloadAudioUsingRequestingService:(PQRequestingService *)requestingService
                                   complete:(void(^)(NSURL *))complete {
    if (_offlineAudioUri.length != 0) {
        complete([NSURL URLWithString:_offlineAudioUri]);
    } else {
        // Using parse
        /*
        [requestingService downloadAudioFileAtUrl:_onlineAudioUri
                                         complete:^(NSURL *filepath) {
                                             _offlineAudioUri = [filepath absoluteString];
                                             complete(filepath);
                                         }];
         */
        
        // Using S3
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = @"audeecon-us";
        downloadRequest.key = [_onlineAudioUri lastPathComponent];
        downloadRequest.downloadingFileURL = [PQFilePathFactory filePathInTemporaryDirectoryForFileName:[_onlineAudioUri lastPathComponent]];
        downloadRequest.downloadProgress = ^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
            NSLog(@"%lld - %lld - %lld", bytes, totalBytes, totalBytesExpected);
        };
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"defaulttransfermanager"];
        
        [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                               withBlock:^id(AWSTask *task) {
                                                                   if (task.error != nil) {
                                                                       complete(nil);
                                                                   }
                                                                   else {
                                                                       _offlineAudioUri = [downloadRequest.downloadingFileURL path];
                                                                       complete([NSURL URLWithString:_offlineAudioUri]);
                                                                   }
                                                                   return nil;
                                                               }];
    }
}

@end
