//
//  PQStickerRecommender.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/26/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQSticker;

@interface PQStickerRecommender : NSObject
- (id)initWithUsername:(NSString *)username;

- (void)getRecommendedStickers;

- (void)updateRecommenderUsingSticker:(PQSticker *)sticker;

- (NSArray *)curentRecommendedStickers;
@end
