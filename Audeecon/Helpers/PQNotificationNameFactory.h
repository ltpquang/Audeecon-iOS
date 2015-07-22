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

@interface PQNotificationNameFactory : NSObject
+ (NSString *)messageStartedSending:(PQMessage *)message;
+ (NSString *)messageCompletedSending:(PQMessage *)message;
+ (NSString *)messageCompletedUploading:(PQMessage *)message;
+ (NSString *)messageCompletedDownloading:(PQMessage *)message;
+ (NSString *)messageCompletedReceivingFromJIDString:(NSString *)jidString;
+ (NSString *)stickerCompletedDownloading:(PQSticker *)sticker;
+ (NSString *)stickerCompletedDownloadingFullsizeImage:(PQSticker *)sticker;
+ (NSString *)stickerPackCompletedDownloading;
@end
