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


@class PQRequestingService;
@interface PQStickerPack : RLMObject <PQStickerPackDownloadOperationDelegate>
@property NSString *packId;
@property NSString *name;
@property NSString *artist;
@property NSString *packDescription;
@property NSString *thumbnailUri;
@property NSData *thumbnailData;
@property RLMArray<PQSticker> *stickers;
//Excluded in realm
@property (nonatomic) UIImage *thumbnailImage;
@property (nonatomic) BOOL needToBeUpdated;

- (id)initWithPackId:(NSString *)packId
             andName:(NSString *)name
           andArtist:(NSString *)artist
      andDescription:(NSString *)packDescription
     andThumbnailUri:(NSString *)thumbnailUri;
- (NSOperation *)downloadDataAndStickersUsingOperationQueue:(NSOperationQueue *)queue;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQStickerPack>
RLM_ARRAY_TYPE(PQStickerPack)
