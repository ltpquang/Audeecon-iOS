//
//  PQStickerDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQSticker;
@interface PQStickerDownloadOperation : NSOperation
- (id)initWithSticker:(PQSticker *)sticker
     andDownloadQueue:(NSOperationQueue *)downloadQueue;

@end
