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

@interface PQCurrentUser : PQUser
@property RLMArray<PQStickerPack> *ownedStickerPack;

- (void)updateOwnedStickerPackUsingQueue:(NSOperationQueue *)queue
                                 success:(void(^)())successCall
                                 failure:(void(^)(NSError *error))failureCall;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQCurrentUser>
RLM_ARRAY_TYPE(PQCurrentUser)
