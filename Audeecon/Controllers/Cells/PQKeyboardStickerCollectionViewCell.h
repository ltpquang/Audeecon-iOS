//
//  PQKeyboardStickerCollectionViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PQSticker;

@protocol PQKeyboardStickerCellDelegate;

@interface PQKeyboardStickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<PQKeyboardStickerCellDelegate> delegate;


+ (UINib *)nib;
+ (NSString *)reuseIdentifier;

- (void)configCellUsingSticker:(PQSticker *)sticker
                      delegate:(id<PQKeyboardStickerCellDelegate>)delegate;

@end


@protocol PQKeyboardStickerCellDelegate

- (void)didStartHoldingOnCell:(UICollectionViewCell *)cell;
- (void)didStopHoldingOnCell:(UICollectionViewCell *)cell;

@end