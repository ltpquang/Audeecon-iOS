//
//  PQStickerKeyboardCollectionViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQKeyboardStickerCollectionViewCell.h"
#import "PQStickerKeyboardView.h"

@interface PQStickerKeyboardCollectionViewController : UICollectionViewController
<PQKeyboardStickerCellDelegate>
- (id)initWithStickerPack:(PQStickerPack *)pack
                 andFrame:(CGRect)frame
                 delegate:(id<PQStickerKeyboardDelegate>) stickerKeyboardDelegate;
@property (nonatomic, weak) id<PQStickerKeyboardDelegate> stickerKeyboardDelegate;
@end
