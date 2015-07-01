//
//  PQUser.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/16/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"

@interface PQUser : NSObject

@property (strong, nonatomic) XMPPJID *jid;
@property (strong, nonatomic) NSString *jidString;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *displayName;

@end
