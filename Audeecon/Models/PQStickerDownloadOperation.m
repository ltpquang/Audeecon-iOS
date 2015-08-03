//
//  PQStickerDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerDownloadOperation.h"
#import "PQStickerImagesDownloadOperation.h"
#import "PQGetStickerInfoOperation.h"
#import "PQNotificationNameFactory.h"
#import "PQSticker.h"

@interface PQStickerDownloadOperation(){
    BOOL executing;
    BOOL finished;
}
@property PQSticker *sticker;
@property NSOperationQueue *downloadQueue;
@end

@implementation PQStickerDownloadOperation
- (id)initWithSticker:(PQSticker *)sticker
     andDownloadQueue:(NSOperationQueue *)downloadQueue {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _sticker = sticker;
        _downloadQueue = downloadQueue;
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
    //NSLog(@"Start download pack");
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    dispatch_async(dispatch_get_main_queue(), ^{
        PQGetStickerInfoOperation *getInfoOpe = [[PQGetStickerInfoOperation alloc] initWithSticker:self.sticker];
        PQStickerImagesDownloadOperation *imagesDownloadOpe = [[PQStickerImagesDownloadOperation alloc]
                                                               initWithSticker:self.sticker
                                                               andQueue:self.downloadQueue
                                                               andDownloadQueue:self.downloadQueue
                                                               delegate:nil];
        NSBlockOperation *finishBlock = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory stickerCompletedDownloading:self.sticker.stickerId]
                                                                    object:self.sticker];
            });
        }];
        [imagesDownloadOpe addDependency:getInfoOpe];
        [finishBlock addDependency:imagesDownloadOpe];
        
        [self.downloadQueue addOperation:getInfoOpe];
        [self.downloadQueue addOperation:imagesDownloadOpe];
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
@end
