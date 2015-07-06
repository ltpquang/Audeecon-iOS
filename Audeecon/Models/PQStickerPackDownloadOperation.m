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
#import "PQStickerDownloadOperation.h"
#import "PQRequestingService.h"
#import <AFNetworking.h>

@interface PQStickerPackDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;
@property NSOperationQueue *downloadQueue;
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
    
    [self.pack downloadStickersUsingRequestingService:[PQRequestingService new]
                                              success:^{
                                                  //
                                                  NSBlockOperation *downloadPackThumbnailOperation = [NSBlockOperation blockOperationWithBlock:^{
                                                      if ([self isCancelled]) {
                                                          return;
                                                      }
                                                      NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pack.thumbnailUri]];
                                                      self.pack.thumbnailData = imgData;
                                                  }];
                                                  [downloadPackThumbnailOperation setCompletionBlock:^{
                                                      [self.delegate stickerPackDownloadOperation:self
                                                                            didUpdateWithProgress:100];
                                                      self.percentage = 100;
                                                      [self completeOperation];
                                                      [self.delegate stickerPackDownloadOperation:self
                                                                  didFinishDownloadingStickerPack:self.pack
                                                                                            error:nil];
                                                  }];
                                                  
                                                  for (PQSticker *sticker in self.pack.stickers) {
                                                      PQStickerDownloadOperation *stickerDownloadOpe = [[PQStickerDownloadOperation alloc]
                                                                                                        initWithSticker:sticker
                                                                                                        delegate:self];
                                                      [downloadPackThumbnailOperation addDependency:stickerDownloadOpe];
                                                      [self.downloadQueue addOperation:stickerDownloadOpe];
                                                  }
                                                  
                                                  [self.downloadQueue addOperation:downloadPackThumbnailOperation];
                                              }
                                              failure:^(NSError *error) {
                                                  //
                                                  [self.delegate stickerPackDownloadOperation:self
                                                              didFinishDownloadingStickerPack:self.pack
                                                                                        error:error];
                                              }];
    
    
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

- (void)stickerDownloadOperation:(PQStickerDownloadOperation *)operation
     didFinishDownloadingSticker:(PQSticker *)sticker {
    NSInteger percentage = (NSInteger)(100 * (1 - (float)(self.downloadQueue.operationCount)/(float)(self.pack.stickers.count + 1)));
    self.percentage = percentage;
    [self.delegate stickerPackDownloadOperation:self
                          didUpdateWithProgress:percentage];
}
@end
