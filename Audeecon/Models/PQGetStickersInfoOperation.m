//
//  PQGetStickersInfoOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQGetStickersInfoOperation.h"
#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import <RLMRealm.h>

@interface PQGetStickersInfoOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;
@property NSString *packId;

@end

@implementation PQGetStickersInfoOperation
- (id)initWithStickerPack:(PQStickerPack *)pack {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _pack = pack;
    }
    return self;
}

- (id)initWithStickerPackId:(NSString *)packId {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _packId = packId;
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
    __block NSString *packId = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        packId = self.pack.packId;
    });
    [[PQRequestingService new] getStickersOfStickerPackWithId:packId//self.packId
                                                      success:^(NSArray *result) {
                                                          RLMRealm *realm = [RLMRealm defaultRealm];
                                                          PQStickerPack *pack = [PQStickerPack objectForPrimaryKey:self.packId];
                                                          [realm beginWriteTransaction];
                                                          [pack.stickers removeAllObjects];
                                                          [pack.stickers addObjects:result];
                                                          [realm commitWriteTransaction];
                                                          [self completeOperation];
                                                      }
                                                      failure:^(NSError *error) {
                                                          //
                                                      }];
//    [pack downloadStickersUsingRequestingService:[PQRequestingService new]
//                                              success:^{
//                                                  [self completeOperation];
//                                              }
//                                              failure:^(NSError *error) {
//                                                  NSLog(@"Error in get stickers info operation");
//                                                  [self completionBlock];
//                                              }];
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
