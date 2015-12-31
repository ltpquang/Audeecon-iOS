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
#import "PQMessageDownloadOperation.h"

@interface PQMessagingCenter()
@property (strong, nonatomic) XMPPStream *stream;
// Message dictionary is used to save the chat log
// Key: the partner
// Value: the array containing all the back and forth messages
@property (strong, nonatomic) NSMutableDictionary *messageDictionary;
@property (strong, nonatomic) NSOperationQueue *sendingQueue;
// Most recent sending dictionary is used to save the last sent message
// to ensure that all the message will be sent after the previous one completed sending
// Key: the partner
// Value: the operation of the last sending message
@property (strong, nonatomic) NSMutableDictionary *mostRecentSendingDictionary;
@property (strong, nonatomic) NSOperationQueue *receivingQueue;
// Have new unacknown messages dictionary indicates that whether we have new unacknown
// messages with specified user or not, this is not similar to unread messages, because sometimes we
// have unread messages but we are acknown about them
@property (strong, nonatomic) NSMutableDictionary *haveNewUnacknownMessagesDictionary;
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

- (NSOperationQueue *)receivingQueue {
    if (_receivingQueue == nil) {
        _receivingQueue = [NSOperationQueue new];
        _receivingQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _receivingQueue;
}

- (NSMutableDictionary *)haveNewUnacknownMessagesDictionary {
    if (_haveNewUnacknownMessagesDictionary == nil) {
        _haveNewUnacknownMessagesDictionary = [NSMutableDictionary new];
    }
    return _haveNewUnacknownMessagesDictionary;
}

- (void)setHaveNewUnacknownMessages:(BOOL)isHaveNew
                       forJIDString:(NSString *)jidString {
    if (isHaveNew) {
        self.haveNewUnacknownMessagesDictionary[jidString] = @1;
    }
    else {
        self.haveNewUnacknownMessagesDictionary[jidString] = @0;
    }
}

- (void)acknowMessagesWithJIDString:(NSString *)jidString {
    [self setHaveNewUnacknownMessages:NO forJIDString:jidString];
}

- (BOOL)haveNewUnacknownMessagesWithJIDString:(NSString *)jidString {
    NSNumber *number = self.haveNewUnacknownMessagesDictionary[jidString];
    if (number && [number boolValue]) {
        return YES;
    }
    return NO; 
}

- (NSInteger)unreadMessageCountForJIDString:(NSString *)jid {
    NSArray *messages = [self messagesWithPartnerJIDString:jid];
    int count = 0;
    for (PQMessage *mess in messages) {
        if (!mess.isOutgoing && !mess.isRead) {
            ++count;
        }
    }
    return count;
}

- (PQSticker *)lastIncomingMessageStickerForJIDString:(NSString *)jid {
    NSArray *messages = [self messagesWithPartnerJIDString:jid];
    return [(PQMessage *)[messages lastObject] sticker];
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
    [self setHaveNewUnacknownMessages:YES forJIDString:fromJIDString];
    PQMessageDownloadOperation *messDownloadOperation = [[PQMessageDownloadOperation alloc] initWithMessage:pqMessage
                                                                                           andDownloadQueue:self.receivingQueue];
    [self.receivingQueue addOperation:messDownloadOperation];
    NSLog(@"%@", [PQNotificationNameFactory messageCompletedReceivingFromJIDString:fromJIDString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory messageCompletedReceivingFromJIDString:fromJIDString]
                                                        object:pqMessage];
}

- (void)sendMessage:(PQMessage *)message {
    // Create an audio uploading operation
    PQMessageAudioUploadOperation *uploadingOperation = [[PQMessageAudioUploadOperation alloc] initWithMessage:message];
    uploadingOperation.completionBlock = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory messageCompletedUploading:message.messageId]
                                                                object:message];
            // After uploading, send the message
            XMPPMessage *toSendMessage = [XMPPMessage messageWithType:@"chat"
                                                                   to:[XMPPJID jidWithString:message.toJIDString]];
            NSString *body = [@[message.sticker.stickerId,
                                message.onlineAudioUri] componentsJoinedByString:@"|"];
            [toSendMessage addBody:body];
            [self.stream sendElement:toSendMessage];
            [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory messageCompletedSending:message.messageId]
                                                                object:message];
        });
    };
    
    // Check for previous uploading operation, the current operation must be started after the previous one completed
    PQMessageAudioUploadOperation *previousOperation = self.mostRecentSendingDictionary[message.toJIDString];
    if (previousOperation != nil) {
        [uploadingOperation addDependency:previousOperation];
    }
    self.mostRecentSendingDictionary[message.toJIDString] = uploadingOperation;
    
    // Notify globaly that the message is going to be sent
    NSString *notiName = [PQNotificationNameFactory messageStartedSending:message.messageId];
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
