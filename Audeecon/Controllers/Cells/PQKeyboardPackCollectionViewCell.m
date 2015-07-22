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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

@implementation PQKeyboardPackCollectionViewCell
+ (UINib *)nib {
    return [UINib nibWithNibName:@"KeyboardPackCollectionViewCell" bundle:nil];
}

+ (NSString *)reuseIdentifier {
    return @"KeyboardPackCollectionViewCell";
}

+ (CGSize)cellSize {
    return CGSizeMake(37, 35);
}

- (void)configCellUsingStickerPack:(PQStickerPack *)pack {
    if ([pack needToBeUpdated]) {
        self.mainImage.image = nil;
        [self.loadingIndicator startAnimating];
    }
    else {
        self.mainImage.image = pack.thumbnailImage;
        [self.loadingIndicator stopAnimating];
    }
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
