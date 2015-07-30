//
//  PQUser.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQUser.h"
#import "XMPPvCardTemp.h"
#import <Realm.h>
#import "AppDelegate.h"
#import "PQImageUriToDataDownloadOperation.h"
#import "PQNotificationNameFactory.h"

@implementation PQUser

- (id)initWithXMPPJID:(XMPPJID *)jid {
    if (self = [super init]) {
        _jidString = [jid bare];
        _username = [jid user];
        _nickname = [jid user];
        _avatarUrl = @"";
        _avatarData = [NSData new];
    }
    return self;
}

#pragma mark - App utilities
- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIImage *)avatarImage {
    if (_avatarImage == nil) {
        _avatarImage = [UIImage imageWithData:self.avatarData];
    }
    return _avatarImage;
}

- (void)updateInfoUsingvCard:(XMPPvCardTemp *)vCard {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    self.nickname = vCard.nickname;
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory userNicknameChanged:self.username]
                                                        object:self];
    [realm commitWriteTransaction];
    if (![self.avatarUrl isEqualToString:vCard.url] ||
        (self.avatarUrl.length != 0 && self.avatarData.length == 0)) {
        [realm beginWriteTransaction];
        self.avatarUrl = vCard.url;
        [realm commitWriteTransaction];
        // update new avatar but please check if the download has been started or not
        [self downloadAvatar];
        return;
    }
}

- (void)downloadAvatar {
    PQImageUriToDataDownloadOperation *operation = [[PQImageUriToDataDownloadOperation alloc]
                                                    initWithUri:self.avatarUrl
                                                    andComleteBlock:^(NSData *result) {
                                                        RLMRealm *realm = [RLMRealm defaultRealm];
                                                        [realm beginWriteTransaction];
                                                        self.avatarData = result;
                                                        [realm commitWriteTransaction];
                                                    }];
    operation.completionBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory userAvatarChanged:self.username]
                                                                object:self];
        });
    };
    
    [[[[self appDelegate] globalContainer] avatarDownloadQueue] addOperation:operation];
}


// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"jidString":@"",
             @"nickname":@"",
             @"avatarUrl":@"",
             @"avatarData":[NSData new]};
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"avatarImage"];
}

+ (NSString *)primaryKey {
    return @"username";
}

@end
