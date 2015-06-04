//
//  PQRequestingService.m
//  FBStickerCrawler
//
//  Created by Le Thai Phuc Quang on 4/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQRequestingService.h"
#import <AFNetworking.h>
#import "PQUrlService.h"
#import "PQParsingService.h"
#import "PQStickerPack.h"

@interface PQRequestingService()
@property AFHTTPSessionManager *manager;
@end

@implementation PQRequestingService
- (id)init {
    if (self = [super init]) {
        [self setupManager];
    }
    return self;
}

- (void)setupManager {
    _manager = [[AFHTTPSessionManager alloc] init];
}

- (void)configWithExpectationOfJsonInRequest:(BOOL)jsonInRequest
                           andJsonInResponse:(BOOL)jsonInResponse {
    _manager.requestSerializer = jsonInRequest?[AFJSONRequestSerializer serializer]:[AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = jsonInResponse?[AFJSONResponseSerializer serializer]:[AFHTTPResponseSerializer serializer];
}

- (void)getAllStickerPacksWithSuccess:(void(^)(NSArray *result))successCall
                              failure:(void(^)(NSError *error))failureCall {
    [self configWithExpectationOfJsonInRequest:NO
                             andJsonInResponse:YES];
    [_manager GET:[PQUrlService urlToGetAllStickerPacks]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              //Parse result and call the call back
              NSArray *result = [PQParsingService parseListOfStickerPacksFromArray:(NSArray *)responseObject];
              successCall(result);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              failureCall(error);
          }];
}

- (void)getStickersOfStickerPackWithId:(NSString *)packId
                               success:(void(^)(NSArray *result))successCall
                               failure:(void(^)(NSError *error))failureCall {
    [self configWithExpectationOfJsonInRequest:NO
                             andJsonInResponse:YES];
    [_manager GET:[PQUrlService urlToGetStickerPackWithId:packId]
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              //Parse result and call the call back
              //NSArray *stickers = (NSArray *)[(NSDictionary *)responseObject objectForKey:@"stickers"];
              NSArray *result = [PQParsingService parseListOfStickersFromArray:(NSArray *)responseObject];
              successCall(result);
          }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              failureCall(error);
          }];
}
@end
