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
@property NSString *uri;
@property NSData *thumbnailData;
@property (nonatomic) UIImage *thumbnailImage;

- (id)initWithStickerId:(NSString *)stickerId
                 andUri:(NSString *)uri;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<PQSticker>
RLM_ARRAY_TYPE(PQSticker)
