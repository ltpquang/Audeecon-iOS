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
#import "AppDelegate.h"
#import "PQStickerPackDownloadManager.h"
#import "PQNotificationNameFactory.h"
#import <Realm.h>
#import "PQCurrentUser.h"

@interface PQStickerPackTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet PKDownloadButton *downloadButton;
@property (strong, nonatomic) PQStickerPack *pack;
@property (strong, nonatomic) PQStickerPackDownloadManager *stickerPackDownloadManager;
@end

@implementation PQStickerPackTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configCellUsingStickerPack:(PQStickerPack *)pack {
    self.pack = pack;
    self.stickerPackDownloadManager = [[self appDelegate] stickerPackDownloadManager];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusChanged:)
                                                 name:[PQNotificationNameFactory stickerPackChangedStatus:self.pack.packId]
                                               object:nil];
    [self evaluateStatusAndUpdateDownloadButton];
}

- (void)prepareForReuse {
    self.mainImage.image = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)evaluateStatusAndUpdateDownloadButton {
    StickerPackStatus status = [self.stickerPackDownloadManager statusForStickerPackWithId:self.pack.packId];
    switch (status) {
        case StickerPackStatusNotAvailable:
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        case StickerPackStatusPending:
            self.downloadButton.state = kPKDownloadButtonState_Pending;
            break;
        case StickerPackStatusDownloading:
            self.downloadButton.state = kPKDownloadButtonState_Downloading;
            NSInteger percentage = [self.stickerPackDownloadManager progressForStickerPackWithId:self.pack.packId];
            self.downloadButton.stopDownloadButton.progress = (float)percentage/100.0;
            break;
        case StickerPackStatusDownloaded:
            self.downloadButton.state = kPKDownloadButtonState_Downloaded;
            break;
    }
}

- (void)statusChanged:(NSNotification *)notification {
    [self evaluateStatusAndUpdateDownloadButton];
}

- (void)downloadButtonTapped:(PKDownloadButton *)downloadButton currentState:(PKDownloadButtonState)state {
    switch (state) {
        case kPKDownloadButtonState_StartDownload: {
            self.downloadButton.state = kPKDownloadButtonState_Pending;
            // Download sticker pack info
            [[[self appDelegate] currentUser] downloadStickerPackFromTheStore:self.pack];
            break;
        }
        case kPKDownloadButtonState_Pending: {
            // Cancel download
            [[[self appDelegate] currentUser] removeStickerPack:self.pack];
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        }
        case kPKDownloadButtonState_Downloading: {
            // Cancel download
            [[[self appDelegate] currentUser] removeStickerPack:self.pack];
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            break;
        }
        case kPKDownloadButtonState_Downloaded: {
            [[[self appDelegate] currentUser] removeStickerPack:self.pack];
            self.downloadButton.state = kPKDownloadButtonState_StartDownload;
            // Delete pack
            break;
        }
        default:
            NSAssert(NO, @"unsupported state");
            break;
    }
}
#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
