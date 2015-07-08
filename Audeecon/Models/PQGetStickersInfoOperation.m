//
//  PQGetStickersInfoOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQGetStickersInfoOperation.h"
#import "PQStickerPack.h"
#import "PQSticker.h"
#import "PQRequestingService.h"
#import <RLMRealm.h>

@interface PQGetStickersInfoOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQStickerPack *pack;

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
        NSString *packId = self.pack.packId;
        
        [[PQRequestingService new] getStickersOfStickerPackWithId:packId
                                                          success:^(NSArray *result) {
                                                              RLMRealm *realm = [RLMRealm defaultRealm];
                                                              
                                                              [realm beginWriteTransaction];
                                                              [self.pack.stickers removeAllObjects];
                                                              for (PQSticker *sticker in result) {
                                                                  PQSticker *returnSticker = [PQSticker createOrUpdateInDefaultRealmWithValue:sticker];
                                                                  [self.pack.stickers addObject:returnSticker];
                                                              }
                                                              [realm commitWriteTransaction];
                                                              [self completeOperation];
                                                          }
                                                          failure:^(NSError *error) {
                                                              //
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
