//
//  PQStickerPackTableViewCell.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKDownloadButton.h"

@class PQStickerPack;
@class PQStickerPackDownloadManager;

@interface PQStickerPackTableViewCell : UITableViewCell <PKDownloadButtonDelegate>
- (void)configCellUsingStickerPack:(PQStickerPack *)pack;
@end
