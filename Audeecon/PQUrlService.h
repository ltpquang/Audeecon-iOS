//
//  PQUrlService.h
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQUrlService : NSObject
+ (NSString *)urlToGetAllStickerPacks;
+ (NSString *)urlToGetAllStickerPacksForUser:(NSString *)username;
+ (NSString *)urlToGetStickerPackWithId:(NSString *)packId;

+ (NSString *)urlToS3FileWithFileName:(NSString *)fileName;
@end
