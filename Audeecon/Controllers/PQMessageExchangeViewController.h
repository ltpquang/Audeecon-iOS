//
//  PQMessageExchangeViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQMessageExchangeDelegate.h"
#import "XMPPFramework.h"

@interface PQMessageExchangeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PQMessageExchangeDelegate>
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;
@end
