//
//  PQFriendListTableViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/13/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMPPUserCoreDataStorageObject;
@class PQOtherUser;

@protocol PQFriendListCellDelegate;

@interface PQFriendListTableViewCell : UITableViewCell
//- (void)configUsingUser:(XMPPUserCoreDataStorageObject *)user;
- (void)configUsingUser:(PQOtherUser *)user
               delegate:(id<PQFriendListCellDelegate>)delegate;
@end

@protocol PQFriendListCellDelegate <NSObject>

- (void)didStartHoldingOnCell:(UITableViewCell *)cell;

@end