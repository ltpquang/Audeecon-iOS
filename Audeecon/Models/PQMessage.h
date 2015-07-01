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
@property NSString *sender;
@property NSString *stickerUri;
@property NSString *onlineAudioUri;
@property NSString *offlineAudioUri;

- (id)initWithSender:(NSString *)sender
       andStickerUri:(NSString *)stickerUri
  andOfflineAudioUri:(NSString *)offlineAudioUri;

- (id)initWithXmlElement:(DDXMLElement *)element;

- (DDXMLElement *)xmlElementSendTo:(NSString *)toUser;

- (void)uploadAudioWithCompletion:(void(^)(BOOL, NSError *))complete;
- (void)downloadAudioUsingRequestingService:(PQRequestingService *)requestingService
                                   complete:(void(^)(NSURL *))complete;

@end
