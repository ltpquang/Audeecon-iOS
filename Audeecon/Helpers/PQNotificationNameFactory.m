//
//  PQNotificationNameFactory.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQNotificationNameFactory.h"

@implementation PQNotificationNameFactory
+ (NSString *)messageStartedSending:(NSString *)messageId {
    return [@"StartedUploading:" stringByAppendingString:messageId];
}

+ (NSString *)messageCompletedSending:(NSString *)messageId {
    return [@"CompletedSending:" stringByAppendingString:messageId];
}

+ (NSString *)messageCompletedUploading:(NSString *)messageId {
    return [@"CompletedUploading:" stringByAppendingString:messageId];
}

+ (NSString *)messageCompletedDownloading:(NSString *)messageId {
    return [@"CompletedDownloadingMessage:" stringByAppendingString:messageId];
}

+ (NSString *)messageCompletedReceivingFromJIDString:(NSString *)jidString {
    return [@"Received:" stringByAppendingString:jidString];
}

+ (NSString *)messageDidChangeReadStatus:(NSString *)messageId {
    return [@"MessageDidChangeReadStatus:" stringByAppendingString:messageId];
}

+ (NSString *)stickerCompletedDownloading:(NSString *)stickerId {
    return [@"CompletedDownloading:" stringByAppendingString:stickerId];
}

+ (NSString *)stickerCompletedDownloadingFullsizeImage:(NSString *)stickerId {
    return [@"CompletedDownloadStickerFullsizeImage:" stringByAppendingString:stickerId];
}

+ (NSString *)stickerPackCompletedDownloading {
    return @"CompletedDownloadingStickerPack";
}

+ (NSString *)stickerPackStartedPending {
    return @"StartedPendingStickerPack";
}

+ (NSString *)stickerPackChangedProgress:(NSString *)packId {
    return [@"ChangeInDownloadProgress:" stringByAppendingString:packId];
}

+ (NSString *)stickerPackChangedStatus:(NSString *)packId {
    return [@"ChangedStatus:" stringByAppendingString:packId];
}

+ (NSString *)ownedStickerPacksDidUpdate {
    return @"OwnedStickerPacksDidUpdate";
}

+ (NSString *)recommendedStickersChanged {
    return @"RecommendedStickersChanged";
}

+ (NSString *)userAvatarChanged:(NSString *)username {
    return [@"AvatarChanged:" stringByAppendingString:username];
}

+ (NSString *)userNicknameChanged:(NSString *)username {
    return [@"NicknameChanged:" stringByAppendingString:username];
}

+ (NSString *)userOnlineStatusChanged:(NSString *)username {
    return [@"OnlineStatusChanged:" stringByAppendingString:username];
}
@end
