//
//  PQOtherUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/14/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import "PQUser.h"
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PQUserStatusOnline,
    PQUserStatusOffline,
    PQUserStatusAway,
} PQUserStatus;

@interface PQOtherUser : PQUser
@property (nonatomic) BOOL isOnline;
@property BOOL isUpdated;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQOtherUser>
RLM_ARRAY_TYPE(PQOtherUser)
