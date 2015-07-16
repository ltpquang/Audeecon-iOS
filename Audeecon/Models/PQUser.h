//
//  PQUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>
#import "XMPP.h"

@class XMPPvCardTemp;

@interface PQUser : RLMObject
@property NSString *jidString;
@property NSString *username;
@property NSString *nickname;
@property NSData *avatarData;
@property NSString *avatarUrl;

//Excluded
@property (nonatomic) UIImage *avatarImage;


- (id)initWithXMPPJID:(XMPPJID *)jid;

- (void)updateInfoUsingvCard:(XMPPvCardTemp *)vCard;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQUser>
RLM_ARRAY_TYPE(PQUser)
