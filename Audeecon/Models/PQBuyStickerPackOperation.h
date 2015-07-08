//
//  PQBuyStickerOperation.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/7/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PQStickerPack;

@interface PQBuyStickerPackOperation : NSOperation
- (id)initWithStickerPack:(PQStickerPack *)pack;
@end
