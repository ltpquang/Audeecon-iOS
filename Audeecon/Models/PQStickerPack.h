//
//  PQStickerPack.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>
#import "PQSticker.h"
#import "PQStickerPackDownloadOperation.h"
typedef enum : NSUInteger {
    StickerPackStatusNotAvailable,
    StickerPackStatusPending,
    StickerPackStatusDownloading,
    StickerPackStatusDownloaded
} StickerPackStatus;

@class PQRequestingService;
@interface PQStickerPack : RLMObject <PQStickerPackDownloadOperationDelegate>
@property NSString *packId;
@property NSString *name;
@property NSString *artist;
@property NSString *packDescription;
@property NSString *thumbnailUri;
@property NSData *thumbnailData;
@property (nonatomic) UIImage *thumbnailImage;
@property StickerPackStatus status;
@property (nonatomic) NSInteger percentage;
@property RLMArray<PQSticker> *stickers;

- (id)initWithPackId:(NSString *)packId
             andName:(NSString *)name
           andArtist:(NSString *)artist
      andDescription:(NSString *)packDescription
     andThumbnailUri:(NSString *)thumbnailUri;
- (void)downloadStickersUsingRequestingService:(PQRequestingService *)requestingService
                                       success:(void(^)())successCall
                                       failure:(void(^)(NSError *error))failureCall;
- (void)downloadDataAndStickersUsingOperationQueue:(NSOperationQueue *)queue
                                          progress:(void(^)(NSInteger percentage))progressCall;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQStickerPack>
RLM_ARRAY_TYPE(PQStickerPack)
