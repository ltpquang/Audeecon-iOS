//
//  PQStickerPackDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQStickerDownloadOperation.h"

@protocol PQStickerPackDownloadOperationDelegate;
@class PQStickerPack;

@interface PQStickerPackDownloadOperation : NSOperation <PQStickerDownloadOperationDelegate>
- (id)initWithStickerPack:(PQStickerPack *)pack
                 delegate:(id<PQStickerPackDownloadOperationDelegate>)delegate;
@end


@protocol PQStickerPackDownloadOperationDelegate <NSObject>

- (void)stickerPackDidFinishDownloading;

@end