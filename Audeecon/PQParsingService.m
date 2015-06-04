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
    PQStickerPack *result = [[PQStickerPack alloc] initWithId:(NSString *)[pack valueForKey:@"_id"]
                                                      andName:(NSString *)[pack valueForKey:@"name"]
                                                    andArtist:(NSString *)[pack valueForKey:@"artist"]
                                           andPackDescription:(NSString *)[pack valueForKey:@"description"]
                                                 andThumbnail:(NSString *)[pack valueForKey:@"profile_image"]
                                                  andPreviews:(NSArray *)[pack valueForKey:@"previews"]
                                                  andStickers:nil];
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
    PQSticker *result = [[PQSticker alloc] initWithId:(NSString *)[sticker objectForKey:@"sticker_id"]
                                             andWidth:[[sticker valueForKey:@"width"] integerValue]
                                            andHeight:[[sticker valueForKey:@"height"] integerValue]
                                        andFrameCount:[[sticker valueForKey:@"frame_count"] integerValue]
                                         andFrameRate:[[sticker valueForKey:@"frame_rate"] integerValue]
                                      andFramesPerCol:[[sticker valueForKey:@"frames_per_col"] integerValue]
                                      andFramesPerRow:[[sticker valueForKey:@"frames_per_row"] integerValue]
                                               andUri:(NSString *)[sticker valueForKey:@"uri"]
                                         andSourceUri:(NSString *)[sticker valueForKey:@"source_uri"]
                                         andSpriteUri:(NSString *)[sticker valueForKey:@"sprite_uri"]
                                   andPaddedSpriteUri:(NSString *)[sticker valueForKey:@"padded_sprite_uri"]];
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
