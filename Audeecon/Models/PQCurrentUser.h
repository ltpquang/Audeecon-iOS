//
//  PQCurrentUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import "PQStickerPack.h"
#import "PQUser.h"
#import "PQOtherUser.h"
#import "XMPP.h"
#import "PQRealmString.h"

@interface PQCurrentUser : PQUser
@property RLMArray<PQOtherUser> *friends;
@property RLMArray<PQStickerPack> *ownedStickerPack;
//Excluded
@property (nonatomic) NSMutableArray *awatingJIDs;

- (void)updateOwnedStickerPackUsingQueue:(NSOperationQueue *)queue
                                 success:(void(^)())successCall
                                 failure:(void(^)(NSError *error))failureCall;

- (void)updateFriendListUsingXMPPJID:(XMPPJID *)jid;
- (void)markFriendListForUpdating;
- (void)removeNotUpdatedFriends;
- (void)updateInfoForFriendWithXMPPJID:(XMPPJID *)jid
                        usingvCardTemp:(XMPPvCardTemp *)vCard;
- (void)addAwaitingJid:(XMPPJID *)awaitingJid;
- (XMPPJID *)awaitingJidToProcess;

- (void)updateFriendListUsingPresence:(XMPPPresence *)presence;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQCurrentUser>
RLM_ARRAY_TYPE(PQCurrentUser)
