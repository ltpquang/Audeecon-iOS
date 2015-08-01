//
//  PQSticker.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/3/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQSticker.h"
#import "UIImage+Sprite.h"

@implementation PQSticker

- (id)initWithStickerId:(NSString *)stickerId {
    if (self = [super init]) {
        _stickerId = stickerId;
    }
    return self;
}

- (id)initWithStickerId:(NSString *)stickerId
        andThumbnailUri:(NSString *)thumbnailUri
         andFullsizeUri:(NSString *)fullsizeUri
           andSpriteUri:(NSString *)spriteUri
          andFrameCount:(NSInteger)frameCount
           andFrameRate:(NSInteger)frameRate
        andFramesPerCol:(NSInteger)framesPerCol
        andFramesPerRow:(NSInteger)framesPerRow {
    if (self = [super init]) {
        _stickerId = stickerId;
        _thumbnailUri = thumbnailUri;
        _fullsizeUri = fullsizeUri;
        _spriteUri = spriteUri;
        _frameCount = frameCount;
        _frameRate = frameRate;
        _framesPerCol = framesPerCol;
        _framesPerRow = framesPerRow;
    }
    return self;
}

- (NSInteger)width {
    if (_width == 0) {
        _width = self.fullsizeImage.size.width;
    }
    return _width;
}

- (NSInteger)height {
    if (_height == 0) {
        _height = self.fullsizeImage.size.height;
    }
    return _height;
}

- (BOOL)needToBeUpdated {
    if (self.thumbnailData.length == 0 ||
        self.fullsizeData.length == 0) {
        return YES;
    }
    if (self.spriteUri.length != 0 && self.spriteData.length == 0) {
        return YES;
    }
    return NO;
}

- (UIImage *)thumbnailImage {
    if (_thumbnailImage == nil) {
        _thumbnailImage = [UIImage imageWithData:self.thumbnailData];
    }
    return _thumbnailImage;
}

- (UIImage *)fullsizeImage {
    if (_fullsizeImage == nil) {
        _fullsizeImage = [UIImage imageWithData:self.fullsizeData];
    }
    return _fullsizeImage;
}

- (NSArray *)spriteArray {
    if (_spriteArray == nil) {
        if (self.frameCount == 1) {
            _spriteArray = @[self.fullsizeImage];
        }
        else {
            UIImage *spriteSheet = [UIImage imageWithData:self.spriteData];
            _spriteArray = [spriteSheet spritesWithSpriteSheetImage:spriteSheet
                                                  columnCount:(self.frameCount - 1) / self.framesPerCol + 1
                                                     rowCount:(self.frameCount - 1) / self.framesPerRow + 1
                                                  spriteCount:self.frameCount];
        }
    }
    return _spriteArray;
}

- (void)animateStickerOnImageView:(UIImageView *)imageView {
    if (self.frameCount == 0) {
        imageView.image = self.fullsizeImage;
    }
    else {
        [imageView setAnimationImages:self.spriteArray];
        //[imageView setAnimationRepeatCount:1];
        [imageView setAnimationDuration:(float)(self.frameCount * self.frameRate)/1000];
        [imageView startAnimating];
    }
}

- (void)freeUpSticker {
    self.spriteArray = nil;
}


// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"stickerId":@"",
             @"thumbnailUri":@"",
             @"thumbnailData":[NSData new],
             @"fullsizeUri":@"",
             @"fullsizeData":[NSData new],
             @"spriteUri":@"",
             @"spriteData":[NSData new],
             @"frameCount":@0,
             @"frameRate":@0,
             @"framesPerCol":@0,
             @"framesPerRow":@0};
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"thumbnailImage",
             @"fullsizeImage",
             @"spriteArray",
             @"needToBeUpdated"];
}

+ (NSString *)primaryKey {
    return @"stickerId";
}

@end
