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
#import "XMPPvCardTemp.h"

@implementation PQCurrentUser

- (NSMutableArray *)awatingJIDs {
    if (!_awatingJIDs) {
        _awatingJIDs = [NSMutableArray new];
    }
    return  _awatingJIDs;
}

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
                                                 NSLog(@"Finish block called in current user");
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


- (void)updateFriendListUsingXMPPJID:(XMPPJID *)jid {
    if ([jid.user isEqualToString:self.username]) {
        return;
    }
    for (PQOtherUser *user in self.friends) {
        if ([user.username isEqualToString:jid.user]) {
            user.jid = jid;
            user.isUpdated = YES;
            return;
        }
    }
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [self.friends addObject:[[PQOtherUser alloc] initWithXMPPJID:jid]];
    [realm commitWriteTransaction];
    
}


- (void)updateInfoForFriendWithXMPPJID:(XMPPJID *)jid
                        usingvCardTemp:(XMPPvCardTemp *)vCard {
    if ([jid.user isEqualToString:self.username]) {
        [self updateInfoUsingvCard:vCard];
        return;
    }
    
    for (PQOtherUser *user in self.friends) {
        if ([user.username isEqualToString:jid.user]) {
            [user updateInfoUsingvCard:vCard];
            return;
        }
    }
}

- (void)addAwaitingJid:(XMPPJID *)awaitingJid {
    [self.awatingJIDs addObject:awaitingJid];
}

- (XMPPJID *)awaitingJidToProcess {
    XMPPJID *result = self.awatingJIDs.firstObject;
    [self.awatingJIDs removeObjectAtIndex:0];
    return result;
}
// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"awatingJIDs"];
}

@end
