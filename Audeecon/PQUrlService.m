//
//  PQUrlService.m
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQUrlService.h"

@implementation PQUrlService
+ (NSString *)baseUrl {
    return @"http://audeecon.herokuapp.com/api/v2";
}

+ (NSString *)urlToGetAllStickerPacks {
    NSString *result = [[self baseUrl]
                        stringByAppendingString:@"/packs"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetAllStickers {
    NSString *result = [[self baseUrl]
                        stringByAppendingString:@"/stickers"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetAllUsers {
    NSString *result = [[self baseUrl]
                        stringByAppendingString:@"/users"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetUser:(NSString *)username {
    NSString *result = [[[self urlToGetAllUsers]
                        stringByAppendingString:@"/"]
                        stringByAppendingString:username];
    NSLog(@"%@", result);
    return  result;
}

+ (NSString *)urlToGetAllStickerPacksForUser:(NSString *)username {
    NSString *result = [[self urlToGetUser:username]
                        stringByAppendingString:@"/packs"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToBuyStickerPackForUser:(NSString *)username {
    //audeecon.herokuapp.com/api/v2/users/:username/purchase
    NSString *result = [[self urlToGetUser:username]
                        stringByAppendingString:@"/purchase"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetRecommendedStickersForUser:(NSString *)username {
    //audeecon.herokuapp.com/api/v2/users/:username/recommend
    NSString *result = [[self urlToGetUser:username]
                        stringByAppendingString:@"/recommend"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetStickerPackWithId:(NSString *)packId {
    //?size=240
    NSString *result = [[[[self urlToGetAllStickerPacks]
                        stringByAppendingString:@"/"]
                        stringByAppendingString:packId]
                        stringByAppendingString:@"?size=240"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetStickerWithId:(NSString *)stickerId {
    NSString *result = [[[self urlToGetAllStickers]
                        stringByAppendingString:@"/"]
                        stringByAppendingString:stickerId];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToS3FileWithFileName:(NSString *)fileName {
    return [@"https://s3.amazonaws.com/audeecon-us/" stringByAppendingString:fileName];
}

+ (NSString *)urlToDefaultAvatar {
    //return @"https://s3.amazonaws.com/audeecon-us/default/defaultavatar.jpeg";
    return @"";
}

@end
