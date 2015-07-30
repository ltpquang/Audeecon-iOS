//
//  PQFriendListViewController.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/20/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQFriendListViewController.h"
#import "AppDelegate.h"
#import "PQLoginViewController.h"
#import "PQMessageExchangeViewController.h"
#import "XMPPvCardTemp.h"
#import "PQHostnameFactory.h"
#import "PQCurrentUser.h"
#import "PQNotificationNameFactory.h"

@interface PQFriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (strong, nonatomic) RLMArray<PQOtherUser> *friends;
@property (strong, nonatomic) UIImageView *profilePicture;
@property BOOL isUISet;
@end

@implementation PQFriendListViewController

#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Friends";
    [[self appDelegate] setStreamConnectDelegate:self];
    [[self appDelegate] setLoginDelegate:self];
    [[self appDelegate] setFriendListDelegate:self];
    if ([[[self appDelegate] xmppStream] isDisconnected]) {
        [[self appDelegate] connect];
    }
    if (!self.isUISet && [[self appDelegate] currentUser] != nil) {
        [self setupUI];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLogin {
    UIStoryboard *sb = [self storyboard];
    PQLoginViewController *loginVC = [sb instantiateViewControllerWithIdentifier:@"LoginView"];
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)registerForNotifications {
    PQUser *user = [[self appDelegate] currentUser];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avatarChangedHandler:)
                                                 name:[PQNotificationNameFactory userAvatarChanged:user.username]
                                               object:nil];
}

- (void)avatarChangedHandler:(NSNotification *)noti {
    self.profilePicture.image = [(PQUser *)noti.object avatarImage];
}

- (void)setupUI {
    [self setupAddFriendButton];
    [self setupInfoButton];
    [self registerForNotifications];
    self.isUISet = YES;
}
#pragma mark - Info button 
- (void)setupInfoButton {
    PQUser *user = [[self appDelegate] currentUser];
    self.profilePicture = user.avatarData.length > 0 ?
    [[UIImageView alloc] initWithImage:user.avatarImage]:
    [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultavatar"]];
    
    self.profilePicture.layer.cornerRadius = 12.0;
    self.profilePicture.layer.masksToBounds = YES;
    [self.profilePicture setFrame:CGRectMake(0, 0, 36, 36)];
    [self.profilePicture addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(infoButtonTUI:)]];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithCustomView:self.profilePicture];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    spacer.width = -4;
    self.navigationItem.leftBarButtonItems = @[spacer, infoButton];
}

- (void)infoButtonTUI:(UIGestureRecognizer *)sender {
    UIActionSheet *infoSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Sign out", nil];
    infoSheet.tag = 1;
    [infoSheet showInView:self.view];
}

#pragma mark - Add friends
- (void)setupAddFriendButton {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addButtonTUI:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)addButtonTUI:(UIButton *)sender {
    if ([[[[self appDelegate] currentUser] awatingJIDs] count] != 0) {
        XMPPJID *awaitingJid = [[[[self appDelegate] currentUser] awatingJIDs] objectAtIndex:0];
        [self confirmFriendRequestAlertViewForJID:awaitingJid];
    }
    else {
        [self addFriendAlertView];
    }
}

- (void)addFriendAlertView {
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Add a friend"
                                                 message:@"Input friend's username"
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Add",nil];
    al.alertViewStyle = UIAlertViewStylePlainTextInput;
    al.tag = 0;
    [al show];
}

- (void)confirmFriendRequestAlertViewForJID:(XMPPJID *)jid {
    NSString *message = [NSString stringWithFormat:@"'%@' requested to add you as a friend.", jid.user];
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Friend request"
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"Decline"
                                       otherButtonTitles:@"Accept", nil];
    al.tag = 1;
    [al show];
}

- (void)rejectFirstAwaitingFriendRequest {
    XMPPJID *jidToReject = [[[self appDelegate] currentUser] awaitingJidToProcess];
    [[[self appDelegate] xmppRoster] rejectPresenceSubscriptionRequestFrom:jidToReject];
}

