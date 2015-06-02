//
//  PQMessageExchangeDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PQMessageExchangeDelegate <NSObject>
- (void)didReceiveMessage:(NSDictionary *)messageContent;
@end