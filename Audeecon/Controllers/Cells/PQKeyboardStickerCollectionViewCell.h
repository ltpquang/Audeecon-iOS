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
+ (CGSize)cellSize;

- (void)configCellUsingSticker:(PQSticker *)sticker
                      delegate:(id<PQKeyboardStickerCellDelegate>)delegate;

@end


@protocol PQKeyboardStickerCellDelegate

- (void)didStartHoldingOnCell:(UICollectionViewCell *)cell withGesture:(UIGestureRecognizer *)gesture;
- (void)didStopHoldingOnCell:(UICollectionViewCell *)cell withGesture:(UIGestureRecognizer *)gesture;

@end