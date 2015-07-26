//
//  PQStickerPackStatusManager.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/25/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    StickerPackStatusNotAvailable,
    StickerPackStatusPending,
    StickerPackStatusDownloading,
    StickerPackStatusDownloaded
} StickerPackStatus;

@class PQStickerPack;

@interface PQStickerPackDownloadManager : NSObject
- (StickerPackStatus)statusForStickerPackWithId:(NSString *)packId;
- (NSInteger)progressForStickerPackWithId:(NSString *)packId;
- (void)downloadStickerPack:(PQStickerPack *)pack
         usingDownloadQueue:(NSOperationQueue *)downloadQueue;
- (void)cancelStickPack:(PQStickerPack *)pack;
@end
