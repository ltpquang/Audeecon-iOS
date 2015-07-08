//
//  PQStickerPack.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPack.h"
#import "PQRequestingService.h"
#import "PQGetStickersInfoOperation.h"
#import <RLMRealm.h>

@interface PQStickerPack()
@property (weak) PQStickerPackDownloadOperation *downloadOperation;
@end

@implementation PQStickerPack


- (id)initWithPackId:(NSString *)packId
             andName:(NSString *)name
           andArtist:(NSString *)artist
      andDescription:(NSString *)packDescription
     andThumbnailUri:(NSString *)thumbnailUri {
    if (self = [super init]) {
        _packId = packId;
        _name = name;
        _artist = artist;
        _packDescription = packDescription;
        _thumbnailUri = thumbnailUri;
        _status = StickerPackStatusNotAvailable;
    }
    return self;
}

- (UIImage *)thumbnailImage {
    if (_thumbnailImage == nil) {
        _thumbnailImage = [UIImage imageWithData:self.thumbnailData];
    }
    return _thumbnailImage;
}

- (NSInteger)percentage {
    return self.downloadOperation.percentage;
}

- (BOOL)needToBeUpdated {
    if (self.thumbnailData.length == 0) {
        return YES;
    }
    for (PQSticker *sticker in self.stickers) {
        if (sticker.thumbnailData.length == 0) {
            return YES;
        }
    }
    return NO;
}


- (NSOperation *)downloadDataAndStickersUsingOperationQueue:(NSOperationQueue *)queue {
    if (![self needToBeUpdated]) {
        [self stickerPackDownloadOperation:nil
           didFinishDownloadingStickerPack:self
                                     error:nil];
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{}];
        [queue addOperation:operation];
        return operation;
    }
    else {
        PQGetStickersInfoOperation *getStickerInfos = [[PQGetStickersInfoOperation alloc] initWithStickerPack:self];
        
        PQStickerPackDownloadOperation *operation = [[PQStickerPackDownloadOperation alloc]
                                                     initWithStickerPack:self
                                                     delegate:self];
        
        [operation addDependency:getStickerInfos];
        
        self.downloadOperation = operation;
        [queue addOperation:getStickerInfos];
        [queue addOperation:operation];
        self.status = StickerPackStatusPending;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusChanged" object:self];
        return operation;
    }
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
     didFinishDownloadingStickerPack:(PQStickerPack *)pack
                               error:(NSError *)error {
    self.status = StickerPackStatusDownloaded;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusChanged" object:self];
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
               didUpdateWithProgress:(NSInteger)percentage {
    self.status = StickerPackStatusDownloading;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusChanged" object:self];
    NSLog(@"%i", percentage);
}
// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"packId":@"",
             @"name":@"",
             @"artist":@"",
             @"packDescription":@"",
             @"thumbnailUri":@"",
             @"thumbnailData":[NSData new]};
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"thumbnailImage",
             @"status",
             @"downloadOperation",
             @"percentage",
             @"needToBeUpdated"];
}

+ (NSString *)primaryKey {
    return @"packId";
}
@end
