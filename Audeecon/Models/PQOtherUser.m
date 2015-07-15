//
//  PQOtherUser.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/14/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQOtherUser.h"

@implementation PQOtherUser

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"status",
             @"isUpdated"];
}

@end
