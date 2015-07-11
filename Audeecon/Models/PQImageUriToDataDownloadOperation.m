//
//  PQImageToDataDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQImageUriToDataDownloadOperation.h"
#import <Realm.h>
#import <AFNetworking.h>
@interface PQImageUriToDataDownloadOperation() {
    BOOL executing;
    BOOL finished;
}
@property NSString *uri;
@property (nonatomic, copy) void (^completeBlock)(NSData *);
@end

@implementation PQImageUriToDataDownloadOperation
- (id)initWithUri:(NSString *)uri
  andComleteBlock:(void(^)(NSData *))completeBlock {
    if (self = [super init]) {
        executing = NO;
        finished = NO;
        _uri = uri;
        _completeBlock = completeBlock;
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
        if (self.uri.length == 0) {
            self.completeBlock(nil);
            [self completeOperation];
            return;
        }
        
        
        
        if ([self isCancelled])
        {
            // Must move the operation to the finished state if it is canceled.
            [self completeOperation];
            return;
        }
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager new];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:self.uri parameters:nil
             success:^(NSURLSessionDataTask *task, NSData *responseObject) {
                 if (responseObject.length == 0) {
                     NSLog(@"DOWNLOAD DATA ERROR");
                 }
                 else {
                     NSLog(@"Data length: %lu", (unsigned long)responseObject.length);
                 }
                 self.completeBlock(responseObject);
                 [self completeOperation];
             }
             failure:^(NSURLSessionDataTask *task, NSError *error) {
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
