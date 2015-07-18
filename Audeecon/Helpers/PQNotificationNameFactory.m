//
//  PQNotificationNameFactory.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQNotificationNameFactory.h"
#import "PQMessage.h"

@implementation PQNotificationNameFactory
+ (NSString *)messageStartedSending:(PQMessage *)message {
    return [@"StartedUploading:" stringByAppendingString:message.offlineAudioUri.lastPathComponent];
}
+ (NSString *)messageCompletedUploading:(PQMessage *)message {
    return [@"CompletedUploading:" stringByAppendingString:message.offlineAudioUri.lastPathComponent];
}
@end
