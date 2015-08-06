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
#import <DBCameraCollectionViewController.h>
#import <DBCameraContainerViewController.h>
#import <DBCameraView.h>
#import <AWSS3.h>
#import <AWSCore.h>
#import "PQFilePathFactory.h"
#import "PQUrlService.h"

@interface PQFriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (strong, nonatomic) RLMArray<PQOtherUser> *friends;
@property (strong, nonatomic) UIImageView *profilePicture;
@property BOOL isUISet;
@property MBProgressHUD *hud;
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
    [[self appDelegate] setVCardModuleDelegate:self];
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
                                                  cancelButtonTitle:nil//@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];//@"Change profile picture", @"Sign out", nil];
    infoSheet.tag = 1;
    [infoSheet addButtonWithTitle:@"Change profile picture"];
    [infoSheet addButtonWithTitle:@"Sign out"];
    infoSheet.cancelButtonIndex = [infoSheet addButtonWithTitle:@"Cancel"];
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
    PQOtherUser *partner = [self.friends objectAtIndex:indexPath.row];
    [[[self appDelegate] messagingCenter] acknowMessagesWithJIDString:partner.jidString];
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    PQMessageExchangeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageExchangeView"];
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
        if (buttonIndex == 0) {
            // Change profile pic
            [self loadCamera];
            
        }
        if (buttonIndex == 1) {
            [[self appDelegate] signOutAndDestroyViewController:self.navigationController];
            //NSLog(@"1");
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

#pragma mark - Camera
- (void)loadCamera
{
    DBCameraViewController *cameraController = [DBCameraViewController initWithDelegate:self];
    [cameraController setForceQuadCrop:YES];
    
    DBCameraContainerViewController *container = [[DBCameraContainerViewController alloc] initWithDelegate:self cameraSettingsBlock:^(DBCameraView *cameraView, id container) {
        //
        [cameraView.photoLibraryButton setHidden:NO];
        [cameraView.cameraButton setHidden:NO];
        [cameraView.flashButton setHidden:YES];
    }];
    [container setCameraViewController:cameraController];
    [container setFullScreenMode];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:container];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata {
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
    self.hud.minSize = CGSizeMake(135.f, 135.f);
    
    
    self.hud.labelText = @"Uploading...";
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    [self performSelectorInBackground:@selector(uploadImage:) withObject:image];
}

- (void)uploadImage:(UIImage *)image {
    NSURL *fileUrl = [PQFilePathFactory filePathInTemporaryDirectoryForAvatarImage];
    
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileUrl.path atomically:YES];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"avatar.png"];
    
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    __block NSString *username = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        username = [[[self appDelegate] currentUser] username];
    });
    NSString *onlineFileName = [NSString stringWithFormat:@"%@-%@.jpeg", username, timestamp]; // [self.username stringByAppendingString:@".jpeg"];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"audeecon-us/avatar";
    uploadRequest.key = onlineFileName;
    uploadRequest.body = fileUrl;
    uploadRequest.uploadProgress = ^(int64_t bytes, int64_t totalBytes, int64_t totalBytesExpected) {
        NSLog(@"%lld - %lld - %lld", bytes, totalBytes, totalBytesExpected);
        float progress = (float)(totalBytes * 100.0 / totalBytesExpected);
        NSLog(@"%f", progress);
        self.hud.progress = progress/100;
    };
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager S3TransferManagerForKey:@"defaulttransfermanager"];
    
    [[transferManager upload:uploadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor]
                                                       withBlock:^id(AWSTask *task) {
                                                           if (task.error != nil) {
                                                               //complete(NO, task.error);
                                                           }
                                                           else {
                                                               NSString *fileUrl = [PQUrlService urlToS3FileWithFileName:[@"avatar/" stringByAppendingString:onlineFileName]];
                                                               NSLog(@"%@", fileUrl);
                                                               [self updatevCardUsingAvatarUrl:fileUrl];
                                                               self.hud.mode = MBProgressHUDModeIndeterminate;
                                                               self.hud.labelText = @"Updating...";
                                                           }
                                                           return nil;
                                                       }];
}

- (void)updatevCardUsingAvatarUrl:(NSString *)fileUrl {
    XMPPvCardTemp *myvCardTemp = [[[self appDelegate] xmppvCardTempModule] myvCardTemp];
    if (myvCardTemp == nil) {
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        myvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    }
    [myvCardTemp setNickname:[[[self appDelegate] currentUser] nickname]];
    [myvCardTemp setUrl:fileUrl];
    [[[self appDelegate] xmppvCardTempModule] updateMyvCardTemp:myvCardTemp];
    [[self appDelegate] setVCardModuleDelegate:self];
}

#pragma mark - HUD delegates
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_hud removeFromSuperview];
    _hud = nil;
}

#pragma mark - vCard module delegates
- (void)vCardModuleDidUpdateMyvCard {
    [self.hud hide:YES];
    XMPPJID *jid = [XMPPJID jidWithString:[[[self appDelegate] currentUser] jidString]];
    [[[self appDelegate] xmppvCardTempModule] fetchvCardTempForJID:jid ignoreStorage:YES];
}

- (void)vCardModuleDidNotUpdateMyvCard:(DDXMLElement *)error {
    
}


@end
