//
//  PQMessageCollectionViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PQMessage;
@class PQUser;

@protocol PQMessageTableViewCellDelegate;

@interface PQMessageTableViewCell : UITableViewCell

- (void)configCellUsingMessage:(PQMessage *)message
                       andUser:(PQUser *)user
                      delegate:(id<PQMessageTableViewCellDelegate>)delegate;
@end

@protocol PQMessageTableViewCellDelegate <NSObject>

- (void)didStartHoldingOnCell:(UITableViewCell *)cell;
- (void)didStopHoldingOnCell:(UITableViewCell *)cell;

@end