//
//  PQStickerPackDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PQStickerImagesDownloadOperation.h"

@class PQStickerPack;
@protocol PQStickerPackDownloadOperationDelegate;

@interface PQStickerPackDownloadOperation : NSOperation <PQStickerImagesDownloadOperationDelegate>
@property NSInteger percentage;
- (id)initWithStickerPack:(PQStickerPack *)pack
                 delegate:(id<PQStickerPackDownloadOperationDelegate>)delegate;
@end


@protocol PQStickerPackDownloadOperationDelegate <NSObject>
- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
     didFinishDownloadingStickerPack:(PQStickerPack *)pack
                               error:(NSError *)error;
- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
               didUpdateWithProgress:(NSInteger)percentage;
@end