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

@interface PQFriendListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
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

- (void)configUsingUser:(XMPPUserCoreDataStorageObject *)user {
    if (!self.avatarRounded) {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2;
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarRounded = YES;
    }
    self.nicknameLabel.text = user.nickname;
    self.usernameLabel.text = user.jid.user;
    if (user.photo != nil)
    {
        self.avatarImageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            self.avatarImageView.image = [UIImage imageWithData:photoData];
        else
            self.avatarImageView.image = [UIImage imageNamed:@"defaultavatar"];
    }
}

- (void)prepareForReuse {
    self.avatarImageView.image = [UIImage imageNamed:@"defaultavatar"];
}

@end
