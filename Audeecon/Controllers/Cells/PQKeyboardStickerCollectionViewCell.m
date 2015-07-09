//
//  PQKeyboardStickerCollectionViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/21/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQKeyboardStickerCollectionViewCell.h"
#import "PQSticker.h"

@interface PQKeyboardStickerCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@end

@implementation PQKeyboardStickerCollectionViewCell
+ (UINib *)nib {
    return [UINib nibWithNibName:@"KeyboardStickerCollectionViewCell" bundle:nil];
}

+ (NSString *)reuseIdentifier {
    return @"KeyboardStickerCollectionViewCell";
}

+ (CGSize)cellSize {
    return CGSizeMake(60, 60);
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupCell];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupCell];
    }
    return self;
}

- (void)configCellUsingSticker:(PQSticker *)sticker
                      delegate:(id<PQKeyboardStickerCellDelegate>)delegate {
    _mainImage.image = sticker.thumbnailImage;
    if (!_delegate) {
        _delegate = delegate;
    }
}

- (void)setupCell {
    //self.backgroundColor = [UIColor darkGrayColor];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(longPressHandler:)];
    [longPressRecognizer setMinimumPressDuration:0.25];
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            //
            [_delegate didStartHoldingOnCell:self];
            break;
        case UIGestureRecognizerStateEnded:
            //
            [_delegate didStopHoldingOnCell:self];
            break;
        default:
            break;
    }
}
@end
