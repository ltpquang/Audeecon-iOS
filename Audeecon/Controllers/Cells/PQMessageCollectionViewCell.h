//
//  PQMessageCollectionViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PQMessage;

@protocol PQMessageCollectionViewCellDelegate;

@interface PQMessageCollectionViewCell : UICollectionViewCell

- (void)configCellUsingMessage:(PQMessage *)message
                      delegate:(id<PQMessageCollectionViewCellDelegate>)delegate;
- (void)reshowPlayButton;
@end

@protocol PQMessageCollectionViewCellDelegate <NSObject>

- (void)didReceiveRequestToPlayCell:(PQMessageCollectionViewCell *)cell;

@end