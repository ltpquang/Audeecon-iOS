//
//  PQMessageDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageDownloadOperation.h"
#import "PQMessage.h"
#import "PQMessageAudioDownloadOperation.h"
#import "PQStickerDownloadOperation.h"
#import "PQNotificationNameFactory.h"
#import "PQSticker.h"

@interface PQMessageDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQMessage *message;
@property NSOperationQueue *downloadQueue;

@end

@implementation PQMessageDownloadOperation
- (id)initWithMessage:(PQMessage *)message
     andDownloadQueue:(NSOperationQueue *)downloadQueue {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _message = message;
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
        NSBlockOperation *finishBlock = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory messageCompletedDownloading:self.message] object:self.message];
                [self completeOperation];
            });
        }];
        
        PQMessageAudioDownloadOperation *messageDownloadOperation = [[PQMessageAudioDownloadOperation alloc] initWithMessage:self.message];
        
        [finishBlock addDependency:messageDownloadOperation];
        
        if (self.message.sticker.fullsizeData.length == 0) {
            PQStickerDownloadOperation *stickerDownloadOperation = [[PQStickerDownloadOperation alloc] initWithSticker:self.message.sticker
                                                                                                      andDownloadQueue:self.downloadQueue];
            [finishBlock addDependency:stickerDownloadOperation];
            [messageDownloadOperation addDependency:stickerDownloadOperation];
            [self.downloadQueue addOperation:stickerDownloadOperation];
        }
        
        [self.downloadQueue addOperation:messageDownloadOperation];
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
