//
//  PQUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/16/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import <Realm.h>

@interface PQUser : NSObject

@property XMPPJID *jid;
@property NSString *displayName;

@end
RLM_ARRAY_TYPE(PQUser)
