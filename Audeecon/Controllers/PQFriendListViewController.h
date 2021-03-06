//
//  PQFriendListViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PQStreamConnectDelegate.h"
#import "PQLoginDelegate.h"
#import "PQFriendListDelegate.h"
#import "PQFriendListTableViewCell.h"
#import <DBCameraViewController.h>
#import <MBProgressHUD.h>
#import "PQvCardModuleDelegate.h"

@interface PQFriendListViewController : UIViewController
<UITableViewDataSource,
UITableViewDelegate,
PQStreamConnectDelegate,
PQLoginDelegate,
PQFriendListDelegate,
NSFetchedResultsControllerDelegate,
UIAlertViewDelegate,
PQFriendListCellDelegate,
UIActionSheetDelegate,
DBCameraViewControllerDelegate,
MBProgressHUDDelegate,
PQvCardModuleDelegate>


@end
