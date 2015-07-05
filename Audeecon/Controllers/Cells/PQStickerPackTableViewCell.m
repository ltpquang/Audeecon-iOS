//
//  PQStickerPackTableViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPackTableViewCell.h"
#import "PQStickerPack.h"
#import "UIImageView+AFNetworking.h"

@interface PQStickerPackTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet PKDownloadButton *downloadButton;

@end

@implementation PQStickerPackTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configCellUsingStickerPack:(PQStickerPack *)pack {
    self.nameLabel.text = pack.name;
    self.artistLabel.text = pack.artist;
    self.descriptionLabel.text = pack.packDescription;
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.numberOfLines = 0;
    CGSize labelSize = [self.descriptionLabel.text sizeWithAttributes:@{NSFontAttributeName:self.descriptionLabel.font}];
    
    self.descriptionLabel.frame = CGRectMake(
                             self.descriptionLabel.frame.origin.x, self.descriptionLabel.frame.origin.y,
                             self.descriptionLabel.frame.size.width, labelSize.height);
    [self.mainImage setImageWithURL:[NSURL URLWithString:pack.thumbnailUri]];
    self.downloadButton.state = kPKDownloadButtonState_StartDownload;
    NSLog(@"%@", self.downloadButton);
}

- (void)prepareForReuse {
    self.mainImage.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton currentState:(PKDownloadButtonState)state {
    switch (state) {
        case kPKDownloadButtonState_StartDownload:
            self.downloadButton.state = kPKDownloadButtonState_Pending;
            // Download sticker pack info
            break;
        case kPKDownloadButtonState_Pending:
            // Cancel download
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        case kPKDownloadButtonState_Downloading:
            // Cancel download
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        case kPKDownloadButtonState_Downloaded:
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            // Delete pack
            break;
        default:
            NSAssert(NO, @"unsupported state");
            break;
    }
}


@end
