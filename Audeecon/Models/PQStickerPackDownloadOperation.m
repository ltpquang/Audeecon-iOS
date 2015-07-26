//
//  PQStickerPackDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPackDownloadOperation.h"
#import "PQSticker.h"
#import "PQStickerPack.h"
#import "PQStickerImagesDownloadOperation.h"
#import "PQRequestingService.h"
#import "PQBuyStickerPackOperation.h"
#import "PQGetStickersInfoOperation.h"
#import <AFNetworking.h>
#import <Realm.h>
#import "PQImageUriToDataDownloadOperation.h"

@interface PQStickerPackDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;
@property NSOperationQueue *downloadQueue;
@property NSOperationQueue *stickerQueue;
@property NSInteger doneCount;
@property (weak) id<PQStickerPackDownloadOperationDelegate> delegate;
@end

@implementation PQStickerPackDownloadOperation

- (id)initWithStickerPack:(PQStickerPack *)pack
                 delegate:(id<PQStickerPackDownloadOperationDelegate>)delegate {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _pack = pack;
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
    NSLog(@"Start download pack");
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    self.downloadQueue = [[NSOperationQueue alloc] init];
    self.downloadQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    self.stickerQueue = [[NSOperationQueue alloc] init];
    self.stickerQueue.maxConcurrentOperationCount = -1;
    self.doneCount = 0;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PQImageUriToDataDownloadOperation *thumbnailDownloadOperation = [[PQImageUriToDataDownloadOperation alloc]
                                                                         initWithUri:self.pack.thumbnailUri
                                                                         andComleteBlock:^(NSData *resultData) {
                                                                             RLMRealm *realm = [RLMRealm defaultRealm];
                                                                             [realm beginWriteTransaction];
                                                                             self.pack.thumbnailData = resultData;
                                                                             [realm commitWriteTransaction];
                                                                         }];
        
        PQBuyStickerPackOperation *buyStickerPackOpe = [[PQBuyStickerPackOperation alloc] initWithStickerPack:self.pack];
        
        NSBlockOperation *finishBlock = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate stickerPackDownloadOperation:self
                                      didUpdateWithProgress:100];
                self.percentage = 100;
                [self completeOperation];
                [self.delegate stickerPackDownloadOperation:self
                            didFinishDownloadingStickerPack:self.pack
                                                      error:nil];
            });
        }];
        
        [finishBlock addDependency:thumbnailDownloadOperation];
        [finishBlock addDependency:buyStickerPackOpe];
        
        RLMArray<PQSticker> *stickers = self.pack.stickers;
        
        for (PQSticker *sticker in stickers) {
            PQStickerImagesDownloadOperation *stickerDownloadOpe = [[PQStickerImagesDownloadOperation alloc]
                                                              initWithSticker:sticker
                                                              andQueue:self.downloadQueue
                                                              andDownloadQueue:self.stickerQueue
                                                              delegate:self];
            stickerDownloadOpe.completionBlock = ^() {
                ++self.doneCount;
            };
            
            [buyStickerPackOpe addDependency:stickerDownloadOpe];
            [self.downloadQueue addOperation:stickerDownloadOpe];
        }
        [self.downloadQueue addOperation:thumbnailDownloadOperation];
        [self.downloadQueue addOperation:buyStickerPackOpe];
        [self.downloadQueue addOperation:finishBlock];
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

- (void)stickerImagesDownloadOperation:(PQStickerImagesDownloadOperation *)operation
     didFinishDownloadingSticker:(PQSticker *)sticker {
    NSInteger totalCount = self.pack.stickers.count + 1;
    NSInteger doneCount = self.doneCount;
    NSInteger donePercentage = (NSInteger)(((float)doneCount/(float)totalCount) * 100.0);
    self.percentage = donePercentage;
    [self.delegate stickerPackDownloadOperation:self
                          didUpdateWithProgress:donePercentage];
}
@end
