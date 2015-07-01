//
//  PQStickerPackDownloader.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 6/24/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerAndPackDownloader.h"
#import <UIKit/UIKit.h>
#import "UIImage+Sprite.h"
#import "PQSticker.h"
#import "PQStickerPack.h"

@implementation PQStickerAndPackDownloader

- (id)initWithStickerPack:(PQStickerPack *)pack
              atIndexPath:(NSIndexPath *)indexPath
                 delegate:(id<PQStickerAndPackDownloaderDelegate>)delegate {
    if (self = [super init]) {
        _pack = pack;
        _indexPath = indexPath;
        _downloaderDelegate = delegate;
        _forPack = YES;
    }
    return self;
}

- (id)initWithSticker:(PQSticker *)sticker
          atIndexPath:(NSIndexPath *)indexPath
             delegate:(id<PQStickerAndPackDownloaderDelegate>)delegate {
    if (self = [super init]) {
        _sticker = sticker;
        _indexPath = indexPath;
        _downloaderDelegate = delegate;
        _forPack = NO;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        NSString *imgUri = self.forPack ? _pack.thumbnail : _sticker.uri;
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUri]];
        
        if (self.isCancelled) {
            imgData = nil;
            return;
        }
        
        if (self.forPack) {
            _pack.thumbnailImage = [UIImage imageWithData:imgData];
        }
        else {
            _sticker.thumbnailImage = [UIImage imageWithData:imgData];
        }
        
        imgData = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        if (self.forPack) {
            [(NSObject *)self.downloaderDelegate performSelectorOnMainThread:@selector(packDownloaderDidFinish:)
                                                                  withObject:self
                                                               waitUntilDone:NO];
        }
        else {
            [(NSObject *)self.downloaderDelegate performSelectorOnMainThread:@selector(stickerDownloaderDidFinish:)
                                                                  withObject:self
                                                               waitUntilDone:NO];
        }
    }
}

@end
