//
//  PQSticker.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 4/9/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UIImageView;

@interface PQSticker : NSObject
@property NSString *objectId;
@property NSInteger width;
@property NSInteger height;
@property NSInteger frameCount;
@property NSInteger frameRate;
@property NSInteger framesPerCol;
@property NSInteger framesPerRow;
@property NSString *uri;
@property NSString *sourceUri;
@property NSString *spriteUri;
@property NSString *paddedSpriteUri;
@property NSArray *spriteArray;
@property (nonatomic) BOOL hasImage;
@property (nonatomic) BOOL hasThumbnail;
@property UIImage *thumbnailImage;

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
andPaddedSpriteUri:(NSString *)paddedSpriteUri;

- (void)populateStickerToUIImageVIew:(UIImageView *)imageView
                          onComplete:(void(^)())completeCall;
@end
