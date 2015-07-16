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
#import "PQFriendListTableViewCell.h"
#import "PQHostnameFactory.h"
#import "PQCurrentUser.h"

@interface PQFriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (strong, nonatomic) RLMArray<PQOtherUser> *friends;
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
    
    [self setupAddFriendButton];
}

- (void)viewDidAppear:(BOOL)animated {
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex && alertView.tag == 1) {
        // Decline request
        [self rejectFirstAwaitingFriendRequest];
    }
    else {
        if (alertView.tag == 0) {
            NSString *usernameToAdd = [[alertView textFieldAtIndex:0] text];
            XMPPJID *jidToAdd = [XMPPJID jidWithString:[PQHostnameFactory nicknameWithHostName:usernameToAdd]];
            [[[self appDelegate] xmppRoster] addUser:jidToAdd withNickname:@""];
        }
        else if (alertView.tag == 1) {
            [self acceptFirstAwaitingFriendRequest];
        }
    }
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
    //[[self appDelegate] fetchRoster];
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
    
    [cell configUsingUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PQMessageExchangeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageExchangeView"];
    PQOtherUser *partner = [self.friends objectAtIndex:indexPath.row];
    [vc configUsingPartner:partner];
    [self.navigationController showViewController:vc sender:self];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if ([[segue identifier] isEqualToString:@"GoToMessageExchangeSegue"]) {
//        PQMessageExchangeViewController *vc = (PQMessageExchangeViewController *)[segue destinationViewController];
//        [vc setUser:[[self fetchedResultsController] objectAtIndexPath:_selectedIndex]];
//    }
//    else {
//        PQJSQMessageExchangeViewController *vc = (PQJSQMessageExchangeViewController *)[segue destinationViewController];
//        [vc setUser:[[self fetchedResultsController] objectAtIndexPath:_selectedIndex]];
//    }
}


@end
