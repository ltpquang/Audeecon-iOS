//
//  PQStickerPackDownloader.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/24/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PQSticker;
@class PQStickerPack;

@protocol PQStickerAndPackDownloaderDelegate;

@interface PQStickerAndPackDownloader : NSOperation
@property (nonatomic, weak) id<PQStickerAndPackDownloaderDelegate> downloaderDelegate;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) PQStickerPack *pack;
@property (strong, nonatomic) PQSticker *sticker;
@property BOOL forPack;

- (id)initWithStickerPack:(PQStickerPack *)pack
              atIndexPath:(NSIndexPath *)indexPath
                 delegate:(id<PQStickerAndPackDownloaderDelegate>)delegate;

- (id)initWithSticker:(PQSticker *)sticker
          atIndexPath:(NSIndexPath *)indexPath
             delegate:(id<PQStickerAndPackDownloaderDelegate>)delegate;
@end

@protocol PQStickerAndPackDownloaderDelegate <NSObject>
- (void)packDownloaderDidFinish:(PQStickerAndPackDownloader *)downloader;
- (void)stickerDownloaderDidFinish:(PQStickerAndPackDownloader *)downloader;
@end
