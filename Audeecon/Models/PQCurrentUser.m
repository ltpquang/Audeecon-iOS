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
#import "PQNotificationNameFactory.h"
#import "AppDelegate.h"

@implementation PQCurrentUser

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSMutableArray *)awatingJIDs {
    if (!_awatingJIDs) {
        _awatingJIDs = [NSMutableArray new];
    }
    return  _awatingJIDs;
}

#pragma mark - Stickers managing
- (BOOL)stickerPacksNeedToBeReplacedByStickerPacks:(NSArray *)newArray {
    NSArray *oldIds = [self.ownedStickerPack valueForKeyPath:@"packId"];
    NSArray *newIds = [newArray valueForKeyPath:@"packId"];
    
    NSCountedSet *oldSet = [NSCountedSet setWithArray:oldIds];
    NSCountedSet *newSet = [NSCountedSet setWithArray:newIds];
    
    return ![oldSet isEqualToSet:newSet];
}

- (void)updateListOfOwnedStickerPackUsingReturnedList:(NSArray *)returned {
    NSArray *oldIds = [self.ownedStickerPack valueForKey:@"packId"];
    NSArray *newIds = [returned valueForKey:@"packId"];
    
    NSSet *oldSet = [NSSet setWithArray:oldIds];
    NSSet *newSet = [NSSet setWithArray:newIds];
    
    NSMutableSet *toRemove = [NSMutableSet new];
    [toRemove setSet:oldSet];
    [toRemove minusSet:newSet];
    
    NSMutableSet *toAdd = [NSMutableSet new];
    [toAdd setSet:newSet];
    [toAdd minusSet:oldSet];
    
    for (int i = self.ownedStickerPack.count-1; i >= 0; --i) {
        NSString *packId = [(PQStickerPack *)self.ownedStickerPack[i] packId];
        if ([toRemove containsObject:packId]) {
            [self.ownedStickerPack removeObjectAtIndex:i];
        }
    }
    
    for (PQStickerPack *pack in returned) {
        if ([toAdd containsObject:pack.packId]) {
            PQStickerPack *newPack = [PQStickerPack createOrUpdateInDefaultRealmWithValue:pack];
            [self.ownedStickerPack addObject:newPack];
        }
    }
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
                                                 [self updateListOfOwnedStickerPackUsingReturnedList:result];
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
                                             //This notification is used to notify the keyboard about there are incoming sticker packs, but the packs' data is not ready, so that the sticker keyboard can show up loading indicators
                                             [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory ownedStickerPacksDidUpdate] object:nil];
                                         }
                                         failure:^(NSError *error) {
                                             //
                                             failureCall(error);
                                         }];
}

- (void)downloadStickerPackFromTheStore:(PQStickerPack *)pack {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    PQStickerPack *newPack = [PQStickerPack createOrUpdateInDefaultRealmWithValue:pack];
    [[self ownedStickerPack] addObject:newPack];
    NSOperationQueue *queue = [[[self appDelegate] globalContainer] stickerPackDownloadQueue];
    [[[self appDelegate] stickerPackDownloadManager] downloadStickerPack:newPack
                                                    usingDownloadQueue:queue];
    [realm commitWriteTransaction];
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory ownedStickerPacksDidUpdate] object:nil];
}

- (void)removeStickerPack:(PQStickerPack *)pack {
    [[[self appDelegate] stickerPackDownloadManager] cancelStickPack:pack];
    [[PQRequestingService new] unBuyStickerPack:pack.packId
                                        forUser:self.username
                                        success:^{
                                            RLMRealm *realm = [RLMRealm defaultRealm];
                                            [realm beginWriteTransaction];
                                            NSUInteger removed = [[self ownedStickerPack] indexOfObject:pack];
                                            if (removed != NSNotFound) {
                                                [[self ownedStickerPack] removeObjectAtIndex:removed];
                                            }
                                            //[realm deleteObject:pack];
                                            [realm commitWriteTransaction];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory ownedStickerPacksDidUpdate] object:nil];
                                        }
                                        failure:^(NSError *error) {
                                            NSLog(@"Unbuy failed");
                                        }];
}

#pragma mark - Friends managing
- (void)updateFriendListUsingXMPPJID:(XMPPJID *)jid {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if ([jid.user isEqualToString:self.username]) {
        [realm commitWriteTransaction];
        return;
    }
    for (PQOtherUser *user in self.friends) {
        if ([user.username isEqualToString:jid.user]) {
            user.jidString = jid.bare;
            user.isUpdated = YES;
            [realm commitWriteTransaction];
            return;
        }
    }
    PQOtherUser *user = [[PQOtherUser alloc] initWithXMPPJID:jid];
    user.isUpdated = YES;
    [self.friends addObject:user];
    [realm commitWriteTransaction];
    
}

- (void)markFriendListForUpdating {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (PQOtherUser *user in self.friends) {
        user.isUpdated = NO;
        user.isOnline = NO;
    }
    [realm commitWriteTransaction];
}
- (void)removeNotUpdatedFriends {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (int i = self.friends.count - 1; i >= 0; --i) {
        PQOtherUser *user = [self.friends objectAtIndex:i];
        if (!user.isUpdated) {
            [self.friends removeObjectAtIndex:i];
            [realm deleteObject:user];
        }
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory userFriendRequestListChanged]
                                                        object:nil];
}

- (XMPPJID *)awaitingJidToProcess {
    XMPPJID *result = self.awatingJIDs.firstObject;
    [self.awatingJIDs removeObjectAtIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory userFriendRequestListChanged]
                                                        object:nil];
    return result;
}

- (void)updateFriendListUsingPresence:(XMPPPresence *)presence {
    NSString *presenceType = [presence type]; // online/offline
    NSString *presenceFromUser = [[presence from] user];
    for (PQOtherUser *user in self.friends) {
        if ([user.username isEqualToString:presenceFromUser]) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            if ([presenceType isEqualToString:@"available"]) {
                user.isOnline = YES;
            }
            else if ([presenceType isEqualToString:@"unavailable"]) {
                user.isOnline = NO;
            }
            [realm commitWriteTransaction];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory userOnlineStatusChanged:user.username]
                                                                object:user];
            NSLog(@"%@ - Posted", [PQNotificationNameFactory userOnlineStatusChanged:self.username]);
        }
    }
}

- (void)removeFriendWithJID:(XMPPJID *)jid {
    [[[self appDelegate] xmppRoster] removeUser:jid];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    for (int i = 0; i < self.friends.count; ++i) {
        PQOtherUser *toRemove = self.friends[i];
        if ([toRemove.username isEqualToString:jid.user]) {
            [self.friends removeObjectAtIndex:i];
            [realm deleteObject:toRemove];
        }
    }
    [realm commitWriteTransaction];
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
