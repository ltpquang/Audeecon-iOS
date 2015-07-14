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
#import "PQFilePathFactory.h"

@interface PQRequestingService()
@property AFHTTPSessionManager *manager;
@property AFHTTPSessionManager *downloadManager;
@property NSURLSessionDownloadTask *downloadTask;
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
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _downloadManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
}

- (void)configWithExpectationOfJsonInRequest:(BOOL)jsonInRequest
                           andJsonInResponse:(BOOL)jsonInResponse {
    _manager.requestSerializer = jsonInRequest?[AFJSONRequestSerializer serializer]:[AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = jsonInResponse?[AFJSONResponseSerializer serializer]:[AFHTTPResponseSerializer serializer];
}

- (void)getAllStickerPacksForUser:(NSString *)user
                          success:(void(^)(NSArray *result))successCall
                          failure:(void(^)(NSError *error))failureCall {
    [self configWithExpectationOfJsonInRequest:NO
                             andJsonInResponse:YES];
    NSString *url = user.length == 0 ? [PQUrlService urlToGetAllStickerPacks] : [PQUrlService urlToGetAllStickerPacksForUser:user];
    [_manager GET:url
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

- (void)buyStickerPack:(NSString *)packId
               forUser:(NSString *)username
               success:(void(^)())successCall
               failure:(void(^)(NSError *error))failureCall {
    NSDictionary *param = @{@"pack_id":packId};
    [self configWithExpectationOfJsonInRequest:YES
                             andJsonInResponse:YES];
    [_manager POST:[PQUrlService urlToBuyStickerPackForUser:username]
        parameters:param
           success:^(NSURLSessionDataTask *task, id responseObject) {
               successCall();
           }
           failure:^(NSURLSessionDataTask *task, NSError *error) {
               failureCall(error);
           }];
}

- (void)registerWithServerForUser:(NSString *)username
                          success:(void(^)())successCall
                          failure:(void(^)(NSError *error))failureCall {
    NSDictionary *param = @{@"username":username};
    [self configWithExpectationOfJsonInRequest:YES
                             andJsonInResponse:YES];
    [_manager POST:[PQUrlService urlToGetAllUsers]
        parameters:param
           success:^(NSURLSessionDataTask *task, id responseObject) {
               successCall();
           }
           failure:^(NSURLSessionDataTask *task, NSError *error) {
               failureCall(error);
           }];
}

- (void)downloadAudioFileAtUrl:(NSString *)fileUrl
                      complete:(void(^)(NSURL *filepath))completeCall {
    NSURL *URL = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    if (_downloadTask) {
        [_downloadTask cancel];
    }
    
    _downloadTask
    = [_downloadManager downloadTaskWithRequest:request
                                       progress:nil
                                    destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                        return [PQFilePathFactory filePathInTemporaryDirectoryForFileName:[response suggestedFilename]];
                                    }
                              completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                  completeCall(filePath);
                              }];
    [_downloadTask resume];
}
@end
