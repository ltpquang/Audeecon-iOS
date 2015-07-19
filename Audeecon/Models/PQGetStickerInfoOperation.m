//
//  PQGetStickerInfo.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQGetStickerInfoOperation.h"
#import "PQSticker.h"
#import "PQRequestingService.h"

@interface PQGetStickerInfoOperation(){
    BOOL executing;
    BOOL finished;
}
@property PQSticker *sticker;
@end
@implementation PQGetStickerInfoOperation
- (id)initWithSticker:(PQSticker *)sticker {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _sticker = sticker;
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
        [[PQRequestingService new] getStickerWithId:self.sticker.stickerId
                                            success:^(PQSticker *sticker) {
                                                //
                                                RLMRealm *realm = [RLMRealm defaultRealm];
                                                [realm beginWriteTransaction];
                                                self.sticker.thumbnailUri = sticker.thumbnailUri;
                                                self.sticker.fullsizeUri = sticker.fullsizeUri;
                                                self.sticker.spriteUri = sticker.spriteUri;
                                                self.sticker.frameCount = sticker.frameCount;
                                                self.sticker.frameRate = sticker.frameRate;
                                                self.sticker.framesPerCol = sticker.framesPerCol;
                                                self.sticker.framesPerRow = sticker.framesPerRow;
                                                self.sticker.width = sticker.width;
                                                self.sticker.height = sticker.height;
                                                [realm commitWriteTransaction];
                                                [self completeOperation];
                                            }
                                            failure:^(NSError *error) {
                                                NSLog(@"Update sticker info failed");
                                                [self completeOperation];
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
