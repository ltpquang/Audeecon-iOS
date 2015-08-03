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
#import "PQNotificationNameFactory.h"

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
        if ([sticker needToBeUpdated]) {
            return YES;
        }
    }
    return NO;
}


- (NSOperation *)downloadDataAndStickersUsingOperationQueue:(NSOperationQueue *)queue {
    if (![self needToBeUpdated]) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]  postNotificationName:[PQNotificationNameFactory stickerPackCompletedDownloading]
                                                                     object:self];
            });
        }];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory stickerPackStartedPending]
                                                            object:self];
        return operation;
    }
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
     didFinishDownloadingStickerPack:(PQStickerPack *)pack
                               error:(NSError *)error {
    NSLog(@"Post downloaded");
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory stickerPackCompletedDownloading]
                                                        object:self];
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
               didUpdateWithProgress:(NSInteger)percentage {
    //NSLog(@"%i", percentage);
    [[NSNotificationCenter defaultCenter] postNotificationName:[PQNotificationNameFactory stickerPackChangedProgress:self.packId]
                                                        object:nil
                                                      userInfo:@{@"percentage":[NSNumber numberWithInt:percentage]}];
    

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
