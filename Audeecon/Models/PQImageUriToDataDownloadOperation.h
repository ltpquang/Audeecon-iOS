//
//  PQImageToDataDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQImageUriToDataDownloadOperation : NSOperation
- (id)initWithUri:(NSString *)uri
  andComleteBlock:(void(^)(NSData *))completeBlock;
@end
