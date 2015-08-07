//
//  PQFriendListTableViewCell.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/13/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "AppDelegate.h"
#import "PQFriendListTableViewCell.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "PQOtherUser.h"
#import "PQNotificationNameFactory.h"
#import "PQSticker.h"
#import "PQMessagingCenter.h"
#import <UIImageView+AFNetworking.h>
#import "PQColorProvider.h"

@interface PQFriendListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *onlineIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *lastMessageThumbnailImageView;
@property (strong, nonatomic) id<PQFriendListCellDelegate> delegate;
@property (strong, nonatomic) NSString *jidString;
@property BOOL firstTimeSetup;
@end

@implementation PQFriendListTableViewCell
#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configUsingUser:(PQOtherUser *)user
               delegate:(id<PQFriendListCellDelegate>)delegate {
    if (!self.firstTimeSetup) {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.borderWidth = 1.0;
        self.avatarImageView.layer.borderColor = [[PQColorProvider primaryColor] CGColor];
        self.delegate = delegate;
        [self setupCell];
        self.firstTimeSetup = YES;
    }
    self.jidString = user.jidString;
    self.nicknameLabel.text = user.nickname;
    self.usernameLabel.text = user.username;
    if (user.avatarData.length != 0) {
        self.avatarImageView.image = user.avatarImage;
    }
    if (user.isOnline) {
        [self.onlineIndicator setHidden:NO];
    }
    else {
        [self.onlineIndicator setHidden:YES];
    }
    
    PQMessagingCenter *center = [[self appDelegate] messagingCenter];
    [self configUIForUnacknownMessagesUsingMessagingCenter:center];
    [self configUIForLastMessageThumbnailUsingMessagingCenter:center];
    
    [self registerNotificationsWithUsername:user.username];
    
}

- (void)configUIForUnacknownMessagesUsingMessagingCenter:(PQMessagingCenter *)center {
    if ([center haveNewUnacknownMessagesWithJIDString:self.jidString]) {
        [self.nicknameLabel setTextColor:[PQColorProvider primaryComplement]];
    }
    else {
        [self.nicknameLabel setTextColor:[PQColorProvider primaryColor]];
    }
}

- (void)configUIForLastMessageThumbnailUsingMessagingCenter:(PQMessagingCenter *)center {
    PQSticker *sticker = [center lastIncomingMessageStickerForJIDString:self.jidString];
    if (sticker == nil) {
        self.lastMessageThumbnailImageView.hidden = YES;
        return;
    }
    if (sticker.thumbnailData.length != 0) {
        self.lastMessageThumbnailImageView.hidden = NO;
        self.lastMessageThumbnailImageView.image = sticker.thumbnailImage;
    }
    else {
        self.lastMessageThumbnailImageView.hidden = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stickerDidUpdateNotification:)
                                                     name:[PQNotificationNameFactory stickerCompletedDownloadingThumbnailImage:sticker.stickerId]
                                                   object:nil];
    }
}

- (void)registerNotificationsWithUsername:(NSString *)username {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAvatarNotification:)
                                                 name:[PQNotificationNameFactory userAvatarChanged:username]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNicknameNotification:)
                                                 name:[PQNotificationNameFactory userNicknameChanged:username]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveIsOnlineNotification:)
                                                 name:[PQNotificationNameFactory userOnlineStatusChanged:username]
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessageNotification:)
                                                 name:[PQNotificationNameFactory messageCompletedReceivingFromJIDString:self.jidString]
                                               object:nil];
    NSLog(@"%@ - Registered", [PQNotificationNameFactory userOnlineStatusChanged:username]);
}

- (void)receiveAvatarNotification:(NSNotification *)noti {
    self.avatarImageView.image = [(PQOtherUser *)noti.object avatarImage];
}

- (void)receiveNicknameNotification:(NSNotification *)noti {
    self.nicknameLabel.text = [(PQOtherUser *)noti.object nickname];
}

- (void)receiveIsOnlineNotification:(NSNotification *)noti {
    if ([(PQOtherUser *)noti.object isOnline]) {
        [self.onlineIndicator setHidden:NO];
    }
    else {
        [self.onlineIndicator setHidden:YES];
    }
}

- (void)stickerDidUpdateNotification:(NSNotification *)noti {
    UIImage *image = noti.userInfo[@"thumbnailImage"];
    self.lastMessageThumbnailImageView.hidden = NO;
    [self.lastMessageThumbnailImageView setImage:image];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[PQNotificationNameFactory stickerCompletedDownloadingThumbnailImage:[(PQSticker *)noti.object stickerId]]
                                                  object:nil];
}

- (void)receiveMessageNotification:(NSNotification *)noti {
    PQMessagingCenter *center = [[self appDelegate] messagingCenter];
    [self configUIForUnacknownMessagesUsingMessagingCenter:center];
    [self configUIForLastMessageThumbnailUsingMessagingCenter:center];
}

- (void)prepareForReuse {
    self.onlineIndicator.hidden = YES;
    self.lastMessageThumbnailImageView.hidden = NO;
    self.lastMessageThumbnailImageView.image = [UIImage imageNamed:@"defaultsmile"];
    self.avatarImageView.image = [UIImage imageNamed:@"defaultavatar"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setupCell {
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(longPressHandler:)];
    [longPressRecognizer setMinimumPressDuration:0.8];
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            //
            [self.delegate didStartHoldingOnCell:self];
            break;
//        case UIGestureRecognizerStateEnded:
//            //
//            [self.delegate didStopHoldingOnCell:self];
//            break;
        default:
            break;
    }
}
@end
