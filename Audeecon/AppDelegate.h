//
//  AppDelegate.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 3/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQLoginDelegate.h"
#import "PQFriendListDelegate.h"
#import "PQMessageExchangeDelegate.h"
#import "XMPPStream.h"
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, XMPPStreamDelegate, XMPPRosterDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) XMPPStream *xmppStream;
@property (strong, nonatomic, readonly) XMPPRoster *xmppRoster;
@property (strong, nonatomic, readonly) XMPPRosterCoreDataStorage *xmppRosterCoreDataStorage;

@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;

@property NSString *password;
@property BOOL isOpen;

@property (weak, nonatomic) id<PQLoginDelegate> loginDelegate;
@property (weak, nonatomic) id<PQFriendListDelegate> friendListDelegate;
@property (weak, nonatomic) id<PQMessageExchangeDelegate> messageExchangeDelegate;

@property (strong, nonatomic) NSArray *_stickerPacks;

- (BOOL)connect;
- (NSManagedObjectContext *)managedObjectContext_roster;

@end

