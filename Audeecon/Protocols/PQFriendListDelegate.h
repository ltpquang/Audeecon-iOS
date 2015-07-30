//
//  PQFriendListDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDXML.h"

@protocol PQFriendListDelegate <NSObject>

- (void)friendListDidUpdate;

- (void)didDisconnect;
@end
