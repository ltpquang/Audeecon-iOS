//
//  PQCurrentUser.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQCurrentUser.h"
#import "PQRequestingService.h"
#import "PQStickerPack.h"
#import <Realm.h>

@implementation PQCurrentUser

- (BOOL)stickerPacksNeedToBeReplacedByStickerPacks:(NSArray *)newArray {
    NSArray *oldIds = [self.ownedStickerPack valueForKeyPath:@"packId"];
    NSArray *newIds = [newArray valueForKeyPath:@"packId"];
    
    NSCountedSet *oldSet = [NSCountedSet setWithArray:oldIds];
    NSCountedSet *newSet = [NSCountedSet setWithArray:newIds];
    
    return ![oldSet isEqualToSet:newSet];
}

- (void)updateOwnedStickerPackUsingQueue:(NSOperationQueue *)queue
                                 success:(void(^)())successCall
                                 failure:(void(^)(NSError *error))failureCall {
    PQRequestingService *requestingService = [PQRequestingService new];
    [requestingService getAllStickerPacksForUser:self.username
                                         success:^(NSArray *result) {
                                             
                                             RLMRealm *realm = [RLMRealm defaultRealm];
                                             if ([self stickerPacksNeedToBeReplacedByStickerPacks:result]) {
                                                 [realm beginWriteTransaction];
                                                 
                                                 [realm deleteObjects:self.ownedStickerPack];
                                                 [self.ownedStickerPack removeAllObjects];
                                                 
                                                 for (PQStickerPack *pack in result) {
                                                     PQStickerPack *returnPack = [PQStickerPack createOrUpdateInDefaultRealmWithValue:pack];
                                                     [self.ownedStickerPack addObject:returnPack];
                                                 }
                                                 
                                                 [realm commitWriteTransaction];
                                             }
                                             
                                             NSBlockOperation *ope = [NSBlockOperation blockOperationWithBlock:^{
                                                 successCall();
                                             }];
                                             
                                             for (PQStickerPack *pack in self.ownedStickerPack) {
                                                 [ope addDependency:[pack downloadDataAndStickersUsingOperationQueue:queue]];
                                             }
                                             [queue addOperation:ope];
                                         }
                                         failure:^(NSError *error) {
                                             //
                                             failureCall(error);
                                         }];
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
