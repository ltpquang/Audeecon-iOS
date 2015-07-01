//
//  PQKeyboardPackCollectionViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PQStickerPack;

@interface PQKeyboardPackCollectionViewCell : UICollectionViewCell
+ (UINib *)nib;
+ (NSString *)reuseIdentifier;

- (void)configCellUsingStickerPack:(PQStickerPack *)pack;
- (void)resetContent;
@end
