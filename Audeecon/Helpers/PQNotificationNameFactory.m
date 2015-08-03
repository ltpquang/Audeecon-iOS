//
//  PQNotificationNameFactory.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQNotificationNameFactory.h"
#import "PQMessage.h"
#import "PQSticker.h"
#import "PQStickerPack.h"

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

+ (NSString *)stickerCompletedDownloading:(PQSticker *)sticker {
    return [@"CompletedDownloading:" stringByAppendingString:sticker.stickerId];
}

+ (NSString *)stickerCompletedDownloadingFullsizeImage:(PQSticker *)sticker {
    return [@"CompletedDownloadStickerFullsizeImage:" stringByAppendingString:sticker.stickerId];
}

+ (NSString *)stickerPackCompletedDownloading {
    return @"CompletedDownloadingStickerPack";
}

+ (NSString *)stickerPackStartedPending {
    return @"StartedPendingStickerPack";
}

+ (NSString *)stickerPackChangedProgress:(PQStickerPack *)stickerPack {
    return [@"ChangeInDownloadProgress:" stringByAppendingString:stickerPack.packId];
}

+ (NSString *)stickerPackChangedStatus:(NSString *)stickerPackId {
    return [@"ChangedStatus:" stringByAppendingString:stickerPackId];
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
