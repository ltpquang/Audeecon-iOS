//
//  PQStickerPack.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/4/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQStickerPack.h"
#import "PQRequestingService.h"

@implementation PQStickerPack
@synthesize thumbnailData = _thumbnailData;
@synthesize thumbnailImage = _thumbnailImage;

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
        _thumbnailImage = [UIImage imageWithData:_thumbnailData];
    }
    return _thumbnailImage;
}

- (void)downloadThumbnail {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_thumbnailUri]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               self.thumbnailData = data;
                           }];
}

- (void)downloadStickersUsingRequestingService:(PQRequestingService *)requestingService
                                       success:(void(^)())successCall
                                       failure:(void(^)(NSError *error))failureCall {
    [requestingService getStickersOfStickerPackWithId:self.packId
                                              success:^(NSArray *result) {
                                                  [self.stickers addObjects:result];
                                                  successCall();
                                              }
                                              failure:^(NSError *error) {
                                                  failureCall(error);
                                              }];
}

- (void)downloadDataAndStickersUsingOperationQueue:(NSOperationQueue *)queue
                                          progress:(void(^)(NSInteger percentage))progressCall {
    PQStickerPackDownloadOperation *operation = [[PQStickerPackDownloadOperation alloc]
                                                 initWithStickerPack:self
                                                 delegate:self];
    [queue addOperation:operation];
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
     didFinishDownloadingStickerPack:(PQStickerPack *)pack
                               error:(NSError *)error {
    NSLog(@"Pack downloaded");
    NSLog(@"Pack image: %@", [UIImage imageWithData:self.thumbnailData]);
    for (PQSticker *sticker in self.stickers) {
        NSLog(@"Sticker image: %@", [UIImage imageWithData:sticker.thumbnailData]);
    }
}

- (void)stickerPackDownloadOperation:(PQStickerPackDownloadOperation *)operation
               didUpdateWithProgress:(NSInteger)percentage {
    NSLog(@"%i", percentage);
}
// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"thumbnailImage"];
}

@end
