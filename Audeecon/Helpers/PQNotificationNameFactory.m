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
+ (NSString *)messageStartedSending:(PQMessage *)message {
    return [@"StartedUploading:" stringByAppendingString:message.offlineAudioUri.lastPathComponent];
}

+ (NSString *)messageCompletedSending:(PQMessage *)message {
    return [@"CompletedSending:" stringByAppendingString:message.offlineAudioUri.lastPathComponent];
}

+ (NSString *)messageCompletedUploading:(PQMessage *)message {
    return [@"CompletedUploading:" stringByAppendingString:message.offlineAudioUri.lastPathComponent];
}

+ (NSString *)messageCompletedDownloading:(PQMessage *)message {
    return [@"CompletedDownloadingMessage:" stringByAppendingString:message.onlineAudioUri.lastPathComponent];
}

+ (NSString *)messageCompletedReceivingFromJIDString:(NSString *)jidString {
    return [@"Received:" stringByAppendingString:jidString];
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
@end