- (void)acceptFirstAwaitingFriendRequest {
    XMPPJID *jidToAccept = [[[self appDelegate] currentUser] awaitingJidToProcess];
    [[[self appDelegate] xmppRoster] acceptPresenceSubscriptionRequestFrom:jidToAccept andAddToRoster:YES];
    [[[self appDelegate] xmppRoster] addUser:jidToAccept withNickname:@""];
}

- (void)removeFriendWithJID:(XMPPJID *)jid {
    [[[self appDelegate] currentUser] removeFriendWithJID:jid];
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}

#pragma mark - Stream connect delegate
- (void)xmppStreamDidConnect {
    [[self appDelegate] authenticateUsingPassword];
}

- (void)xmppStreamConnectDidTimeOut {
    
}

- (void)didDisconnect {
    
}
#pragma mark - Login delegate
- (void)loginDidAuthenticate {
    if (!self.isUISet && [[self appDelegate] currentUser] != nil) {
        [self setupUI];
    }
}

- (void)loginDidNotAuthenticate:(DDXMLElement *)error {
    
}

#pragma mark - Friend list delegate
- (void)friendListDidUpdate {
    self.friends = [[[self appDelegate] currentUser] friends];
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListTableCell" forIndexPath:indexPath];
    
    PQOtherUser *user = [self.friends objectAtIndex:indexPath.row];
    
    [cell configUsingUser:user delegate:self];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PQMessageExchangeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageExchangeView"];
    PQOtherUser *partner = [self.friends objectAtIndex:indexPath.row];
    [vc configUsingPartner:partner];
    [self.navigationController showViewController:vc sender:self];
}

#pragma mark - Friend list table view cell delegate
- (void)didStartHoldingOnCell:(UITableViewCell *)cell {
    self.selectedIndex = [self.tableView indexPathForCell:cell];
    UIActionSheet *friendActionSheet = [[UIActionSheet alloc]
                                        initWithTitle:nil
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:@"Unfriend"
                                        otherButtonTitles:nil];
    friendActionSheet.tag = 0;
    [friendActionSheet showInView:self.view];
}

#pragma mark - Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) { //Friend cell action sheet
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            NSString *friendName = ((PQUser *)self.friends[self.selectedIndex.row]).nickname;
            NSString *message = [NSString stringWithFormat:@"Do you really want to remove %@ from your friendlist and disappear from his/her friendlist also", friendName];
            UIAlertView *removeFriendAlertView = [[UIAlertView alloc] initWithTitle:@"Remove friend"
                                                                            message:message
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Nope"
                                                                  otherButtonTitles:@"Yep", nil];
            removeFriendAlertView.tag = 2;
            [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [removeFriendAlertView show];
        }
    }
    else if (actionSheet.tag == 1) { //Self info action sheet
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [[self appDelegate] signOutAndDestroyViewController:self.navigationController];
        }
    }
}

#pragma mark - Alert view delegate


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 0) { // Friend add
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSString *usernameToAdd = [[alertView textFieldAtIndex:0] text];
            XMPPJID *jidToAdd = [XMPPJID jidWithString:[PQHostnameFactory nicknameWithHostName:usernameToAdd]];
            [[[self appDelegate] xmppRoster] addUser:jidToAdd withNickname:@""];
        }
    }
    else if (alertView.tag == 1) { // Friend confirm
        if (buttonIndex == alertView.cancelButtonIndex) {
            [self rejectFirstAwaitingFriendRequest];
        }
        else {
            [self acceptFirstAwaitingFriendRequest];
        }
    }
    else if (alertView.tag == 2) { // Friend remove
        if (buttonIndex != alertView.cancelButtonIndex) {
            // Remove friend from friend list
            NSString *jidStrToRemove = [(PQUser *)self.friends[self.selectedIndex.row] jidString];
            XMPPJID *jidToRemove = [XMPPJID jidWithString:jidStrToRemove];
            [self removeFriendWithJID:jidToRemove];
            self.friends = [[[self appDelegate] currentUser] friends];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[self.selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            self.selectedIndex = nil;
        }
    }
}




@end
