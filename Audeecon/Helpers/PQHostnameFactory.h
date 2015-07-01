//
//  PQHostnameFactory.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQHostnameFactory : NSObject
+ (NSString *)hostnameString;
+ (NSString *)nicknameWithHostName:(NSString *)nickname;
@end
