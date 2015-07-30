//
//  PQMessageExchangeViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "PQStickerKeyboardView.h"
#import "PQAudioPlayerAndRecorder.h"

@protocol PQStickerKeyboardDelegate;
@protocol PQMessageTableViewCellDelegate;
@class PQOtherUser;

@interface PQMessageExchangeViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource, PQStickerKeyboardDelegate, PQAudioPlayerAndRecorderDelegate, PQMessageTableViewCellDelegate>
- (void)configUsingPartner:(PQOtherUser *)partner;
@end
