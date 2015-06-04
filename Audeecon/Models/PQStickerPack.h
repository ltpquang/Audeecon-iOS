//
//  PQStickerPack.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQRequestingService;

@interface PQStickerPack : NSObject
@property NSString *objectId;
@property NSString *name;
@property NSString *artist;
@property NSString *packDescription;
@property NSString *thumbnail;
@property NSArray *previews;
@property NSArray *stickers;

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