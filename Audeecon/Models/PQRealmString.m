//
//  PQRealmString.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/15/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQRealmString.h"

@implementation PQRealmString

- (id)initWithNSString:(NSString *)string {
    if (self = [super init]) {
        _string = string;
    }
    return self;
}

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"string":@""};
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
