//
//  PQUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import "XMPP.h"

@interface PQUser : RLMObject
@property XMPPJID *jid;
@property NSString *username;

- (id)initWithXMPPJID:(XMPPJID *)jid;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQUser>
RLM_ARRAY_TYPE(PQUser)
