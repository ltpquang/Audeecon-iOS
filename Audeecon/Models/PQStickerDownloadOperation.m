//
//  PQStickerDownloadOperation.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerDownloadOperation.h"
#import "PQSticker.h"

@interface PQStickerDownloadOperation()
@property PQSticker *sticker;
@property id<PQStickerDownloadOperationDelegate> delegate;
@end

@implementation PQStickerDownloadOperation
- (id)initWithSticker:(PQSticker *)sticker
             delegate:(id<PQStickerDownloadOperationDelegate>)delegate {
    if (self = [super init]) {
        _sticker = sticker;
        _delegate = delegate;
    }
    return self;
}

- (void)main {
    //NSLog(@"Start download sticker");
    if (self.isCancelled) {
        //NSLog(@"Sticker cancelled at #1");
        return;
    }
    
    //NSLog(@"Sticker start getting data");
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sticker.uri]];
    //NSLog(@"Sticker finish getting data");
    
    if (self.isCancelled) {
        //NSLog(@"Sticker cancelled at #2");
        imgData = nil;
        return;
    }
    
    self.sticker.thumbnailData = imgData;
    if (self.isCancelled) {
        //NSLog(@"Sticker cancelled at #3");
        return;
    }
    //NSLog(@"Finish download sticker");
}

@end
