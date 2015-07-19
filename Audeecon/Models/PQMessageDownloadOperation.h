//
//  PQMessageDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQMessage;

@interface PQMessageDownloadOperation : NSOperation
- (id)initWithMessage:(PQMessage *)message
     andDownloadQueue:(NSOperationQueue *)downloadQueue;
@end
