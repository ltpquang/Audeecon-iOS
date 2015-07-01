//
//  PQStreamConnectDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/10/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PQStreamConnectDelegate <NSObject>
- (void)xmppStreamDidConnect;
- (void)xmppStreamConnectDidTimeOut;
@end
