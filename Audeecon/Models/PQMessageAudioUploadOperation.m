//
//  PQMessageAudioUploadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageAudioUploadOperation.h"
#import "PQMessage.h"
#import "PQNotificationNameFactory.h"

@interface PQMessageAudioUploadOperation() {
    BOOL executing;
    BOOL finished;
}
@property PQMessage *message;

@end

@implementation PQMessageAudioUploadOperation
- (id)initWithMessage:(PQMessage *)message {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _message = message;
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
        [self.message uploadAudioWithCompletion:^(BOOL succeeded, NSError *error) {
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

