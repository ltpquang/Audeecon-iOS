//
//  PQStickerPackStatusManager.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/25/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPackDownloadManager.h"
#import "PQStickerPack.h"
#import "PQNotificationNameFactory.h"

@interface PQStickerPackDownloadManager()
@property (strong, nonatomic) NSMutableDictionary *downloadStatus;
@property (strong, nonatomic) NSMutableDictionary *downloadProgress;
@property (strong, nonatomic) NSMutableDictionary *stickerPackDownloadOperations;
@end

@implementation PQStickerPackDownloadManager
- (id)init {
    if (self = [super init]) {
        _downloadStatus = [NSMutableDictionary new];
        _downloadProgress = [NSMutableDictionary new];
        _stickerPackDownloadOperations = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stickerPackDownloadedNotificationHandler:)
                                                     name:[PQNotificationNameFactory stickerPackCompletedDownloading]
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stickerPackPendingNotificationHandler:)
                                                     name:[PQNotificationNameFactory stickerPackStartedPending]
                                                   object:nil];
    }
    return self;
}

- (void)stickerPackDownloadedNotificationHandler:(NSNotification *)noti {
    PQStickerPack *pack = (PQStickerPack *)noti.object;
    self.downloadStatus[pack.packId] = [NSNumber numberWithInt:StickerPackStatusDownloaded];
    self.downloadProgress[pack.packId] = @100;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[PQNotificationNameFactory stickerPackChangedProgress:pack]
                                                  object:nil];
    [self postStatusChangedNotificationForStickerPackId:pack.packId];
}

- (void)stickerPackPendingNotificationHandler:(NSNotification *)noti {
    PQStickerPack *pack = (PQStickerPack *)noti.object;
    self.downloadStatus[pack.packId] = [NSNumber numberWithInt:StickerPackStatusPending];
    self.downloadProgress[pack.packId] = @0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stickerPackDownloadProgressChangeHandler:)
                                                 name:[PQNotificationNameFactory stickerPackChangedProgress:pack]
                                               object:nil];
    [self postStatusChangedNotificationForStickerPackId:pack.packId];
}

- (void)stickerPackDownloadProgressChangeHandler:(NSNotification *)noti {
    NSArray *arr = [noti.name componentsSeparatedByString:@":"];
    NSString *packId = (NSString *)arr[1];
    self.downloadStatus[packId] = [NSNumber numberWithInt:StickerPackStatusDownloading];
    self.downloadProgress[packId] = (NSNumber *)noti.userInfo[@"percentage"];
    [self postStatusChangedNotificationForStickerPackId:packId];
}

- (StickerPackStatus)statusForStickerPackWithId:(NSString *)packId {
    if (self.downloadStatus[packId] == nil) {
        return StickerPackStatusNotAvailable;
    }
    else {
        return (StickerPackStatus)[self.downloadStatus[packId] intValue];
    }
}

- (NSInteger)progressForStickerPackWithId:(NSString *)packId {
    if (self.downloadProgress[packId] == nil) {
        return 0;
    }
    else {
        return [self.downloadProgress[packId] intValue];
    }
}

- (void)downloadStickerPack:(PQStickerPack *)pack
         usingDownloadQueue:(NSOperationQueue *)downloadQueue {
    self.stickerPackDownloadOperations[pack.packId] = [pack downloadDataAndStickersUsingOperationQueue:downloadQueue];
}

- (void)cancelStickPack:(PQStickerPack *)pack {
    NSOperation *downloading = (NSOperation *)self.stickerPackDownloadOperations[pack.packId];
    if (downloading) {
        [downloading cancel];
    }
}

- (void)postStatusChangedNotificationForStickerPackId:(NSString *)stickerPackId {
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory
                                                                stickerPackChangedStatus:stickerPackId]
                                                        object:nil];
}

@end
