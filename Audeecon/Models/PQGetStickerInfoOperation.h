//
//  PQGetStickerInfo.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/19/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQSticker;

@interface PQGetStickerInfoOperation : NSOperation
- (id)initWithSticker:(PQSticker *)sticker;
@end
