//
//  PQNotificationNameFactory.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/17/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQMessage;
@interface PQNotificationNameFactory : NSObject
+ (NSString *)messageStartedSending:(PQMessage *)message;
+ (NSString *)messageCompletedSending:(PQMessage *)message;
+ (NSString *)messageCompletedUploading:(PQMessage *)message;
@end
