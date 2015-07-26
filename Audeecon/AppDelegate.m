//
//  AppDelegate.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPP.h"
#import "XMPPvCardTemp.h"
#import "XMPPMessage+XEP_0085.h"
#import "PQHostnameFactory.h"
#import "PQRequestingService.h"
#import "PQMessage.h"
#import "PQFilePathFactory.h"
#import <AWSCore.h>
#import <AWSS3.h>
#import <Realm.h>
#import "PQUser.h"
#import "PQCurrentUser.h"
#import "PQNotificationNameFactory.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Application delegates


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self clearTemperaryFolder];
    //[self setupParse];
    [self setupStream];
    [self setupAmazon];
    [self updateRealmSchema];
    self.stickerPackDownloadManager = [[PQStickerPackDownloadManager alloc] init];
    
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    //login = nil;
    if (login) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [sb instantiateInitialViewController];
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *loginVC = [sb instantiateViewControllerWithIdentifier:@"LoginView"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = navController;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - App delegate actions
- (PQGlobalContainer *)globalContainer {
    if (_globalContainer == nil) {
        _globalContainer = [PQGlobalContainer new];
    }
    return _globalContainer;
}

- (PQMessagingCenter *)messagingCenter {
    if (_messagingCenter == nil) {
        _messagingCenter = [[PQMessagingCenter alloc] initWithXMPPStream:_xmppStream];
    }
    return _messagingCenter;
}

- (PQStickerKeyboardView *)keyboardView {
    if (_keyboardView == nil) {
        _keyboardView = [[[NSBundle mainBundle] loadNibNamed:@"StickerKeyboardView" owner:nil options:nil] lastObject];
    }
    return _keyboardView;
}

- (PQStickerRecommender *)stickerRecommender {
    if (_stickerRecommender == nil) {
        _stickerRecommender = [[PQStickerRecommender alloc] initWithUsername:self.currentUser.username];
        [_stickerRecommender getRecommendedStickers];
    }
    return _stickerRecommender;
}


- (void)clearTemperaryFolder {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [[PQFilePathFactory tempDirectory] path];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        if (!success || error) {
            // it failed.
        }
    }
}



- (void)setupAmazon {
    AWSCognitoCredentialsProvider *credentialsProvider
    = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                 identityPoolId:@"us-east-1:86938877-3794-4eeb-8062-563baf97c462"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                         credentialsProvider:credentialsProvider];
    
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    [AWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:@"defaulttransfermanager"];
}

- (void)updateRealmSchema {
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                
            }];
}
#pragma mark - XMPP setup
- (void)setupStream {
    _xmppStream = [[XMPPStream alloc] init];
    [_xmppStream setHostName:[PQHostnameFactory hostnameString]];
    [_xmppStream setHostPort:5222];
    
    _xmppRosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterCoreDataStorage];
    _xmppRoster.autoFetchRoster = NO;
    
    

    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
    
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];
    
    [_xmppRoster            activate:_xmppStream];
    [_xmppvCardTempModule   activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - XMPP actions
- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    NSLog(@"Connect");
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];
    
    if (![_xmppStream isDisconnected]) {
        //[_streamConnectDelegate xmppStreamDidConnect];
        return YES;
    }
    
    
    if (jabberID == nil || myPassword == nil) {
        
        return NO;
    }
    
    [_xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    _password = myPassword;
    
    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect {
    
    [self goOffline];
    [_xmppStream disconnect];
    [_friendListDelegate didDisconnect];
}

- (void)authenticateUsingPassword {
    NSError *error = nil;
    [_xmppStream authenticateWithPassword:_password error:&error];
}

- (void)registerUsingPassword {
    NSError *error = nil;
    [_xmppStream registerWithPassword:_password error:&error];
}

- (void)fetchRoster {
    [_xmppRoster fetchRoster];
}

#pragma mark - XMPPStream connecting delegates
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"didConnect");
    _isOpen = YES;
    [_streamConnectDelegate xmppStreamDidConnect];
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    //[_loginDelegate loginDidConnectTimeout];
}


