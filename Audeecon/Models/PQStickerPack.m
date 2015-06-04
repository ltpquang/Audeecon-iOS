//
//  PQStickerPack.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPack.h"
#import "PQRequestingService.h"

@implementation PQStickerPack
- (id)initWithId:(NSString *)objectId
         andName:(NSString *)name
       andArtist:(NSString *)artist
andPackDescription:(NSString *)packDescription
    andThumbnail:(NSString *)thumbnail
     andPreviews:(NSArray *)previews
     andStickers:(NSArray *)stickers {
    if (self = [super init]) {
        _objectId = objectId;
        _name = name;
        _artist = artist;
        _packDescription = packDescription;
        _thumbnail = thumbnail;
        _previews = previews;
        _stickers = stickers;
    }
    return self;
}

- (void)downloadStickersUsingRequestingService:(PQRequestingService *)requestingService
                                       success:(void(^)())successCall
                                       failure:(void(^)(NSError *error))failureCall {
    [requestingService getStickersOfStickerPackWithId:_objectId
                                              success:^(NSArray *result) {
                                                  _stickers = result;
                                                  successCall();
                                              }
                                              failure:^(NSError *error) {
                                                  failureCall(error);
                                              }];
}
@end
