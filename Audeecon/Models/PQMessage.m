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
//#import <Parse/Parse.h>
#import "PQRequestingService.h"
#import <AWSCore.h>
#import <AWSS3.h>
#import "PQUrlService.h"
#import "PQFilePathFactory.h"

@implementation PQMessage

- (id)initWithSender:(NSString *)sender
       andStickerUri:(NSString *)stickerUri
  andOfflineAudioUri:(NSString *)offlineAudioUri {
    if (self = [super init]) {
        _sender = sender;
        _stickerUri = stickerUri;
        _offlineAudioUri = offlineAudioUri;
    }
    return self;
}

- (id)initWithXmlElement:(DDXMLElement *)element {
    if (self = [super init]) {
        NSString *body = [[element elementForName:@"body"] stringValue];
        NSString *from = [[element attributeForName:@"from"] stringValue];
        
        _sender = from;
        
        NSArray *arr = [body componentsSeparatedByString:@"|"];
        _stickerUri = arr[0];
        _onlineAudioUri = arr[1];
    }
    return self;
}

- (DDXMLElement *)xmlElementSendTo:(NSString *)toUser {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    NSArray *arr = @[_stickerUri, _onlineAudioUri];
    NSString *bodyString = [arr componentsJoinedByString:@"|"];
    [body setStringValue:bodyString];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:toUser];
    [message addChild:body];
    
    return message;
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
