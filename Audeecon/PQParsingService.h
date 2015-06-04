//
//  PQParsingService.h
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQParsingService : NSObject
+ (NSArray *)parseListOfStickerPacksFromArray:(NSArray *)array;
+ (NSArray *)parseListOfStickersFromArray:(NSArray *)array;
@end
