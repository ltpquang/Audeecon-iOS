//
//  PQLoginViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQStreamConnectDelegate.h"
#import "PQLoginDelegate.h"
#import "PQRegisterDelegate.h"
#import "PQvCardModuleDelegate.h"
#import <DBCameraViewController.h>
#import <MBProgressHUD.h>

@interface PQLoginViewController : UIViewController <PQLoginDelegate, PQStreamConnectDelegate, PQRegisterDelegate, PQvCardModuleDelegate, DBCameraViewControllerDelegate, MBProgressHUDDelegate>

@end
