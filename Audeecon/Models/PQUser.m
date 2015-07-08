//
//  PQUser.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQUser.h"

@implementation PQUser

- (id)initWithXMPPJID:(XMPPJID *)jid {
    if (self = [super init]) {
        _jid = jid;
        _username = [jid user];
    }
    return self;
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"jid"];
}

+ (NSString *)primaryKey {
    return @"username";
}

@end
