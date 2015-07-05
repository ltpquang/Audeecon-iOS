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

@interface PQFriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndex;

@end

@implementation PQFriendListViewController

#pragma mark - View controller delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self FetchFriends];
    [[self appDelegate] setStreamConnectDelegate:self];
    [[self appDelegate] setLoginDelegate:self];
    if ([[[self appDelegate] xmppStream] isDisconnected]) {
        [[self appDelegate] connect];
    }
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
    [self presentViewController:loginVC animated:YES completion:^{
        //
    }];
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

#pragma mark UITableViewCell helpers
- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user {
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    
    if (user.photo != nil)
    {
        cell.imageView.image = user.photo;
    }
    else
    {
        NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            cell.imageView.image = [UIImage imageWithData:photoData];
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.textLabel.text = user.displayName;
    [self configurePhotoForCell:cell user:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //[self performSegueWithIdentifier:@"GoToMessageExchangeSegue" sender:self];
    //[self performSegueWithIdentifier:@"GoToJSQMessageExchangeSegue" sender:self];
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
