//
//  PQStickerDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerDownloadOperation.h"
#import "PQSticker.h"
#import <AFNetworking.h>

@interface PQStickerDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQSticker *sticker;
@property (weak) id<PQStickerDownloadOperationDelegate> delegate;
@end

@implementation PQStickerDownloadOperation
- (id)initWithSticker:(PQSticker *)sticker
             delegate:(id<PQStickerDownloadOperationDelegate>)delegate {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _sticker = sticker;
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
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *uri = self.sticker.uri;
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:uri]];
        if ([self isCancelled])
        {
            // Must move the operation to the finished state if it is canceled.
            [self completeOperation];
            return;
        }
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if ([self isCancelled]) {
                                       [self completeOperation];
                                       return;
                                   }
                                   RLMRealm *realm = [RLMRealm defaultRealm];
                                   [realm beginWriteTransaction];
                                   self.sticker.thumbnailData = data;
                                   [realm commitWriteTransaction];
                                   [self completeOperation];
                                   [self.delegate stickerDownloadOperation:self
                                               didFinishDownloadingSticker:self.sticker];
                               }];
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
