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

@class PQRequestingService;
@interface PQStickerPack : RLMObject
@property NSString *packId;
@property NSString *name;
@property NSString *artist;
@property NSString *packDescription;
@property NSString *thumbnailUri;
@property NSData *thumbnailData;
@property (nonatomic) UIImage *thumbnailImage;
@property RLMArray<PQSticker> *stickers;

- (id)initWithPackId:(NSString *)packId
             andName:(NSString *)name
           andArtist:(NSString *)artist
      andDescription:(NSString *)packDescription
     andThumbnailUri:(NSString *)thumbnailUri;
- (void)downloadStickersUsingRequestingService:(PQRequestingService *)requestingService
                                       success:(void(^)())successCall
                                       failure:(void(^)(NSError *error))failureCall;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQStickerPack>
RLM_ARRAY_TYPE(PQStickerPack)
