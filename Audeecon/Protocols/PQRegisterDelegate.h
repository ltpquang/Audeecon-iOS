//
//  PQRegisterDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol PQRegisterDelegate <NSObject>
- (void)registerDidSuccess;
- (void)registerDidNotSuccess:(DDXMLElement *)error;
@end
