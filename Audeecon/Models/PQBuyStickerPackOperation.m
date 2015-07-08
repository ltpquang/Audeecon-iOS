//
//  PQBuyStickerOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQBuyStickerPackOperation.h"
#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import "AppDelegate.h"
#import "PQCurrentUser.h"

@interface PQBuyStickerPackOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;

@end

@implementation PQBuyStickerPackOperation
- (id)initWithStickerPack:(PQStickerPack *)pack {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _pack = pack;
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
    [[PQRequestingService new] buyStickerPack:self.pack.packId
                                      forUser:[[[self appDelegate] currentUser] username]
                                      success:^{
                                          //
                                          [self completeOperation];
                                          NSLog(@"Buy complete");
                                      }
                                      failure:^(NSError *error) {
                                          //
                                          NSLog(@"Error in buy sticker operation");
                                          [self completeOperation];
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

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
@end
