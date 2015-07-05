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

@interface PQStickerPackDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;
@property NSOperationQueue *downloadQueue;
@property id<PQStickerPackDownloadOperationDelegate> delegate;
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
    self.downloadQueue.maxConcurrentOperationCount = 4;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    
    if (self.isCancelled) {
        return;
    }
    
    NSBlockOperation *blockOpe = [NSBlockOperation blockOperationWithBlock:^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.pack.thumbnailUri]];
        if (self.isCancelled) {
            imgData = nil;
            return;
        }
        self.pack.thumbnailData = imgData;
        if (self.isCancelled) {
            imgData = nil;
            return;
        }
    }];
    [blockOpe setCompletionBlock:^{
        [self completeOperation];
    }];
    
    for (PQSticker *sticker in self.pack.stickers) {
        PQStickerDownloadOperation *stickerDownloadOpe = [[PQStickerDownloadOperation alloc] initWithSticker:sticker
                                                                                                    delegate:self];
        [blockOpe addDependency:stickerDownloadOpe];
        [self.downloadQueue addOperation:stickerDownloadOpe];
    }
    [self.downloadQueue addOperation:blockOpe];
}

- (void)stickerDidFinishDownloading {
    if (self.downloadQueue.operationCount == 0) {
        NSLog(@"Complete");
    }
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
