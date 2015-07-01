//
//  PQMessage.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/22/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQMessage.h"
#import "PQSticker.h"
#import "DDXML.h"
#import "DDXMLElement.h"
#import "NSXMLElement+XMPP.h"
#import <Parse/Parse.h>
#import "PQRequestingService.h"

@implementation PQMessage

- (id)initWithSender:(NSString *)sender
       andStickerUri:(NSString *)stickerUri
  andOfflineAudioUri:(NSString *)offlineAudioUri {
    if (self = [super init]) {
        _sender = sender;
        _stickerUri = stickerUri;
        _offlineAudioUri = offlineAudioUri;
    }
    return self;
}

- (id)initWithXmlElement:(DDXMLElement *)element {
    if (self = [super init]) {
        NSString *body = [[element elementForName:@"body"] stringValue];
        NSString *from = [[element attributeForName:@"from"] stringValue];
        
        _sender = from;
        
        NSArray *arr = [body componentsSeparatedByString:@"|"];
        _stickerUri = arr[0];
        _onlineAudioUri = arr[1];
    }
    return self;
}

- (DDXMLElement *)xmlElementSendTo:(NSString *)toUser {
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    NSArray *arr = @[_stickerUri, _onlineAudioUri];
    NSString *bodyString = [arr componentsJoinedByString:@"|"];
    [body setStringValue:bodyString];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:toUser];
    [message addChild:body];
    
    return message;
}

- (void)uploadAudioWithCompletion:(void(^)(BOOL, NSError *))complete {
    if (_offlineAudioUri.length == 0) {
        complete(YES, nil);
    }
    else {
        PFFile *file = [PFFile fileWithName:[_offlineAudioUri lastPathComponent] contentsAtPath:_offlineAudioUri];
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                _onlineAudioUri = file.url;
            }
            complete(succeeded, error);
        }
                          progressBlock:^(int percentDone) {
                              NSLog(@"%i", percentDone);
                          }];
    }
}

- (void)downloadAudioUsingRequestingService:(PQRequestingService *)requestingService
                                   complete:(void(^)(NSURL *))complete {
    if (_offlineAudioUri.length != 0) {
        complete([NSURL URLWithString:_offlineAudioUri]);
    } else {
        [requestingService downloadAudioFileAtUrl:_onlineAudioUri
                                         complete:^(NSURL *filepath) {
                                             _offlineAudioUri = [filepath absoluteString];
                                             complete(filepath);
                                         }];
    }
}

@end
