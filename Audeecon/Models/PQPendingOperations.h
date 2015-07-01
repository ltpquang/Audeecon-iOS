//
//  PQPendingOperations.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/24/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQPendingOperations : NSObject
@property (strong, nonatomic) NSMutableDictionary *downloadsInProgress;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
- (void)reset;
@end
