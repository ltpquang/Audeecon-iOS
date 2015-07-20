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
#import "PQMessageExchangeDelegate.h"
#import "XMPPStream.h"
#import "XMPPFramework.h"
#import "PQGlobalContainer.h"
#import "PQMessagingCenter.h"
#import "PQStickerKeyboardView.h"

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
@property (weak, nonatomic) id<PQMessageExchangeDelegate> messageExchangeDelegate;
//@property (weak, nonatomic) id<PQStickerKeyboardDelegate> keyboardDelegate;

@property (strong, nonatomic) PQGlobalContainer *globalContainer;

@property (strong, nonatomic) PQCurrentUser *currentUser;
@property (strong, nonatomic) PQMessagingCenter *messagingCenter;
@property (strong, nonatomic) PQStickerKeyboardView *keyboardView;

- (BOOL)connect;
- (void)fetchRoster;
- (NSManagedObjectContext *)managedObjectContext_roster;

- (void)authenticateUsingPassword;
- (void)registerUsingPassword;
@end

