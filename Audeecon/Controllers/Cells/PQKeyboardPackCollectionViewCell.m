//
//  PQKeyboardPackCollectionViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQKeyboardPackCollectionViewCell.h"
#import "PQStickerPack.h"

@interface PQKeyboardPackCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@end

@implementation PQKeyboardPackCollectionViewCell
+ (UINib *)nib {
    return [UINib nibWithNibName:@"KeyboardPackCollectionViewCell" bundle:nil];
}

+ (NSString *)reuseIdentifier {
    return @"KeyboardPackCollectionViewCell";
}

- (void)configCellUsingStickerPack:(PQStickerPack *)pack {
    _mainImage.image = pack.thumbnailImage;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
