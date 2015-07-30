//
//  PQNotificationNameFactory.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQMessage;
@class PQSticker;
@class PQStickerPack;

@interface PQNotificationNameFactory : NSObject
+ (NSString *)messageStartedSending:(PQMessage *)message;
+ (NSString *)messageCompletedSending:(PQMessage *)message;
+ (NSString *)messageCompletedUploading:(PQMessage *)message;
+ (NSString *)messageCompletedDownloading:(PQMessage *)message;
+ (NSString *)messageCompletedReceivingFromJIDString:(NSString *)jidString;
+ (NSString *)stickerCompletedDownloading:(PQSticker *)sticker;
+ (NSString *)stickerCompletedDownloadingFullsizeImage:(PQSticker *)sticker;
+ (NSString *)stickerPackCompletedDownloading;
+ (NSString *)stickerPackStartedPending;
+ (NSString *)stickerPackChangedProgress:(PQStickerPack *)stickerPack;
+ (NSString *)stickerPackChangedStatus:(NSString *)stickerPackId;
+ (NSString *)ownedStickerPacksDidUpdate;
+ (NSString *)recommendedStickersChanged;
+ (NSString *)userAvatarChanged:(NSString *)username;
+ (NSString *)userNicknameChanged:(NSString *)username;
+ (NSString *)userOnlineStatusChanged:(NSString *)username;
@end

