//
//  PQRequestingService.h
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQRequestingService : NSObject
- (void)getAllStickerPacksForUser:(NSString *)user
                          success:(void(^)(NSArray *result))successCall
                          failure:(void(^)(NSError *error))failureCall;
- (void)getStickersOfStickerPackWithId:(NSString *)packId
                               success:(void(^)(NSArray *result))successCall
                               failure:(void(^)(NSError *error))failureCall;
- (void)downloadAudioFileAtUrl:(NSString *)fileUrl
                      complete:(void(^)(NSURL *filepath))completeCall;
- (void)registerWithServerForUser:(NSString *)username
                          success:(void(^)())successCall
                          failure:(void(^)(NSError *error))failureCall;
- (void)buyStickerPack:(NSString *)packId
               forUser:(NSString *)username
               success:(void(^)())successCall
               failure:(void(^)(NSError *error))failureCall;
@end
