//
//  PQStickerKeyboardView.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQKeyboardStickerCollectionViewCell.h"

@class PQSticker;
@class PQStickerPack;

@protocol PQStickerKeyboardDelegate;

@interface PQStickerKeyboardView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
- (void)configKeyboard;
//- (void)reloadKeyboardUsingPacks:(NSArray *)packs;
- (void)addToSuperview:(UIView *)superview;

@property (nonatomic, weak) id<PQStickerKeyboardDelegate> delegate;
@end


@protocol PQStickerKeyboardDelegate

- (void)didStartHoldingOnSticker:(PQSticker *)sticker
                     withGesture:(UIGestureRecognizer *)gesture;
- (void)didStopHoldingOnSticker:(PQSticker *)sticker
                    withGesture:(UIGestureRecognizer *)gesture;
- (void)keyboardDidChangeLayout;

@end