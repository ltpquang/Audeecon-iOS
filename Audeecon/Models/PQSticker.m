//
//  PQSticker.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQSticker.h"
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "UIImage+Sprite.h"
#import <UIImageView+AFNetworking.h>

@implementation PQSticker
- (id)initWithId:(NSString *)objectId
        andWidth:(NSInteger)width
       andHeight:(NSInteger)height
   andFrameCount:(NSInteger)frameCount
    andFrameRate:(NSInteger)frameRate
 andFramesPerCol:(NSInteger)framesPerCol
 andFramesPerRow:(NSInteger)framesPerRow
          andUri:(NSString *)uri
    andSourceUri:(NSString *)sourceUri
    andSpriteUri:(NSString *)spriteUri
andPaddedSpriteUri:(NSString *)paddedSpriteUri {
    if (self = [super init]) {
        _objectId = objectId;
        _width = width;
        _height = height;
        _frameCount = frameCount;
        _frameRate = frameRate;
        _framesPerCol = framesPerCol;
        _framesPerRow = framesPerRow;
        _uri = uri;
        _sourceUri = sourceUri;
        _spriteUri = spriteUri;
        _paddedSpriteUri = paddedSpriteUri;
    }
    return self;
}

- (BOOL)hasImage {
    //return _spriteArray != nil;
    return self.hasThumbnail && _frameCount == 1;
}

- (BOOL)hasThumbnail {
    return _thumbnailImage != nil;
}

- (void)animateStickerUsingUIImage:(UIImage *)image onUIImageView:(UIImageView *)imageView {
    
    NSArray *sprites = [image spritesWithSpriteSheetImage:image
                                              columnCount:(_frameCount - 1) / _framesPerCol + 1
                                                 rowCount:(_frameCount - 1) / _framesPerRow + 1
                                              spriteCount:_frameCount];
    
    [imageView setAnimationImages:sprites];
    //[imageView setAnimationRepeatCount:1];
    [imageView setAnimationDuration:(float)(_frameCount * _frameRate)/1000];
    [imageView startAnimating];
}

- (void)populateStickerToUIImageVIew:(UIImageView *)imageView
                          onComplete:(void(^)())completeCall {
    if (_frameCount == 1) {
        [imageView setImage:[_spriteArray firstObject]];
        completeCall();
    }
    else {
        [imageView setAnimationImages:_spriteArray];
        [imageView setAnimationDuration:(float)(_frameCount * _frameRate)/1000];
        [imageView setAnimationRepeatCount:3];
        [imageView startAnimating];
        completeCall();
    }
}
@end
