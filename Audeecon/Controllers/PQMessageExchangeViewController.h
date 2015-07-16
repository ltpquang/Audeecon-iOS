//
//  PQMessageExchangeViewController.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/1/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PQMessageExchangeDelegate.h"
#import "XMPPFramework.h"
#import "PQStickerKeyboardView.h"
#import "PQAudioPlayerAndRecorder.h"

@protocol PQStickerKeyboardDelegate;
@protocol PQMessageCollectionViewCellDelegate;
@class PQOtherUser;

@interface PQMessageExchangeViewController : UIViewController
<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PQMessageExchangeDelegate, PQStickerKeyboardDelegate, PQAudioPlayerAndRecorderDelegate, PQMessageCollectionViewCellDelegate>
- (void)configUsingPartner:(PQOtherUser *)partner;
@end
