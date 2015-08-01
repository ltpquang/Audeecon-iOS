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

@interface PQFriendListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *onlineIndicator;
@property (strong, nonatomic) id<PQFriendListCellDelegate> delegate;
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
        self.delegate = delegate;
        [self setupCell];
        self.firstTimeSetup = YES;
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

- (void)prepareForReuse {
    self.onlineIndicator.hidden = YES;
    self.avatarImageView.image = [UIImage imageNamed:@"defaultavatar"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setupCell {
    //self.backgroundColor = [UIColor darkGrayColor];
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
