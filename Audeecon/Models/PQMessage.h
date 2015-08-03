//
//  PQMessage.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PQSticker;
@class DDXMLElement;
@class PQRequestingService;

@interface PQMessage : NSObject
@property PQSticker *sticker;
@property NSString *onlineAudioUri;
@property NSString *offlineAudioUri;
@property NSString *fromJIDString;
@property NSString *toJIDString;
@property BOOL isOutgoing;
@property BOOL isRead;

- (id)initWithSticker:(PQSticker *)sticker
    andOnlineAudioUri:(NSString *)onlineAudioUri
        fromJIDString:(NSString *)fromJIDString
          toJIDString:(NSString *)toJIDString
           isOutgoing:(BOOL)isOutgoing;
- (id)initWithSticker:(PQSticker *)sticker
   andOfflineAudioUri:(NSString *)offlineAudioUri
        fromJIDString:(NSString *)fromJIDString
          toJIDString:(NSString *)toJIDString
           isOutgoing:(BOOL)isOutgoing;
- (void)markAsRead;

- (void)uploadAudioWithCompletion:(void(^)(BOOL, NSError *))complete;
- (void)downloadAudioUsingRequestingService:(PQRequestingService *)requestingService
                                   complete:(void(^)(NSURL *))complete;

@end
