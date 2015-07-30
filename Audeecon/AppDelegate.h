//
//  AppDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQStreamConnectDelegate.h"
#import "PQLoginDelegate.h"
#import "PQRegisterDelegate.h"
#import "PQvCardModuleDelegate.h"
#import "PQFriendListDelegate.h"
#import "XMPPStream.h"
#import "XMPPFramework.h"
#import "PQGlobalContainer.h"
#import "PQMessagingCenter.h"
#import "PQStickerKeyboardView.h"
#import "PQStickerPackDownloadManager.h"
#import "PQStickerRecommender.h"

@class RLMRealm;
@class PQCurrentUser;

@interface AppDelegate : UIResponder
<UIApplicationDelegate, XMPPStreamDelegate, XMPPRosterDelegate, XMPPvCardAvatarDelegate, XMPPvCardTempModuleDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) XMPPStream *xmppStream;
@property (strong, nonatomic, readonly) XMPPRoster *xmppRoster;
@property (strong, nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;

@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@property NSString *password;
@property BOOL isOpen;

@property (weak, nonatomic) id<PQStreamConnectDelegate> streamConnectDelegate;
@property (weak, nonatomic) id<PQLoginDelegate> loginDelegate;
@property (weak, nonatomic) id<PQRegisterDelegate> registerDelegate;
@property (weak, nonatomic) id<PQvCardModuleDelegate> vCardModuleDelegate;
@property (weak, nonatomic) id<PQFriendListDelegate> friendListDelegate;

@property (strong, nonatomic) PQGlobalContainer *globalContainer;

@property (strong, nonatomic) PQCurrentUser *currentUser;
@property (strong, nonatomic) PQMessagingCenter *messagingCenter;
@property (strong, nonatomic) PQStickerKeyboardView *keyboardView;
@property (strong, nonatomic) PQStickerPackDownloadManager *stickerPackDownloadManager;
@property (strong, nonatomic) PQStickerRecommender *stickerRecommender;

- (BOOL)connect;
- (void)fetchRoster;

- (void)authenticateUsingPassword;
- (void)registerUsingPassword;

- (void)updateCurrentUserStickerPacks;

- (void)signOutAndDestroyViewController:(UIViewController *)toDestroy;
@end

