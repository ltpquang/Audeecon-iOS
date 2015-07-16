//
//  PQMessagingCenter.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/16/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessagingCenter.h"
#import "PQMessage.h"
#import "XMPP.h"
#import "PQSticker.h"
#import <Realm.h>

@interface PQMessagingCenter()
@property (strong, nonatomic) NSMutableDictionary *messageDictionary;
@property (strong, nonatomic) XMPPStream *stream;
@end


@implementation PQMessagingCenter
- (NSMutableDictionary *)messageDictionary {
    if (_messageDictionary == nil) {
        _messageDictionary = [NSMutableDictionary new];
    }
    return _messageDictionary;
}

- (id)initWithXMPPStream:(XMPPStream *)stream {
    if (self = [super init]) {
        _stream = stream;
    }
    return self;
}

- (NSMutableArray *)messagesWithPartnerJIDString:(NSString *)partnerJIDString {
    NSMutableArray *messages = self.messageDictionary[partnerJIDString];
    if (messages == nil) {
        messages = [NSMutableArray new];
        self.messageDictionary[partnerJIDString] = messages;
    }
    return messages;
}

- (void)receiveMessage:(XMPPMessage *)message {
    NSString *body = message.body;
    NSString *fromJIDString = message.from.bare;
    NSString *toJIDString = message.to.bare;
    
    NSArray *arr = [body componentsSeparatedByString:@"|"];
    
    NSString *stickerId = arr[0];
    NSString *onlineAudioUri = arr[1];
    
    NSString *predicateString = [NSString stringWithFormat:@"stickerId = '%@'", stickerId];
    RLMResults *stickers = [PQSticker objectsWhere:predicateString];
    PQSticker *sticker = [stickers firstObject];
    
    if (sticker == nil) {
        sticker = [[PQSticker alloc] initWithStickerId:stickerId];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [realm addObject:sticker];
        [realm commitWriteTransaction];
    }
    
    PQMessage *pqMessage = [[PQMessage alloc] initWithSticker:sticker
                                            andOnlineAudioUri:onlineAudioUri
                                                fromJIDString:fromJIDString
                                                  toJIDString:toJIDString
                                                   isOutgoing:NO];
    
    NSMutableArray *messages = [self messagesWithPartnerJIDString:fromJIDString];
    [messages addObject:pqMessage];
    NSString *receiveNotiName = [@"Received:" stringByAppendingString:fromJIDString];
    [[NSNotificationCenter defaultCenter] postNotificationName:receiveNotiName object:pqMessage];
}

- (void)sendMessage:(PQMessage *)message {
    XMPPMessage *toSendMessage = [XMPPMessage messageWithType:@"chat"
                                                           to:[XMPPJID jidWithString:message.toJIDString]];
    NSString *body = [@[message.sticker.stickerId,
                       message.onlineAudioUri] componentsJoinedByString:@"|"];
    [toSendMessage addBody:body];
    [self.stream sendElement:toSendMessage];
    
    NSMutableArray *messages = [self messagesWithPartnerJIDString:message.toJIDString];
    
    [messages addObject:message];
}

- (NSInteger)messageCountWithPartnerJIDString:(NSString *)partnerJIDString {
    return [[self messagesWithPartnerJIDString:partnerJIDString] count];
}

- (PQMessage *)messageAtIndexPath:(NSIndexPath *)indexPath withPartnerJIDString:(NSString *)partnerJIDString {
    return [[self messagesWithPartnerJIDString:partnerJIDString] objectAtIndex:indexPath.row];
}
@end
