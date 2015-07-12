//
//  PQGlobalContainer.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/5/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQGlobalContainer.h"

@implementation PQGlobalContainer
//- (NSArray *)stickerPacks {
//    if (_stickerPacks == nil) {
//        _stickerPacks = [NSArray new];
//    }
//    return _stickerPacks;
//}

- (NSOperationQueue *)stickerPackDownloadQueue {
    if (_stickerPackDownloadQueue == nil) {
        _stickerPackDownloadQueue = [NSOperationQueue new];
        _stickerPackDownloadQueue.maxConcurrentOperationCount = 1;
    }
    return _stickerPackDownloadQueue;
}
@end
