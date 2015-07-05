//
//  PQStickerPack.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm.h>

@interface PQStickerPack : RLMObject
@end


/// Old class, comment to work with Realm
/*
@class PQRequestingService;

@interface PQStickerPack : RLMObject
@property NSString *objectId;
@property NSString *name;
@property NSString *artist;
@property NSString *packDescription;
@property NSString *thumbnail;
@property NSArray *previews;
@property NSArray *stickers;
@property UIImage *thumbnailImage;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL hasStickers;

- (id)initWithId:(NSString *)objectId
         andName:(NSString *)name
       andArtist:(NSString *)artist
andPackDescription:(NSString *)packDescription
    andThumbnail:(NSString *)thumbnail
     andPreviews:(NSArray *)previews
     andStickers:(NSArray *)stickers;

- (void)downloadStickersUsingRequestingService:(PQRequestingService *)requestingService
                                       success:(void(^)())successCall
                                       failure:(void(^)(NSError *error))failureCall;
@end
*/