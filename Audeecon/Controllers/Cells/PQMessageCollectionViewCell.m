//
//  PQMessageCollectionViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageCollectionViewCell.h"
#import "PQMessage.h"
#import "PQSticker.h"
#import "UIImageView+AFNetworking.h"

@interface PQMessageCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) id<PQMessageCollectionViewCellDelegate> delegate;

@end

@implementation PQMessageCollectionViewCell
- (void)configCellUsingMessage:(PQMessage *)message
                      delegate:(id<PQMessageCollectionViewCellDelegate>)delegate {
    _mainImage.image = nil;
    _delegate = delegate;
    NSURL *url = [NSURL URLWithString:message.stickerUri];
    NSLog(@"%@", url);
    [_mainImage setImageWithURL:url];
}

- (void)reshowPlayButton {
    [_playButton setHidden:NO];
}

- (IBAction)playButtonTUI:(id)sender {
    [_playButton setHidden:YES];
    [_delegate didReceiveRequestToPlayCell:self];
}
@end
