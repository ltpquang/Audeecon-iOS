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

@end

@implementation PQFriendListViewController

#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Friends";
    [[self appDelegate] setStreamConnectDelegate:self];
    [[self appDelegate] setLoginDelegate:self];
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
}
#pragma mark - Buttons handler

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

#pragma mark - Login delegate
- (void)loginDidAuthenticate {
    //[[self appDelegate] fetchRoster];
}

- (void)loginDidNotAuthenticate:(DDXMLElement *)error {
    
}

#pragma mark - Friend list delegate
- (void)didBeginReceivingFriendItems {
    
}

- (void)didReceiveFriendItem:(DDXMLElement *)friendElement withOnlineStatus:(BOOL)isOnline {
    
}

- (void)didEndReceivingFriendItems {
    
}

- (void)friendDidOnline:(NSString *)friendName {
    
}

- (void)friendDidOffline:(NSString *)friendName {
    
}

#pragma mark - FetchedResultController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        
        NSArray *sortDescriptors = @[sd1, sd2];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [_fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![_fetchedResultsController performFetch:&error])
        {
            //DDLogError(@"Error performing fetch: %@", error);
        }
        
    }
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] reloadData];
    //NSFetchedResultsController *frc = [self fetchedResultsController];
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex {
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  : return @"Available";
            case 1  : return @"Away";
            default : return @"Offline";
        }
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = sections[sectionIndex];
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PQFriendListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendListTableCell" forIndexPath:indexPath];
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [cell configUsingUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PQMessageExchangeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageExchangeView"];
    [vc configUsingPartner:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
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
