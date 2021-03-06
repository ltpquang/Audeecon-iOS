//
//  PQMessageCollectionViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessageTableViewCell.h"
#import "PQMessage.h"
#import "PQSticker.h"
#import "UIImageView+AFNetworking.h"
#import "PQUser.h"
#import "PQNotificationNameFactory.h"
#import "PQColorProvider.h"

@interface PQMessageTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *readIndicatorLabel;


@property (weak, nonatomic) id<PQMessageTableViewCellDelegate> delegate;

@property BOOL imageRounded;

@end

@implementation PQMessageTableViewCell
- (void)configCellUsingMessage:(PQMessage *)message
                       andUser:(PQUser *)user
                      delegate:(id<PQMessageTableViewCellDelegate>)delegate {
    self.delegate = delegate;
    
    if (message.sticker.fullsizeData.length != 0) {
        self.mainImage.image = message.sticker.fullsizeImage;
    }
    else {
        //register for image update
        self.mainImage.image = [UIImage imageNamed:@"defaultsmile"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageCompletedDownloadFullsizeImageHandler:)
                                                     name:[PQNotificationNameFactory stickerCompletedDownloadingFullsizeImage:message.sticker.stickerId]
                                                   object:nil];
    }
    
    if (message.isOutgoing) {
        if (message.onlineAudioUri.length == 0) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(messageCompletedSendingHandler:)
                                                         name:[PQNotificationNameFactory messageCompletedSending:message.messageId]
                                                       object:nil];
            self.mainImage.alpha = 0.4;
        }
        [self.readIndicatorLabel setHidden:YES];
    }
    else {
        if (message.offlineAudioUri.length == 0) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(messageCompletedDownloadingHandler:)
                                                         name:[PQNotificationNameFactory messageCompletedDownloading:message.messageId]
                                                       object:nil];
            self.mainImage.alpha = 0.4;
        }
        
        if (message.isRead) {
            [self.readIndicatorLabel setHidden:NO];
        }
        else {
            [self.readIndicatorLabel setHidden:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(messageDidChangeReadStatus:)
                                                         name:[PQNotificationNameFactory messageDidChangeReadStatus:message.messageId]
                                                       object:nil];
        }
    }
    
    if (user.avatarData.length != 0) {
        self.avatarImage.image = user.avatarImage;
    }
    else {
        //register for image update
    }
    
    
    [self configRoundImage];
    [self setupCell];
}

- (void)messageCompletedSendingHandler:(NSNotification *)noti {
    self.mainImage.alpha = 1.0;
}

- (void)messageCompletedDownloadFullsizeImageHandler:(NSNotification *)noti {
    self.mainImage.image = [(PQSticker *)noti.object fullsizeImage];
}

- (void)messageCompletedDownloadingHandler:(NSNotification *)noti {
    NSLog(@"%@", noti.name);
    self.mainImage.alpha = 1.0;
    self.mainImage.image = [[(PQMessage *)noti.object sticker] fullsizeImage];
}

- (void)messageDidChangeReadStatus:(NSNotification *)noti {
    [self.readIndicatorLabel setHidden:NO];
}

- (void)configRoundImage {
    if (self.imageRounded) {
        return;
    }
    self.avatarImage.layer.borderColor = [[PQColorProvider primaryColor] CGColor];
    self.avatarImage.layer.borderWidth = 1.0;
    self.avatarImage.layer.cornerRadius = self.avatarImage.bounds.size.width / 2.0;
    self.avatarImage.layer.masksToBounds = YES;
    self.imageRounded = YES;
    
}

- (void)prepareForReuse {
    self.mainImage.image = [UIImage imageNamed:@"defaultsmile"];
    self.avatarImage.image = [UIImage imageNamed:@"defaultavatar"];
    self.mainImage.alpha = 1.0;
    self.readIndicatorLabel.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
            [self.delegate didStartHoldingOnCell:self];
            break;
        case UIGestureRecognizerStateEnded:
            //
            [self.delegate didStopHoldingOnCell:self];
            break;
        default:
            break;
    }
}
@end
