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

+ (NSString *)urlToGetAllUsers {
    NSString *result = [[self baseUrl]
                        stringByAppendingString:@"/users"];
    NSLog(@"%@", result);
    return result;
}

+ (NSString *)urlToGetAllStickerPacksForUser:(NSString *)username {
    NSString *result = [[[[self urlToGetAllUsers]
                        stringByAppendingString:@"/"]
                        stringByAppendingString:username]
                        stringByAppendingString:@"/packs"];
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

+ (NSString *)urlToS3FileWithFileName:(NSString *)fileName {
    return [@"https://s3.amazonaws.com/audeecon-us/" stringByAppendingString:fileName];
}

+ (NSString *)urlToDefaultAvatar {
    return @"https://s3.amazonaws.com/audeecon-us/default/defaultavatar.jpeg";
}

+ (NSString *)urlToBuyStickerPackForUser:(NSString *)username {
    //audeecon.herokuapp.com/api/v1/users/:username/purchase
    //pack_id:
    NSString *result = [[[[self urlToGetAllUsers]
                        stringByAppendingString:@"/"]
                        stringByAppendingString:username]
                        stringByAppendingString:@"/purchase"];
    NSLog(@"%@", result);
    return result;
}

@end
