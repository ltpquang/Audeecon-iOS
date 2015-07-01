//
//  PQHostnameFactory.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQHostnameFactory.h"

@implementation PQHostnameFactory
+ (NSString *)hostnameString {
    return @"ec2-52-74-63-154.ap-southeast-1.compute.amazonaws.com";
    //return @"les-macbook-pro.local";
}

+ (NSString *)nicknameWithHostName:(NSString *)nickname {
    return [NSString stringWithFormat:@"%@@%@",nickname, [self hostnameString]];
}

+ (NSString *)nicknameWithoutHostName:(NSString *)nickname {
    NSString *toRemove = [NSString stringWithFormat:@"@%@", [self hostnameString]];
    NSString *result = [nickname stringByReplacingOccurrencesOfString:toRemove withString:@""];
    return result;
}
@end
