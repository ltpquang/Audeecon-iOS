//
//  PQMessagingCenter.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/16/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMPPStream;
@class XMPPMessage;
@class PQMessage;

@interface PQMessagingCenter : NSObject
- (id)initWithXMPPStream:(XMPPStream *)stream;
- (void)receiveMessage:(XMPPMessage *)message;
- (void)sendMessage:(PQMessage *)message;
- (NSInteger)messageCountWithPartnerJIDString:(NSString *)partnerJIDString;
- (PQMessage *)messageAtIndexPath:(NSIndexPath *)indexPath
             withPartnerJIDString:(NSString *)partnerJIDString;
@end
