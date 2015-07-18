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
#import "PQMessageAudioUploadOperation.h"
#import "PQNotificationNameFactory.h"

@interface PQMessagingCenter()
@property (strong, nonatomic) NSMutableDictionary *messageDictionary;
@property (strong, nonatomic) NSOperationQueue *sendingQueue;
@property (strong, nonatomic) NSMutableDictionary *mostRecentSendingDictionary;
@property (strong, nonatomic) XMPPStream *stream;
@end


@implementation PQMessagingCenter
- (NSMutableDictionary *)messageDictionary {
    if (_messageDictionary == nil) {
        _messageDictionary = [NSMutableDictionary new];
    }
    return _messageDictionary;
}

- (NSOperationQueue *)sendingQueue {
    if (_sendingQueue == nil) {
        _sendingQueue = [NSOperationQueue new];
        _sendingQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _sendingQueue;
}

- (NSMutableDictionary *)mostRecentSendingDictionary {
    if (_mostRecentSendingDictionary == nil) {
        _mostRecentSendingDictionary = [NSMutableDictionary new];
    }
    return _mostRecentSendingDictionary;
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
    // Create an audio uploading operation
    PQMessageAudioUploadOperation *uploadingOperation = [[PQMessageAudioUploadOperation alloc] initWithMessage:message];
    uploadingOperation.completionBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            // After uploading, send the message
            XMPPMessage *toSendMessage = [XMPPMessage messageWithType:@"chat"
                                                                   to:[XMPPJID jidWithString:message.toJIDString]];
            NSString *body = [@[message.sticker.stickerId,
                                message.onlineAudioUri] componentsJoinedByString:@"|"];
            [toSendMessage addBody:body];
            [self.stream sendElement:toSendMessage];
        });
    };
    
    // Check for previous uploading operation, the current operation must be started after the previous one completed
    PQMessageAudioUploadOperation *previousOperation = self.mostRecentSendingDictionary[message.toJIDString];
    if (previousOperation != nil) {
        [uploadingOperation addDependency:previousOperation];
    }
    self.mostRecentSendingDictionary[message.toJIDString] = uploadingOperation;
    
    // Notify globaly that the message is going to be sent
    NSString *notiName = [PQNotificationNameFactory messageStartedSending:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:message];
    
    // Uploading the audio
    [self.sendingQueue addOperation:uploadingOperation];
    
    // Add the message to the chat log
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
