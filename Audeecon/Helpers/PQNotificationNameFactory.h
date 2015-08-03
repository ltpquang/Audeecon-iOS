//
//  PQNotificationNameFactory.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PQNotificationNameFactory : NSObject
+ (NSString *)messageStartedSending:(NSString *)messageId;
+ (NSString *)messageCompletedSending:(NSString *)messageId;
+ (NSString *)messageCompletedUploading:(NSString *)messageId;
+ (NSString *)messageCompletedDownloading:(NSString *)messageId;
+ (NSString *)messageCompletedReceivingFromJIDString:(NSString *)jidString;
+ (NSString *)messageDidChangeReadStatus:(NSString *)messageId;
+ (NSString *)stickerCompletedDownloading:(NSString *)stickerId;
+ (NSString *)stickerCompletedDownloadingFullsizeImage:(NSString *)stickerId;
+ (NSString *)stickerPackCompletedDownloading;
+ (NSString *)stickerPackStartedPending;
+ (NSString *)stickerPackChangedProgress:(NSString *)packId;
+ (NSString *)stickerPackChangedStatus:(NSString *)packId;
+ (NSString *)ownedStickerPacksDidUpdate;
+ (NSString *)recommendedStickersChanged;
+ (NSString *)userAvatarChanged:(NSString *)username;
+ (NSString *)userNicknameChanged:(NSString *)username;
+ (NSString *)userOnlineStatusChanged:(NSString *)username;
@end

