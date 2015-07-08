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
#import "PQBuyStickerPackOperation.h"
#import "PQGetStickersInfoOperation.h"
#import <AFNetworking.h>
#import <Realm.h>

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
    self.downloadQueue.maxConcurrentOperationCount = 4; //NSOperationQueueDefaultMaxConcurrentOperationCount;
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
        NSBlockOperation *downloadPackThumbnailOperation = [NSBlockOperation blockOperationWithBlock:^{
            if ([self isCancelled]) {
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *urlString = self.pack.thumbnailUri;
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                [NSURLConnection sendAsynchronousRequest:urlRequest
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           
                                           RLMRealm *realm = [RLMRealm defaultRealm];
                                           [realm beginWriteTransaction];
                                           self.pack.thumbnailData = data;
                                           [realm commitWriteTransaction];
                                       }];
                
            });
            
        }];
        
        PQBuyStickerPackOperation *buyStickerPackOpe = [[PQBuyStickerPackOperation alloc] initWithStickerPack:self.pack];
        
        [buyStickerPackOpe setCompletionBlock:^{
            [self.delegate stickerPackDownloadOperation:self
                                  didUpdateWithProgress:100];
            self.percentage = 100;
            [self completeOperation];
            [self.delegate stickerPackDownloadOperation:self
                        didFinishDownloadingStickerPack:self.pack
                                                  error:nil];
        }];
        
        [buyStickerPackOpe addDependency:downloadPackThumbnailOperation];
        
        
        RLMArray<PQSticker> *stickers = self.pack.stickers;
        
        for (PQSticker *sticker in stickers) {
            PQStickerDownloadOperation *stickerDownloadOpe = [[PQStickerDownloadOperation alloc]
                                                              initWithSticker:sticker
                                                              delegate:self];
            
            [buyStickerPackOpe addDependency:stickerDownloadOpe];
            [self.downloadQueue addOperation:stickerDownloadOpe];
        }
        [self.downloadQueue addOperation:downloadPackThumbnailOperation];
        [self.downloadQueue addOperation:buyStickerPackOpe];
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

- (void)stickerDownloadOperation:(PQStickerDownloadOperation *)operation
     didFinishDownloadingSticker:(PQSticker *)sticker {
    NSInteger percentage = (NSInteger)(100 * (1 - (float)(self.downloadQueue.operationCount)/(float)(self.pack.stickers.count + 1)));
    self.percentage = percentage;
    [self.delegate stickerPackDownloadOperation:self
                          didUpdateWithProgress:percentage];
}
@end
