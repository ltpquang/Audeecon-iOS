//
//  PQStickerDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerImagesDownloadOperation.h"
#import "PQSticker.h"
#import <AFNetworking.h>
#import "PQImageUriToDataDownloadOperation.h"
#import "PQNotificationNameFactory.h"

@interface PQStickerImagesDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQSticker *sticker;
@property (weak) id<PQStickerImagesDownloadOperationDelegate> delegate;
@property NSOperationQueue *queue;
@property NSOperationQueue *downloadQueue;
@end

@implementation PQStickerImagesDownloadOperation
- (id)initWithSticker:(PQSticker *)sticker
             andQueue:(NSOperationQueue *)queue
     andDownloadQueue:downloadQueue
             delegate:(id<PQStickerImagesDownloadOperationDelegate>)delegate {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _sticker = sticker;
        _queue = queue;
        _downloadQueue = downloadQueue;
        _delegate = delegate;
    }
    return self;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    //self.queue = [NSOperationQueue new];
    //self.queue.maxConcurrentOperationCount = 5;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PQImageUriToDataDownloadOperation *thumbnailDownloadOperation = [[PQImageUriToDataDownloadOperation alloc]
                                                                         initWithUri:self.sticker.thumbnailUri
                                                                         andComleteBlock:^(NSData *resultData) {
                                                                             RLMRealm *realm = [RLMRealm defaultRealm];
                                                                             [realm beginWriteTransaction];
                                                                             self.sticker.thumbnailData = resultData;
                                                                             [realm commitWriteTransaction];
                                                                         }];
        
        PQImageUriToDataDownloadOperation *fullsizeDownloadOperation = [[PQImageUriToDataDownloadOperation alloc]
                                                                        initWithUri:self.sticker.fullsizeUri
                                                                        andComleteBlock:^(NSData *resultData) {
                                                                            RLMRealm *realm = [RLMRealm defaultRealm];
                                                                            [realm beginWriteTransaction];
                                                                            self.sticker.fullsizeData = resultData;
                                                                            [realm commitWriteTransaction];
                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory stickerCompletedDownloadingFullsizeImage:self.sticker] object:self.sticker];
                                                                        }];
        
        PQImageUriToDataDownloadOperation *spriteDownloadOperation = nil;
        if (self.sticker.spriteUri.length != 0) {
            spriteDownloadOperation = [[PQImageUriToDataDownloadOperation alloc]
                                                                          initWithUri:self.sticker.spriteUri
                                                                          andComleteBlock:^(NSData *resultData) {
                                                                              RLMRealm *realm = [RLMRealm defaultRealm];
                                                                              [realm beginWriteTransaction];
                                                                              self.sticker.spriteData = resultData;
                                                                              [realm commitWriteTransaction];
                                                                          }];
        }
        
        
        NSBlockOperation *finishBlock = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self completeOperation];
                [self.delegate stickerImagesDownloadOperation:self
                                  didFinishDownloadingSticker:self.sticker];
            });
        }];
        [finishBlock addDependency:thumbnailDownloadOperation];
        [finishBlock addDependency:fullsizeDownloadOperation];
        if (self.sticker.spriteUri.length != 0) {
            [finishBlock addDependency:spriteDownloadOperation];
        }
        
        [self.downloadQueue addOperation:thumbnailDownloadOperation];
        [self.downloadQueue addOperation:fullsizeDownloadOperation];
        [self.downloadQueue addOperation:spriteDownloadOperation];
        [self.queue addOperation:finishBlock];
//        NSString *uri = self.sticker.thumbnailUri;
//        
//        
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
//        if ([self isCancelled])
//        {
//            // Must move the operation to the finished state if it is canceled.
//            [self completeOperation];
//            return;
//        }
//        [NSURLConnection sendAsynchronousRequest:request
//                                           queue:[NSOperationQueue mainQueue]
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                                   if ([self isCancelled]) {
//                                       [self completeOperation];
//                                       return;
//                                   }
//                                   RLMRealm *realm = [RLMRealm defaultRealm];
//                                   [realm beginWriteTransaction];
//                                   self.sticker.thumbnailData = data;
//                                   [realm commitWriteTransaction];
//                                   [self completeOperation];
//                                   [self.delegate stickerDownloadOperation:self
//                                               didFinishDownloadingSticker:self.sticker];
//                               }];
    });
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}


@end
