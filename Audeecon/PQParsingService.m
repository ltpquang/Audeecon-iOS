//
//  PQParsingService.m
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQParsingService.h"
#import "PQStickerPack.h"
#import "PQSticker.h"

@implementation PQParsingService

#pragma mark - Sticker pack
+ (PQStickerPack *)parseStickerPackFromDictionary:(NSDictionary *)pack {
//    PQStickerPack *result = [[PQStickerPack alloc] initWithId:(NSString *)[pack valueForKey:@"_id"]
//                                                      andName:(NSString *)[pack valueForKey:@"name"]
//                                                    andArtist:(NSString *)[pack valueForKey:@"artist"]
//                                           andPackDescription:(NSString *)[pack valueForKey:@"description"]
//                                                 andThumbnail:(NSString *)[pack valueForKey:@"profile_image"]
//                                                  andPreviews:(NSArray *)[pack valueForKey:@"previews"]
//                                                  andStickers:nil];
//    return result;
    PQStickerPack *result = [[PQStickerPack alloc] initWithPackId:pack[@"_id"]
                                                          andName:pack[@"name"]
                                                        andArtist:pack[@"artist"]
                                                   andDescription:pack[@"description"]
                                                  andThumbnailUri:pack[@"profile_image"]];
    return result;
}

+ (NSArray *)parseListOfStickerPacksFromArray:(NSArray *)array {
    if (array == (id)[NSNull null] || array.count == 0) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *pack in array) {
        [result addObject:[self parseStickerPackFromDictionary:pack]];
    }
    return result;
}

#pragma mark - Sticker
+ (PQSticker *)parseStickerFromDictionary:(NSDictionary *)sticker {
    PQSticker *result = [[PQSticker alloc] initWithStickerId:sticker[@"_id"]
                                             andThumbnailUri:sticker[@"thumbnail_uri"]
                                              andFullsizeUri:sticker[@"fullsize_uri"]
                                                andSpriteUri:sticker[@"fullsize_sprite_uri"]
                                               andFrameCount:[sticker[@"frame_count"] integerValue]
                                                andFrameRate:[sticker[@"frame_rate"] integerValue]
                                             andFramesPerCol:[sticker[@"frames_per_col"] integerValue]
                                             andFramesPerRow:[sticker[@"frames_per_row"] integerValue]];
    return result;
}

+ (NSArray *)parseListOfStickersFromArray:(NSArray *)array {
    if (array == (id)[NSNull null] || array.count == 0) {
        return nil;
    }
    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *sticker in array) {
        [result addObject:[self parseStickerFromDictionary:sticker]];
    }
    return result;
}
@end
