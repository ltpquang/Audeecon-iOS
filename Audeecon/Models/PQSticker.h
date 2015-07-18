//
//  PQSticker.h
//  Audeecon
//
//  Created by Le Thai Phuc Quang on 7/3/15.
//  Copyright (c) 2015 QuangLTP. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>

@interface PQSticker : RLMObject
@property NSString *stickerId;

@property NSString *thumbnailUri;
@property NSData *thumbnailData;

@property NSString *fullsizeUri;
@property NSData *fullsizeData;

@property NSString *spriteUri;
@property NSData *spriteData;

@property NSInteger frameCount;
@property NSInteger frameRate;
@property NSInteger framesPerCol;
@property NSInteger framesPerRow;

@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;

//Excluded
@property (nonatomic) UIImage *thumbnailImage;
@property (nonatomic) UIImage *fullsizeImage;
@property (nonatomic) NSArray *spriteArray;
@property (nonatomic) BOOL needToBeUpdated;

- (id)initWithStickerId:(NSString *)stickerId;

- (id)initWithStickerId:(NSString *)stickerId
        andThumbnailUri:(NSString *)thumbnailUri
         andFullsizeUri:(NSString *)fullsizeUri
           andSpriteUri:(NSString *)spriteUri
          andFrameCount:(NSInteger)frameCount
           andFrameRate:(NSInteger)frameRate
        andFramesPerCol:(NSInteger)framesPerCol
        andFramesPerRow:(NSInteger)framesPerRow;

- (void)animateStickerOnImageView:(UIImageView *)imageView;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQSticker>
RLM_ARRAY_TYPE(PQSticker)
