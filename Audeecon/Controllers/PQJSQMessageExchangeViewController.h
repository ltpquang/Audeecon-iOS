//
//  PQJSQMessageExchangeViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/6/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "XMPPFramework.h"
#import "PQMessageExchangeDelegate.h"

@interface PQJSQMessageExchangeViewController : JSQMessagesViewController <PQMessageExchangeDelegate>
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;
@end
