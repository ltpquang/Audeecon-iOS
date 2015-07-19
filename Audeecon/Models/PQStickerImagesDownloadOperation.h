//
//  PQStickerDownloadOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PQSticker;
@protocol PQStickerImagesDownloadOperationDelegate;

@interface PQStickerImagesDownloadOperation : NSOperation
- (id)initWithSticker:(PQSticker *)sticker
             andQueue:(NSOperationQueue *)queue
     andDownloadQueue:(NSOperationQueue *)downloadQueue
             delegate:(id<PQStickerImagesDownloadOperationDelegate>)delegate;
@end

@protocol PQStickerImagesDownloadOperationDelegate <NSObject>
- (void)stickerImagesDownloadOperation:(PQStickerImagesDownloadOperation *)operation
     didFinishDownloadingSticker:(PQSticker *)sticker;
@end
