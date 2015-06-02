//
//  PQFriendListDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PQFriendListDelegate <NSObject>
- (void)friendDidOnline:(NSString *)friendName;
- (void)friendDidOffline:(NSString *)friendName;
- (void)didDisconnect;
@end