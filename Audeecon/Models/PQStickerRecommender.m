//
//  PQStickerRecommender.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/26/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerRecommender.h"
#import "PQSticker.h"
#import "PQRequestingService.h"
#import <Realm.h>
#import "PQNotificationNameFactory.h"

@interface PQStickerRecommender()
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableArray *recommendedStickers;
@end

@implementation PQStickerRecommender
- (id)initWithUsername:(NSString *)username {
    if (self = [super init]) {
        _username = username;
    }
    return self;
}

- (void)getRecommendedStickers {
    [[PQRequestingService new] getRecommendedStickersForUser:self.username
                                                usingSticker:@""
                                                     success:^(NSArray *result) {
                                                         //
                                                         NSMutableArray *ids = [NSMutableArray new];
                                                         for (NSString *string in result) {
                                                             [ids addObject:(NSString *)string];
                                                         }
                                                         self.recommendedStickers = [[self stickerArrayFromIdArray:ids] mutableCopy];
                                                         [self postNotification];
                                                     }
                                                     failure:^(NSError *error) {
                                                         //failureCall(error);
                                                     }];
}

- (void)updateRecommenderUsingSticker:(PQSticker *)sticker {
    if (self.recommendedStickers.count != 0) {
        [self.recommendedStickers removeObjectAtIndex:0];
    }
    [self postNotification];
    [[PQRequestingService new] getRecommendedStickersForUser:self.username
                                                usingSticker:sticker.stickerId
                                                     success:^(NSArray *result) {
                                                         //
                                                         NSMutableArray *ids = [NSMutableArray new];
                                                         for (NSString *string in result) {
                                                             [ids addObject:(NSString *)string];
                                                         }
                                                         self.recommendedStickers = [[self stickerArrayFromIdArray:ids] mutableCopy];
                                                         [self postNotification];
                                                     }
                                                     failure:^(NSError *error) {
                                                         //failureCall(error);
                                                     }];
}

- (NSArray *)curentRecommendedStickers {
    return self.recommendedStickers;
}

- (NSArray *)stickerArrayFromIdArray:(NSArray *)ids {
    NSString *keyName = @"stickerId";
    
    RLMResults *results = [PQSticker objectsWithPredicate:[NSPredicate
                                                           predicateWithFormat:
                                                           [NSString stringWithFormat:@"%@ IN %%@", keyName],
                                                           ids]];//[NSPredicate predicateWithFormat:@"%K IN %@", keyName, ids]];
    return [results valueForKey:@"self"];
}

- (void)postNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory recommendedStickersChanged]
                                                        object:nil];
}
@end
