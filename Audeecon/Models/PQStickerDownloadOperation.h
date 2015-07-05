//
//  PQStickerDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PQStickerDownloadOperationDelegate;
@class PQSticker;

@interface PQStickerDownloadOperation : NSOperation
- (id)initWithSticker:(PQSticker *)sticker
             delegate:(id<PQStickerDownloadOperationDelegate>)delegate;
@end

@protocol PQStickerDownloadOperationDelegate <NSObject>

- (void)stickerDidFinishDownloading;

@end
