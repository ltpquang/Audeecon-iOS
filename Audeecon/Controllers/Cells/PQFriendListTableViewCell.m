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

@interface PQFriendListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *onlineIndicator;
@property BOOL avatarRounded;
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

- (void)configUsingUser:(PQOtherUser *)user {
    if (!self.avatarRounded) {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarRounded = YES;
    }
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
    
    [self registerNotificationsWithUsername:user.username];
    
}

- (void)registerNotificationsWithUsername:(NSString *)username {
    NSString *avatarNotiName = [username stringByAppendingString:@"AvatarChanged"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveAvatarNotification:) name:avatarNotiName object:nil];
    
    NSString *nicknameNotiName = [username stringByAppendingString:@"NicknameChanged"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNicknameNotification:) name:nicknameNotiName object:nil];
    
    NSString *isOnlineNotiName = [username stringByAppendingString:@"IsOnlineChanged"];
    //NSLog(@"Registered: %@", isOnlineNotiName);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIsOnlineNotification:) name:isOnlineNotiName object:nil];
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

- (void)prepareForReuse {
    self.onlineIndicator.hidden = YES;
    self.avatarImageView.image = [UIImage imageNamed:@"defaultavatar"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
