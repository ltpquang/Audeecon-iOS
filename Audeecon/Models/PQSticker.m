//
//  PQSticker.m
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import "PQSticker.h"
#import <UIKit/UIKit.h>
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

- (void)animateStickerUsingUIImage:(UIImage *)image onUIImageView:(UIImageView *)imageView {
    //NSArray *sprites = [image spritesWithSpriteSheetImage:image inRange:NSMakeRange(0, _frameCount) spriteSize:CGSizeMake(_width, _height)];
    
    //NSArray *sprites = [image spritesWithSpriteSheetImage:image spriteSize:CGSizeMake(_width, _height)];
    
    NSArray *sprites = [image spritesWithSpriteSheetImage:image spriteCount:_frameCount spriteSize:CGSizeMake(_width, _height)];
    
    [imageView setAnimationImages:sprites];
    [imageView setAnimationDuration:(float)(_frameCount * _frameRate)/1000];
    [imageView startAnimating];
}

- (void)populateStickerToUIImageVIew:(UIImageView *)imageView
                          onComplete:(void(^)())completeCall {
    if (_frameCount == 1) {
        [imageView setImageWithURL:[NSURL URLWithString:_uri]];
        completeCall();
    }
    else {
        __weak typeof(imageView) weakImageView = imageView;
        [imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_spriteUri]]
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      [self animateStickerUsingUIImage:image onUIImageView:weakImageView];
                                      completeCall();
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      completeCall();
                                  }];
    }
}
@end