#pragma mark - XMPPStream authenticating delegates
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"didAuthenticate");
    [_loginDelegate loginDidAuthenticate];
    
    NSString *dfRealmPath = [[[[RLMRealm defaultRealmPath]
                               stringByDeletingLastPathComponent]
                              stringByAppendingPathComponent:[[[self xmppStream] myJID] user]]
                             stringByAppendingPathExtension:@"realm"];
    
    [RLMRealm setDefaultRealmPath:dfRealmPath];

    // Load user from database
    NSString *predicateString = [NSString stringWithFormat:@"username = '%@'", [[[self xmppStream] myJID] user]];
    RLMResults *users = [PQCurrentUser objectsWhere:predicateString];
    self.currentUser = [users firstObject];
    // If not, create a new one
    
    if (self.currentUser == nil) {
        self.currentUser = [[PQCurrentUser alloc] initWithXMPPJID:[[self xmppStream] myJID]];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:self.currentUser];
        [realm commitWriteTransaction];
    }
    // Then update sticker pack for that user
    [self updateCurrentUserStickerPacks];
    
    
    [self.keyboardView configKeyboard];
    [self.currentUser markFriendListForUpdating];
    [_friendListDelegate friendListDidUpdate];
    [[self xmppRoster] fetchRoster];
    
    
    [self goOnline];
}

- (void)updateCurrentUserStickerPacks {
    [self.currentUser updateOwnedStickerPackUsingQueue:[[self globalContainer] stickerPackDownloadQueue]
                                               success:^{
                                                   //
                                                   NSLog(@"Callback success on app delegate");
                                               }
                                               failure:^(NSError *error) {
                                                   //
                                                   NSLog(@"Update sticker packs failure");
                                               }];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    [_loginDelegate loginDidNotAuthenticate:error];
    
}

#pragma mark - XMPPStream registering delegates
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    [_registerDelegate registerDidSuccess];
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    [_registerDelegate registerDidNotSuccess:error];
}

#pragma mark - XMPPStream IQ delegates
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    //NSLog(@"%@", iq);

    return NO;
    
}

- (XMPPIQ *)xmppStream:(XMPPStream *)sender willSendIQ:(XMPPIQ *)iq {
    //NSLog(@"%@", iq);
    return iq;
}


#pragma mark - XMPPStream messaging delegates
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([message hasComposingChatState]) {
        return;
    }
    //NSLog(@"Received message");
    if (message.isChatMessageWithBody) {
        [self.messagingCenter receiveMessage:message];
    }
}


- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //NSLog(@"%@", presence);
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    if (![presenceFromUser isEqualToString:myUsername]) {
        [self.currentUser updateFriendListUsingPresence:presence];
    }
}



#pragma mark - Core Data
- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [_xmppRosterCoreDataStorage mainThreadManagedObjectContext];
}

#pragma mark - XMPPRoster delegates
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    NSLog(@"%@", presence);
    [self.currentUser addAwaitingJid:presence.from];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item {
    NSLog(@"Roster received item");
    NSString *jidString = [[item attributeForName:@"jid"] stringValue];
    XMPPJID *jid = [XMPPJID jidWithString:jidString];
    [self.currentUser updateFriendListUsingXMPPJID:jid];
    [_xmppvCardTempModule fetchvCardTempForJID:jid ignoreStorage:YES];
    [_friendListDelegate friendListDidUpdate];
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq {
    
}

- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender {
    NSLog(@"Roster begin populating");
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender {
    NSLog(@"Roster end populating");
    [self.currentUser removeNotUpdatedFriends];
    [_friendListDelegate friendListDidUpdate];
}

#pragma mark - XMPPvCardAvatar delegates
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule
              didReceivePhoto:(UIImage *)photo
                       forJID:(XMPPJID *)jid {
    
}

#pragma mark - XMPPvCardTempModule delegates
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid {
    [self.currentUser updateInfoForFriendWithXMPPJID:jid
                                      usingvCardTemp:vCardTemp];
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule {
    [self.vCardModuleDelegate vCardModuleDidUpdateMyvCard];
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
      failedToUpdateMyvCard:(DDXMLElement *)error {
    [self.vCardModuleDelegate vCardModuleDidNotUpdateMyvCard:error];
}


@end
